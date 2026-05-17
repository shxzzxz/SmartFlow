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
          startDate: DateTime(2026, 6, 10),
          repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          occurredAt: DateTime(2026, 5, 10),
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
          startDate: DateTime(2026, 6, 10),
          repaymentMethod: InstallmentRepaymentMethod.equalInstallment,
          interestRatePeriod: InterestRatePeriod.monthly,
          interestRatePpm: 5000,
          occurredAt: DateTime(2026, 5, 10),
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
          startDate: DateTime(2026, 6, 9),
          repaymentMethod: InstallmentRepaymentMethod.flatFee,
          totalFeeMinor: 36000,
        ),
      );
      final contractId =
          (result as Success<CreateContractResult>).value.contractId;
      final contract = await service.findContract(contractId);
      expect(contract!.disbursementTransactionId, isNull);
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
          startDate: DateTime(2026, 6, 10),
          repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          occurredAt: DateTime(2026, 5, 10),
        ),
      );
      final contractId =
          (result as Success<CreateContractResult>).value.contractId;

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
    });

    test('createEarlySettlement 剩余期次 skipped 且合同 closed', () async {
      final contractResult = await service.createDisbursementContract(
        CreateDisbursementContractCommand(
          liabilityAccountId: liabilityAccountId,
          disbursementAccountId: assetAccountId,
          principal: const Money(minorUnits: 1000000),
          totalPeriods: 10,
          startDate: DateTime(2026, 6, 10),
          repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          occurredAt: DateTime(2026, 5, 10),
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
          startDate: DateTime(2026, 6, 10),
          repaymentMethod: InstallmentRepaymentMethod.equalPrincipal,
          occurredAt: DateTime(2026, 5, 10),
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
