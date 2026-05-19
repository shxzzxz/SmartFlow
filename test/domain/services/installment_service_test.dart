import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/core/money/money.dart';
import 'package:smartflow/core/result/result.dart';
import 'package:smartflow/data/database/app_database.dart';
import 'package:smartflow/data/repositories/drift_account_repository.dart';
import 'package:smartflow/data/repositories/drift_installment_repository.dart';
import 'package:smartflow/data/repositories/drift_posting_repository.dart';
import 'package:smartflow/data/repositories/drift_system_account_resolver.dart';
import 'package:smartflow/data/repositories/drift_transaction_query_repository.dart';
import 'package:smartflow/domain/enums/accounting_enums.dart';
import 'package:smartflow/domain/enums/installment_enums.dart';
import 'package:smartflow/domain/services/installment_service.dart';
import 'package:smartflow/domain/services/posting_service.dart';
import 'package:smartflow/domain/services/transaction_service.dart';

import '../../helpers/test_app_database.dart';

void main() {
  group('InstallmentService integration', () {
    late AppDatabase database;
    late InstallmentService service;
    late int assetAccountId;
    late int liabilityAccountId;

    setUp(() async {
      database = createTestDatabase();
      final accountRepository = DriftAccountRepository(database);
      final postingRepository = DriftPostingRepository(database);
      final queryRepository = DriftTransactionQueryRepository(database);
      final systemAccounts = DriftSystemAccountResolver(database);
      final transactionService = TransactionServiceImpl(
        PostingServiceImpl(postingRepository),
        accountRepository: accountRepository,
        transactionQueryRepository: queryRepository,
        systemAccountResolver: systemAccounts,
        postingRepository: postingRepository,
      );
      service = InstallmentServiceImpl(
        repository: DriftInstallmentRepository(database),
        transactionService: transactionService,
        queryRepository: queryRepository,
      );

      assetAccountId = await _insertAccount(
        database,
        name: '招行',
        type: AccountType.asset,
        subtype: AccountSubtype.bankCard,
        balanceMinor: 5000000,
      );
      liabilityAccountId = await _insertAccount(
        database,
        name: '借呗',
        type: AccountType.liability,
        subtype: AccountSubtype.loan,
      );
    });

    tearDown(() async {
      await database.close();
    });

    Future<int> createSimpleContract() async {
      final result = await service.createDisbursementContract(
        CreateDisbursementContractCommand(
          liabilityAccountId: liabilityAccountId,
          disbursementAccountId: assetAccountId,
          principal: const Money(minorUnits: 100000),
          totalPeriods: 1,
          borrowingDate: DateTime(2026, 5, 10),
          firstRepaymentDate: DateTime(2026, 6, 10),
          repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
        ),
      );
      return (result as Success<CreateContractResult>).value.contractId;
    }

    test('createDisbursementContract 写入 BORROWING + 合同 + 计划', () async {
      final result = await service.createDisbursementContract(
        CreateDisbursementContractCommand(
          liabilityAccountId: liabilityAccountId,
          disbursementAccountId: assetAccountId,
          principal: const Money(minorUnits: 1200000),
          totalPeriods: 12,
          borrowingDate: DateTime(2026, 5, 10),
          firstRepaymentDate: DateTime(2026, 6, 10),
          repaymentMethod: InstallmentRepaymentMethod.equalInstallment,
          interestRatePeriod: InterestRatePeriod.monthly,
          interestRatePpm: 5000,
        ),
      );
      expect(result, isA<Success<CreateContractResult>>());
      final contractId =
          (result as Success<CreateContractResult>).value.contractId;

      final contract = await service.findContract(contractId);
      expect(contract, isNotNull);
      expect(contract!.sourceType, InstallmentSourceType.disbursement);
      expect(contract.status, InstallmentContractStatus.active);
      expect(contract.disbursementTransactionId, isNotNull);
      expect(contract.firstRepaymentDate, DateTime(2026, 6, 10));
      expect(contract.lastRepaymentDate, DateTime(2027, 5, 10));

      final schedules = await service.listSchedules(contractId);
      expect(schedules, hasLength(12));
      final principalSum = schedules.fold<int>(
        0,
        (acc, s) => acc + s.expectedPrincipal.minorUnits,
      );
      expect(principalSum, 1200000);

      expect(await _balanceOf(database, assetAccountId), 5000000 + 1200000);
      expect(await _balanceOf(database, liabilityAccountId), 1200000);
    });

    test('createBillConversionContract 不产生交易', () async {
      final result = await service.createBillConversionContract(
        CreateBillConversionContractCommand(
          liabilityAccountId: liabilityAccountId,
          principal: const Money(minorUnits: 500000),
          totalPeriods: 12,
          borrowingDate: DateTime(2026, 5, 9),
          firstRepaymentDate: DateTime(2026, 6, 9),
          repaymentMethod: InstallmentRepaymentMethod.flatFee,
          totalFeeMinor: 36000,
        ),
      );
      final contractId =
          (result as Success<CreateContractResult>).value.contractId;
      final contract = await service.findContract(contractId);
      expect(contract!.disbursementTransactionId, isNull);
      expect(contract.totalFeeMinor, 36000);
      expect(await _balanceOf(database, liabilityAccountId), 0);
      final schedules = await service.listSchedules(contractId);
      expect(schedules, hasLength(12));
      final feeSum = schedules.fold<int>(
        0,
        (acc, s) => acc + s.expectedFee.minorUnits,
      );
      expect(feeSum, 36000);
    });

    test('createRegularRepayment 翻转期次状态并联动合同 settled', () async {
      final contractId = await createSimpleContract();
      final schedules = await service.listSchedules(contractId);
      final result = await service.createRegularRepayment(
        CreateRegularRepaymentCommand(
          contractId: contractId,
          scheduleId: schedules.single.id,
          principal: const Money(minorUnits: 100000),
          paidFromAccountId: assetAccountId,
          occurredAt: DateTime(2026, 7, 10),
        ),
      );
      expect(result, isA<Success>());
      final updated = await service.listSchedules(contractId);
      expect(updated.single.status, InstallmentScheduleStatus.paid);
      final contract = await service.findContract(contractId);
      expect(contract!.status, InstallmentContractStatus.settled);
    });

    test('createExtraPrincipalRepayment 触发 PENDING 期次重算', () async {
      final result = await service.createDisbursementContract(
        CreateDisbursementContractCommand(
          liabilityAccountId: liabilityAccountId,
          disbursementAccountId: assetAccountId,
          principal: const Money(minorUnits: 1000000),
          totalPeriods: 10,
          borrowingDate: DateTime(2026, 5, 10),
          firstRepaymentDate: DateTime(2026, 6, 10),
          repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
        ),
      );
      final contractId =
          (result as Success<CreateContractResult>).value.contractId;

      final beforeDates = (await service.listSchedules(contractId))
          .map((s) => s.expectedRepaymentDate)
          .toList();

      final extra = await service.createExtraPrincipalRepayment(
        CreateExtraPrincipalRepaymentCommand(
          contractId: contractId,
          principal: const Money(minorUnits: 300000),
          paidFromAccountId: assetAccountId,
          occurredAt: DateTime(2026, 6, 1),
        ),
      );
      expect(extra, isA<Success>());

      final schedules = await service.listSchedules(contractId);
      final pendingPrincipalSum = schedules
          .where((s) => s.status == InstallmentScheduleStatus.pending)
          .fold<int>(0, (acc, s) => acc + s.expectedPrincipal.minorUnits);
      expect(pendingPrincipalSum, 700000);

      // 提前还本后日期不能变。
      final afterDates =
          schedules.map((s) => s.expectedRepaymentDate).toList();
      expect(afterDates, beforeDates);
    });

    test('createExtraPrincipalRepayment 支持利息', () async {
      final contractResult = await service.createDisbursementContract(
        CreateDisbursementContractCommand(
          liabilityAccountId: liabilityAccountId,
          disbursementAccountId: assetAccountId,
          principal: const Money(minorUnits: 1000000),
          totalPeriods: 10,
          borrowingDate: DateTime(2026, 5, 10),
          firstRepaymentDate: DateTime(2026, 6, 10),
          repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
        ),
      );
      final contractId =
          (contractResult as Success<CreateContractResult>).value.contractId;

      final extra = await service.createExtraPrincipalRepayment(
        CreateExtraPrincipalRepaymentCommand(
          contractId: contractId,
          principal: const Money(minorUnits: 300000),
          interest: const Money(minorUnits: 1500),
          paidFromAccountId: assetAccountId,
          occurredAt: DateTime(2026, 6, 1),
        ),
      );
      expect(extra, isA<Success>());

      // 资产账户应扣减本金 + 利息
      final assetBalance = await _balanceOf(database, assetAccountId);
      expect(assetBalance, 5000000 + 1000000 - 300000 - 1500);
    });

    test('createEarlySettlement 剩余期次 skipped 且合同 closed', () async {
      final contractResult = await service.createDisbursementContract(
        CreateDisbursementContractCommand(
          liabilityAccountId: liabilityAccountId,
          disbursementAccountId: assetAccountId,
          principal: const Money(minorUnits: 1000000),
          totalPeriods: 10,
          borrowingDate: DateTime(2026, 5, 10),
          firstRepaymentDate: DateTime(2026, 6, 10),
          repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
        ),
      );
      final contractId =
          (contractResult as Success<CreateContractResult>).value.contractId;

      final settle = await service.createEarlySettlement(
        CreateEarlySettlementCommand(
          contractId: contractId,
          principal: const Money(minorUnits: 1000000),
          paidFromAccountId: assetAccountId,
          occurredAt: DateTime(2026, 7, 1),
        ),
      );
      expect(settle, isA<Success>());
      final contract = await service.findContract(contractId);
      expect(contract!.status, InstallmentContractStatus.closed);
      final schedules = await service.listSchedules(contractId);
      for (final s in schedules) {
        expect(s.status, InstallmentScheduleStatus.skipped);
      }
    });

    test('revertRepayment(regular) 将 schedule 回退至 pending', () async {
      final contractId = await createSimpleContract();
      final schedules = await service.listSchedules(contractId);

      final repayResult = await service.createRegularRepayment(
        CreateRegularRepaymentCommand(
          contractId: contractId,
          scheduleId: schedules.single.id,
          principal: const Money(minorUnits: 100000),
          paidFromAccountId: assetAccountId,
          occurredAt: DateTime(2026, 7, 10),
        ),
      );
      final txId = (repayResult as Success).value.transactionId;

      final revert = await service
          .revertRepayment(RevertRepaymentCommand(transactionId: txId));
      expect(revert, isA<Success>());

      final updated = await service.listSchedules(contractId);
      expect(updated.single.status, InstallmentScheduleStatus.pending);
      final contract = await service.findContract(contractId);
      expect(contract!.status, InstallmentContractStatus.active);
    });

    test('revertRepayment(earlySettlement) 恢复期次为 pending 且合同回 active',
        () async {
      final contractResult = await service.createDisbursementContract(
        CreateDisbursementContractCommand(
          liabilityAccountId: liabilityAccountId,
          disbursementAccountId: assetAccountId,
          principal: const Money(minorUnits: 500000),
          totalPeriods: 5,
          borrowingDate: DateTime(2026, 5, 10),
          firstRepaymentDate: DateTime(2026, 6, 10),
          repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
        ),
      );
      final contractId =
          (contractResult as Success<CreateContractResult>).value.contractId;
      final settle = await service.createEarlySettlement(
        CreateEarlySettlementCommand(
          contractId: contractId,
          principal: const Money(minorUnits: 500000),
          paidFromAccountId: assetAccountId,
          occurredAt: DateTime(2026, 7, 1),
        ),
      );
      final settleTxId = (settle as Success).value.transactionId;

      final revert = await service.revertRepayment(
        RevertRepaymentCommand(transactionId: settleTxId),
      );
      expect(revert, isA<Success>());
      final contract = await service.findContract(contractId);
      expect(contract!.status, InstallmentContractStatus.active);
      final schedules = await service.listSchedules(contractId);
      for (final s in schedules) {
        expect(s.status, InstallmentScheduleStatus.pending);
      }
    });

    group('updateContract', () {
      test('调整末期还款日：仅末期日期变更，其它 pending 行日期不变', () async {
        final contractResult = await service.createDisbursementContract(
          CreateDisbursementContractCommand(
            liabilityAccountId: liabilityAccountId,
            disbursementAccountId: assetAccountId,
            principal: const Money(minorUnits: 1200000),
            totalPeriods: 12,
            borrowingDate: DateTime(2026, 5, 10),
            firstRepaymentDate: DateTime(2026, 6, 10),
            repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          ),
        );
        final contractId =
            (contractResult as Success<CreateContractResult>).value.contractId;

        final res = await service.updateContract(
          UpdateContractCommand(
            contractId: contractId,
            totalPeriods: 12,
            firstRepaymentDate: DateTime(2026, 6, 10),
            lastRepaymentDate: DateTime(2027, 6, 20), // 末期推后 10 天
            repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          ),
        );
        expect(res, isA<Success>());
        final schedules = await service.listSchedules(contractId);
        expect(schedules.last.expectedRepaymentDate, DateTime(2027, 6, 20));
        // 第 11 期保持原日期
        expect(schedules[10].expectedRepaymentDate, DateTime(2027, 4, 10));
      });

      test('paid 后修改首期还款日应失败', () async {
        final contractResult = await service.createDisbursementContract(
          CreateDisbursementContractCommand(
            liabilityAccountId: liabilityAccountId,
            disbursementAccountId: assetAccountId,
            principal: const Money(minorUnits: 600000),
            totalPeriods: 6,
            borrowingDate: DateTime(2026, 5, 10),
            firstRepaymentDate: DateTime(2026, 6, 10),
            repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          ),
        );
        final contractId =
            (contractResult as Success<CreateContractResult>).value.contractId;
        final schedules = await service.listSchedules(contractId);
        await service.createRegularRepayment(
          CreateRegularRepaymentCommand(
            contractId: contractId,
            scheduleId: schedules.first.id,
            principal: const Money(minorUnits: 100000),
            paidFromAccountId: assetAccountId,
            occurredAt: DateTime(2026, 6, 10),
          ),
        );

        final res = await service.updateContract(
          UpdateContractCommand(
            contractId: contractId,
            totalPeriods: 6,
            firstRepaymentDate: DateTime(2026, 7, 10), // 改了
            lastRepaymentDate: DateTime(2026, 12, 10),
            repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          ),
        );
        expect(res, isA<FailureResult>());
      });

      test('期数减少：超出的 pending 行被 skipped 清零', () async {
        final contractResult = await service.createDisbursementContract(
          CreateDisbursementContractCommand(
            liabilityAccountId: liabilityAccountId,
            disbursementAccountId: assetAccountId,
            principal: const Money(minorUnits: 600000),
            totalPeriods: 6,
            borrowingDate: DateTime(2026, 5, 10),
            firstRepaymentDate: DateTime(2026, 6, 10),
            repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          ),
        );
        final contractId =
            (contractResult as Success<CreateContractResult>).value.contractId;

        final res = await service.updateContract(
          UpdateContractCommand(
            contractId: contractId,
            totalPeriods: 3,
            firstRepaymentDate: DateTime(2026, 6, 10),
            lastRepaymentDate: DateTime(2026, 8, 10),
            repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          ),
        );
        expect(res, isA<Success>());

        final schedules = await service.listSchedules(contractId);
        final pending = schedules
            .where((s) => s.status == InstallmentScheduleStatus.pending)
            .toList();
        final skipped = schedules
            .where((s) => s.status == InstallmentScheduleStatus.skipped)
            .toList();
        expect(pending, hasLength(3));
        expect(skipped, hasLength(3));
        final principalSum = pending.fold<int>(
          0,
          (acc, s) => acc + s.expectedPrincipal.minorUnits,
        );
        expect(principalSum, 600000);
      });

      test('schedulePatches 覆盖 pending 行金额', () async {
        final contractResult = await service.createDisbursementContract(
          CreateDisbursementContractCommand(
            liabilityAccountId: liabilityAccountId,
            disbursementAccountId: assetAccountId,
            principal: const Money(minorUnits: 600000),
            totalPeriods: 6,
            borrowingDate: DateTime(2026, 5, 10),
            firstRepaymentDate: DateTime(2026, 6, 10),
            repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          ),
        );
        final contractId =
            (contractResult as Success<CreateContractResult>).value.contractId;

        await service.updateContract(
          UpdateContractCommand(
            contractId: contractId,
            totalPeriods: 6,
            firstRepaymentDate: DateTime(2026, 6, 10),
            lastRepaymentDate: DateTime(2026, 11, 10),
            repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
            schedulePatches: [
              const SchedulePendingPatch(
                periodNo: 3,
                expectedPrincipal: Money(minorUnits: 200000),
                expectedInterest: Money(minorUnits: 0),
                expectedFee: Money(minorUnits: 0),
              ),
            ],
          ),
        );
        final schedules = await service.listSchedules(contractId);
        expect(
          schedules.firstWhere((s) => s.periodNo == 3).expectedPrincipal
              .minorUnits,
          200000,
        );
      });

      test('期数 < paidCount+1 失败', () async {
        final contractResult = await service.createDisbursementContract(
          CreateDisbursementContractCommand(
            liabilityAccountId: liabilityAccountId,
            disbursementAccountId: assetAccountId,
            principal: const Money(minorUnits: 600000),
            totalPeriods: 6,
            borrowingDate: DateTime(2026, 5, 10),
            firstRepaymentDate: DateTime(2026, 6, 10),
            repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          ),
        );
        final contractId =
            (contractResult as Success<CreateContractResult>).value.contractId;
        final schedules = await service.listSchedules(contractId);
        // 还掉前 2 期
        await service.createRegularRepayment(
          CreateRegularRepaymentCommand(
            contractId: contractId,
            scheduleId: schedules[0].id,
            principal: const Money(minorUnits: 100000),
            paidFromAccountId: assetAccountId,
            occurredAt: DateTime(2026, 6, 10),
          ),
        );
        await service.createRegularRepayment(
          CreateRegularRepaymentCommand(
            contractId: contractId,
            scheduleId: schedules[1].id,
            principal: const Money(minorUnits: 100000),
            paidFromAccountId: assetAccountId,
            occurredAt: DateTime(2026, 7, 10),
          ),
        );

        // 试图把期数改成 2（应失败，因为 paid=2，至少要 3）
        final res = await service.updateContract(
          UpdateContractCommand(
            contractId: contractId,
            totalPeriods: 2,
            firstRepaymentDate: DateTime(2026, 6, 10),
            lastRepaymentDate: DateTime(2026, 7, 10),
            repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          ),
        );
        expect(res, isA<FailureResult>());
      });
    });
  });
}

Future<int> _insertAccount(
  AppDatabase database, {
  required String name,
  required AccountType type,
  AccountSubtype? subtype,
  int balanceMinor = 0,
}) {
  return database.into(database.accounts).insert(
        AccountsCompanion.insert(
          name: name,
          accountType: type,
          accountSubtype: Value(subtype),
          currencyCode: Money.defaultCurrency,
          balanceMinor: Value(balanceMinor),
        ),
      );
}

Future<int> _balanceOf(AppDatabase database, int accountId) async {
  final row = await (database.select(database.accounts)
        ..where((a) => a.id.equals(accountId)))
      .getSingle();
  return row.balanceMinor;
}
