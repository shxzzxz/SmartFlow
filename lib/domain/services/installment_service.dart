import '../../core/errors/failure.dart';
import '../../core/money/money.dart';
import '../../core/result/result.dart';
import '../entities/installment_contract.dart';
import '../entities/installment_repayment.dart';
import '../entities/installment_schedule.dart';
import '../enums/accounting_enums.dart';
import '../repositories/installment_repository.dart';
import '../repositories/transaction_query_repository.dart';
import 'installment_schedule_generator.dart';
import 'posting_command.dart';
import 'transaction_service.dart';

class CreateDisbursementContractCommand {
  const CreateDisbursementContractCommand({
    required this.liabilityAccountId,
    required this.disbursementAccountId,
    required this.principal,
    required this.totalPeriods,
    required this.borrowingDate,
    required this.firstRepaymentDate,
    required this.repaymentMethod,
    this.lastRepaymentDate,
    this.interestRatePeriod,
    this.interestRatePpm,
    this.totalFeeMinor = 0,
    this.note,
    this.counterpartyName,
  });

  final int liabilityAccountId;
  final int disbursementAccountId;
  final Money principal;
  final int totalPeriods;

  /// 借款日期，同时作为放款交易的 occurredAt。
  final DateTime borrowingDate;
  final DateTime firstRepaymentDate;

  /// 末期还款日，缺省时 = 首期 + (期数-1) 月。
  final DateTime? lastRepaymentDate;

  final InstallmentRepaymentMethod repaymentMethod;
  final InterestRatePeriod? interestRatePeriod;
  final int? interestRatePpm;
  final int totalFeeMinor;
  final String? note;
  final String? counterpartyName;
}

class CreateBillConversionContractCommand {
  const CreateBillConversionContractCommand({
    required this.liabilityAccountId,
    required this.principal,
    required this.totalPeriods,
    required this.borrowingDate,
    required this.firstRepaymentDate,
    required this.repaymentMethod,
    this.lastRepaymentDate,
    this.interestRatePeriod,
    this.interestRatePpm,
    this.totalFeeMinor = 0,
    this.note,
  });

  final int liabilityAccountId;
  final Money principal;
  final int totalPeriods;
  final DateTime borrowingDate;
  final DateTime firstRepaymentDate;
  final DateTime? lastRepaymentDate;
  final InstallmentRepaymentMethod repaymentMethod;
  final InterestRatePeriod? interestRatePeriod;
  final int? interestRatePpm;
  final int totalFeeMinor;
  final String? note;
}

class CreateRegularRepaymentCommand {
  const CreateRegularRepaymentCommand({
    required this.contractId,
    required this.scheduleId,
    required this.principal,
    required this.paidFromAccountId,
    required this.occurredAt,
    this.interest,
    this.fee,
    this.discount,
    this.interestExpenseAccountId,
    this.feeExpenseAccountId,
    this.note,
    this.counterpartyName,
  });

  final int contractId;
  final int scheduleId;
  final Money principal;
  final Money? interest;
  final Money? fee;
  final Money? discount;
  final int paidFromAccountId;
  final int? interestExpenseAccountId;
  final int? feeExpenseAccountId;
  final DateTime occurredAt;
  final String? note;
  final String? counterpartyName;
}

class CreateExtraPrincipalRepaymentCommand {
  const CreateExtraPrincipalRepaymentCommand({
    required this.contractId,
    required this.principal,
    required this.paidFromAccountId,
    required this.occurredAt,
    this.interest,
    this.fee,
    this.interestExpenseAccountId,
    this.feeExpenseAccountId,
    this.note,
    this.counterpartyName,
  });

  final int contractId;
  final Money principal;

  /// 提前还本时一并支付的利息（含截至本日的应计利息）。
  final Money? interest;

  /// 提前还本手续费。
  final Money? fee;

  final int paidFromAccountId;
  final int? interestExpenseAccountId;
  final int? feeExpenseAccountId;
  final DateTime occurredAt;
  final String? note;
  final String? counterpartyName;
}

class CreateEarlySettlementCommand {
  const CreateEarlySettlementCommand({
    required this.contractId,
    required this.principal,
    required this.paidFromAccountId,
    required this.occurredAt,
    this.fee,
    this.interest,
    this.interestExpenseAccountId,
    this.feeExpenseAccountId,
    this.note,
    this.counterpartyName,
  });

  final int contractId;
  final Money principal;
  final Money? interest;
  final Money? fee;
  final int paidFromAccountId;
  final int? interestExpenseAccountId;
  final int? feeExpenseAccountId;
  final DateTime occurredAt;
  final String? note;
  final String? counterpartyName;
}

class RevertRepaymentCommand {
  const RevertRepaymentCommand({required this.transactionId});

  final int transactionId;
}

/// pending 期次的单行手工编辑值（不会改 paid / skipped 行）。
class SchedulePendingPatch {
  const SchedulePendingPatch({
    required this.periodNo,
    this.expectedPrincipal,
    this.expectedInterest,
    this.expectedFee,
    this.expectedRepaymentDate,
  });

  final int periodNo;
  final Money? expectedPrincipal;
  final Money? expectedInterest;
  final Money? expectedFee;
  final DateTime? expectedRepaymentDate;
}

/// 合同编辑命令。
///
/// 编辑范围由 service 校验：
/// - 借款日期始终不可改（由原合同决定）。
/// - 若已有 paid 期次，首期还款日不可改（动了会和已发生的 paid 行错位）。
/// - 期数可改，但必须 >= 已 paid 期次数 + 1（保证至少有 1 个 pending 行）。
/// - 末期还款日始终可改（仅影响最后一期）。
/// - method / 利率 / 手续费 可改，重算 pending 金额。
/// - [schedulePatches] 在按配置重算后覆盖到对应 pending 行。
class UpdateContractCommand {
  const UpdateContractCommand({
    required this.contractId,
    required this.totalPeriods,
    required this.firstRepaymentDate,
    required this.lastRepaymentDate,
    required this.repaymentMethod,
    this.interestRatePeriod,
    this.interestRatePpm,
    this.totalFeeMinor = 0,
    this.note,
    this.clearNote = false,
    this.schedulePatches = const [],
  });

  final int contractId;
  final int totalPeriods;
  final DateTime firstRepaymentDate;
  final DateTime lastRepaymentDate;
  final InstallmentRepaymentMethod repaymentMethod;
  final InterestRatePeriod? interestRatePeriod;
  final int? interestRatePpm;
  final int totalFeeMinor;
  final String? note;
  final bool clearNote;
  final List<SchedulePendingPatch> schedulePatches;
}

class CreateContractResult {
  const CreateContractResult({
    required this.contractId,
    this.disbursementTransactionId,
  });

  final int contractId;
  final int? disbursementTransactionId;
}

abstract interface class InstallmentService {
  Future<Result<CreateContractResult>> createDisbursementContract(
    CreateDisbursementContractCommand command,
  );

  Future<Result<CreateContractResult>> createBillConversionContract(
    CreateBillConversionContractCommand command,
  );

  Future<Result<void>> updateContract(UpdateContractCommand command);

  Future<Result<PostTransactionResult>> createRegularRepayment(
    CreateRegularRepaymentCommand command,
  );

  Future<Result<PostTransactionResult>> createExtraPrincipalRepayment(
    CreateExtraPrincipalRepaymentCommand command,
  );

  Future<Result<PostTransactionResult>> createEarlySettlement(
    CreateEarlySettlementCommand command,
  );

  Future<Result<void>> revertRepayment(RevertRepaymentCommand command);

  Future<List<InstallmentContract>> listContractsByLiabilityAccount(
    int liabilityAccountId,
  );

  Future<InstallmentContract?> findContract(int contractId);

  Future<List<InstallmentSchedule>> listSchedules(int contractId);

  Future<List<InstallmentRepayment>> listRepayments(int contractId);
}

class InstallmentServiceImpl implements InstallmentService {
  InstallmentServiceImpl({
    required InstallmentRepository repository,
    required TransactionService transactionService,
    required TransactionQueryRepository queryRepository,
    InstallmentScheduleGenerator generator =
        const InstallmentScheduleGenerator(),
  })  : _repository = repository,
        _transactionService = transactionService,
        _queryRepository = queryRepository,
        _generator = generator;

  final InstallmentRepository _repository;
  final TransactionService _transactionService;
  final TransactionQueryRepository _queryRepository;
  final InstallmentScheduleGenerator _generator;

  @override
  Future<Result<CreateContractResult>> createDisbursementContract(
    CreateDisbursementContractCommand command,
  ) async {
    final preValidation = _validateCreate(
      principal: command.principal,
      totalPeriods: command.totalPeriods,
      firstRepaymentDate: command.firstRepaymentDate,
      lastRepaymentDate: command.lastRepaymentDate,
    );
    if (preValidation != null) return Result.failure(preValidation);

    final lastDate = command.lastRepaymentDate ??
        _defaultLastDate(command.firstRepaymentDate, command.totalPeriods);

    final borrowingResult = await _transactionService.createBorrowing(
      CreateBorrowingCommand(
        amount: command.principal,
        liabilityAccountId: command.liabilityAccountId,
        occurredAt: command.borrowingDate,
        receiveAccountId: command.disbursementAccountId,
        counterpartyName: command.counterpartyName,
        note: command.note,
      ),
    );
    return borrowingResult.when(
      failure: Result.failure,
      success: (borrowing) async {
        final drafts = _generator.generate(
          principal: command.principal,
          borrowingDate: command.borrowingDate,
          firstRepaymentDate: command.firstRepaymentDate,
          lastRepaymentDate: lastDate,
          totalPeriods: command.totalPeriods,
          method: command.repaymentMethod,
          ratePeriod: command.interestRatePeriod,
          ratePpm: command.interestRatePpm,
          totalFeeMinor: command.totalFeeMinor,
        );
        final contractId = await _repository.insertContract(
          InstallmentContractDraft(
            liabilityAccountId: command.liabilityAccountId,
            sourceType: InstallmentSourceType.disbursement,
            disbursementAccountId: command.disbursementAccountId,
            disbursementTransactionId: borrowing.transactionId,
            principal: command.principal,
            totalPeriods: command.totalPeriods,
            borrowingDate: command.borrowingDate,
            firstRepaymentDate: command.firstRepaymentDate,
            lastRepaymentDate: lastDate,
            repaymentMethod: command.repaymentMethod,
            interestRatePeriod: command.interestRatePeriod,
            interestRatePpm: command.interestRatePpm,
            totalFeeMinor: command.totalFeeMinor,
            status: InstallmentContractStatus.active,
            note: command.note,
          ),
        );
        await _repository.replaceSchedules(contractId, drafts);
        return Result.success(
          CreateContractResult(
            contractId: contractId,
            disbursementTransactionId: borrowing.transactionId,
          ),
        );
      },
    );
  }

  @override
  Future<Result<CreateContractResult>> createBillConversionContract(
    CreateBillConversionContractCommand command,
  ) async {
    final preValidation = _validateCreate(
      principal: command.principal,
      totalPeriods: command.totalPeriods,
      firstRepaymentDate: command.firstRepaymentDate,
      lastRepaymentDate: command.lastRepaymentDate,
    );
    if (preValidation != null) return Result.failure(preValidation);

    final lastDate = command.lastRepaymentDate ??
        _defaultLastDate(command.firstRepaymentDate, command.totalPeriods);

    final drafts = _generator.generate(
      principal: command.principal,
      borrowingDate: command.borrowingDate,
      firstRepaymentDate: command.firstRepaymentDate,
      lastRepaymentDate: lastDate,
      totalPeriods: command.totalPeriods,
      method: command.repaymentMethod,
      ratePeriod: command.interestRatePeriod,
      ratePpm: command.interestRatePpm,
      totalFeeMinor: command.totalFeeMinor,
    );
    final contractId = await _repository.insertContract(
      InstallmentContractDraft(
        liabilityAccountId: command.liabilityAccountId,
        sourceType: InstallmentSourceType.billConversion,
        principal: command.principal,
        totalPeriods: command.totalPeriods,
        borrowingDate: command.borrowingDate,
        firstRepaymentDate: command.firstRepaymentDate,
        lastRepaymentDate: lastDate,
        repaymentMethod: command.repaymentMethod,
        interestRatePeriod: command.interestRatePeriod,
        interestRatePpm: command.interestRatePpm,
        totalFeeMinor: command.totalFeeMinor,
        status: InstallmentContractStatus.active,
        note: command.note,
      ),
    );
    await _repository.replaceSchedules(contractId, drafts);
    return Result.success(CreateContractResult(contractId: contractId));
  }

  @override
  Future<Result<void>> updateContract(UpdateContractCommand command) async {
    final contract = await _repository.findContract(command.contractId);
    if (contract == null) {
      return const Result.failure(
        Failure(
          code: 'installment_contract_not_found',
          message: 'Installment contract does not exist.',
        ),
      );
    }
    if (contract.status != InstallmentContractStatus.active) {
      return const Result.failure(
        Failure(
          code: 'installment_contract_not_active',
          message: 'Only active contracts can be edited.',
        ),
      );
    }
    if (command.totalPeriods <= 0) {
      return const Result.failure(
        Failure(
          code: 'installment_total_periods_invalid',
          message: 'Total periods must be greater than zero.',
        ),
      );
    }
    if (!command.lastRepaymentDate.isAfter(command.firstRepaymentDate) &&
        command.totalPeriods > 1) {
      return const Result.failure(
        Failure(
          code: 'installment_dates_invalid',
          message: 'Last repayment date must be after first.',
        ),
      );
    }

    final schedules = await _repository.listSchedules(command.contractId);
    final paid = schedules
        .where((s) => s.status == InstallmentScheduleStatus.paid)
        .toList()
      ..sort((a, b) => a.periodNo.compareTo(b.periodNo));
    final paidCount = paid.length;

    if (paidCount > 0 &&
        command.firstRepaymentDate != contract.firstRepaymentDate) {
      return const Result.failure(
        Failure(
          code: 'installment_first_date_locked',
          message:
              'First repayment date cannot change after any period is paid.',
        ),
      );
    }
    if (command.totalPeriods < paidCount + 1) {
      return const Result.failure(
        Failure(
          code: 'installment_periods_too_few',
          message: 'Total periods must be at least paidCount + 1.',
        ),
      );
    }

    // 计算 pending 期次的目标日期。
    // - 完整日期序列由 generateDates(firstRepaymentDate, lastRepaymentDate, totalPeriods) 推导
    // - 已 paid 占用前 paidCount 个序位
    // - 剩余日期分配给 pending 行
    final allDates = _generator.generateDates(
      firstRepaymentDate: command.firstRepaymentDate,
      lastRepaymentDate: command.lastRepaymentDate,
      totalPeriods: command.totalPeriods,
    );
    final pendingDates = allDates.sublist(paidCount);

    // 剩余本金 = 总本金 − 已 paid 本金合计 − 已 extraPrincipal 合计
    final paidPrincipalMinor = paid.fold<int>(
      0,
      (acc, s) => acc + s.expectedPrincipal.minorUnits,
    );
    final extraPrincipalMinor =
        await _extraPrincipalSumMinor(command.contractId);
    final remainingMinor = contract.principal.minorUnits -
        paidPrincipalMinor -
        extraPrincipalMinor;
    if (remainingMinor < 0) {
      return const Result.failure(
        Failure(
          code: 'installment_principal_imbalance',
          message: 'Remaining principal would be negative.',
        ),
      );
    }

    // 剩余手续费：按 paid 行已分配的 fee 抵扣后剩余分配给 pending。
    final paidFeeMinor = paid.fold<int>(
      0,
      (acc, s) => acc + s.expectedFee.minorUnits,
    );
    final remainingFeeMinor = command.totalFeeMinor - paidFeeMinor;

    final anchorDate =
        paid.isEmpty ? contract.borrowingDate : paid.last.expectedRepaymentDate;

    final allocations = _generator.allocate(
      remainingPrincipal: Money(
        minorUnits: remainingMinor,
        currency: contract.principal.currency,
      ),
      anchorDate: anchorDate,
      pendingDates: pendingDates,
      method: command.repaymentMethod,
      ratePeriod: command.interestRatePeriod,
      ratePpm: command.interestRatePpm,
      remainingFeeMinor: remainingFeeMinor < 0 ? 0 : remainingFeeMinor,
    );

    // 取得 pending schedules 列表（与 dates 顺序一致），逐个 update。
    final pendingSchedules = schedules
        .where((s) => s.status == InstallmentScheduleStatus.pending)
        .toList()
      ..sort((a, b) => a.periodNo.compareTo(b.periodNo));

    // 处理期数变更：如果 totalPeriods 减少，需要 skip 多余 pending 行；
    // 如果增加，由于 schedules 表是按 periodNo 唯一标识的，需要补行。
    final desiredPendingCount = command.totalPeriods - paidCount;

    if (pendingSchedules.length > desiredPendingCount) {
      // 多余的 pending 行标记 skipped 并清零
      for (var i = desiredPendingCount; i < pendingSchedules.length; i++) {
        final s = pendingSchedules[i];
        await _repository.updateSchedule(
          s.id,
          InstallmentSchedulePatch(
            expectedPrincipal: Money.zero(currency: contract.principal.currency),
            expectedInterest: Money.zero(currency: contract.principal.currency),
            expectedFee: Money.zero(currency: contract.principal.currency),
            status: InstallmentScheduleStatus.skipped,
          ),
        );
      }
    }

    // 重写 schedule rows 的范围：min(existing, desired)
    final usableLen = pendingSchedules.length < desiredPendingCount
        ? pendingSchedules.length
        : desiredPendingCount;
    for (var i = 0; i < usableLen; i++) {
      final s = pendingSchedules[i];
      final alloc = allocations[i];
      final date = pendingDates[i];
      await _repository.updateSchedule(
        s.id,
        InstallmentSchedulePatch(
          expectedRepaymentDate: date,
          expectedPrincipal: alloc.principal,
          expectedInterest: alloc.interest,
          expectedFee: alloc.fee,
        ),
      );
    }
    // 期数增加 → 需要新增 pending 行；用 periodNo > 现有最大值的新行追加。
    // 简单实现：若需要新增，整体 replace pending 部分（保留 paid 行）。
    if (pendingSchedules.length < desiredPendingCount) {
      // 当前实现：rebuild 全表（paid 行金额保留，pending 行用新分配）。
      await _rebuildSchedulesPreservingPaid(
        contractId: command.contractId,
        contract: contract,
        paid: paid,
        pendingDates: pendingDates,
        allocations: allocations,
      );
    }

    // 应用手工 patch（限于 pending periodNo）。
    if (command.schedulePatches.isNotEmpty) {
      final refreshed = await _repository.listSchedules(command.contractId);
      final byPeriod = {for (final s in refreshed) s.periodNo: s};
      for (final patch in command.schedulePatches) {
        final target = byPeriod[patch.periodNo];
        if (target == null) continue;
        if (target.status != InstallmentScheduleStatus.pending) continue;
        await _repository.updateSchedule(
          target.id,
          InstallmentSchedulePatch(
            expectedPrincipal: patch.expectedPrincipal,
            expectedInterest: patch.expectedInterest,
            expectedFee: patch.expectedFee,
            expectedRepaymentDate: patch.expectedRepaymentDate,
          ),
        );
      }
    }

    // 更新合同字段。
    await _repository.updateContract(
      command.contractId,
      InstallmentContractPatch(
        totalPeriods: command.totalPeriods,
        firstRepaymentDate: command.firstRepaymentDate,
        lastRepaymentDate: command.lastRepaymentDate,
        repaymentMethod: command.repaymentMethod,
        interestRatePeriod: command.interestRatePeriod,
        interestRatePpm: command.interestRatePpm,
        totalFeeMinor: command.totalFeeMinor,
        note: command.note,
        clearNote: command.clearNote,
        clearRate:
            command.interestRatePeriod == null && command.interestRatePpm == null,
      ),
    );

    return const Result.success(null);
  }

  @override
  Future<Result<PostTransactionResult>> createRegularRepayment(
    CreateRegularRepaymentCommand command,
  ) async {
    final contract = await _repository.findContract(command.contractId);
    if (contract == null) {
      return const Result.failure(
        Failure(
          code: 'installment_contract_not_found',
          message: 'Installment contract does not exist.',
        ),
      );
    }
    final schedule = await _repository.findSchedule(command.scheduleId);
    if (schedule == null || schedule.contractId != command.contractId) {
      return const Result.failure(
        Failure(
          code: 'installment_schedule_not_found',
          message: 'Schedule does not belong to the contract.',
        ),
      );
    }
    if (schedule.status != InstallmentScheduleStatus.pending) {
      return const Result.failure(
        Failure(
          code: 'installment_schedule_not_pending',
          message: 'Schedule is not pending.',
        ),
      );
    }

    final result = await _transactionService.createRepayment(
      CreateRepaymentCommand(
        principal: command.principal,
        interest: command.interest,
        fee: command.fee,
        discount: command.discount,
        liabilityAccountId: contract.liabilityAccountId,
        paidFromAccountId: command.paidFromAccountId,
        interestExpenseAccountId: command.interestExpenseAccountId,
        feeExpenseAccountId: command.feeExpenseAccountId,
        occurredAt: command.occurredAt,
        counterpartyName: command.counterpartyName,
        note: command.note,
      ),
    );
    return result.when(
      failure: Result.failure,
      success: (post) async {
        await _repository.insertRepayment(
          InstallmentRepaymentDraft(
            contractId: command.contractId,
            repaymentType: InstallmentRepaymentType.regular,
            scheduleId: command.scheduleId,
            transactionId: post.transactionId,
          ),
        );
        await _repository.updateSchedule(
          command.scheduleId,
          const InstallmentSchedulePatch(
            status: InstallmentScheduleStatus.paid,
          ),
        );
        await _maybeMarkContractSettled(command.contractId);
        return Result.success(post);
      },
    );
  }

  @override
  Future<Result<PostTransactionResult>> createExtraPrincipalRepayment(
    CreateExtraPrincipalRepaymentCommand command,
  ) async {
    final contract = await _repository.findContract(command.contractId);
    if (contract == null) {
      return const Result.failure(
        Failure(
          code: 'installment_contract_not_found',
          message: 'Installment contract does not exist.',
        ),
      );
    }
    if (contract.status != InstallmentContractStatus.active) {
      return const Result.failure(
        Failure(
          code: 'installment_contract_not_active',
          message: 'Only active contracts allow extra principal repayment.',
        ),
      );
    }

    final result = await _transactionService.createRepayment(
      CreateRepaymentCommand(
        principal: command.principal,
        interest: command.interest,
        fee: command.fee,
        liabilityAccountId: contract.liabilityAccountId,
        paidFromAccountId: command.paidFromAccountId,
        interestExpenseAccountId: command.interestExpenseAccountId,
        feeExpenseAccountId: command.feeExpenseAccountId,
        occurredAt: command.occurredAt,
        counterpartyName: command.counterpartyName,
        note: command.note,
      ),
    );
    return result.when(
      failure: Result.failure,
      success: (post) async {
        await _repository.insertRepayment(
          InstallmentRepaymentDraft(
            contractId: command.contractId,
            repaymentType: InstallmentRepaymentType.extraPrincipal,
            transactionId: post.transactionId,
          ),
        );
        await _recalculatePendingSchedules(command.contractId);
        return Result.success(post);
      },
    );
  }

  @override
  Future<Result<PostTransactionResult>> createEarlySettlement(
    CreateEarlySettlementCommand command,
  ) async {
    final contract = await _repository.findContract(command.contractId);
    if (contract == null) {
      return const Result.failure(
        Failure(
          code: 'installment_contract_not_found',
          message: 'Installment contract does not exist.',
        ),
      );
    }
    if (contract.status != InstallmentContractStatus.active) {
      return const Result.failure(
        Failure(
          code: 'installment_contract_not_active',
          message: 'Only active contracts can be settled early.',
        ),
      );
    }

    final result = await _transactionService.createRepayment(
      CreateRepaymentCommand(
        principal: command.principal,
        interest: command.interest,
        fee: command.fee,
        liabilityAccountId: contract.liabilityAccountId,
        paidFromAccountId: command.paidFromAccountId,
        interestExpenseAccountId: command.interestExpenseAccountId,
        feeExpenseAccountId: command.feeExpenseAccountId,
        occurredAt: command.occurredAt,
        counterpartyName: command.counterpartyName,
        note: command.note,
      ),
    );
    return result.when(
      failure: Result.failure,
      success: (post) async {
        await _repository.insertRepayment(
          InstallmentRepaymentDraft(
            contractId: command.contractId,
            repaymentType: InstallmentRepaymentType.earlySettlement,
            transactionId: post.transactionId,
          ),
        );
        final schedules =
            await _repository.listSchedules(command.contractId);
        for (final s in schedules) {
          if (s.status == InstallmentScheduleStatus.pending) {
            await _repository.updateSchedule(
              s.id,
              const InstallmentSchedulePatch(
                status: InstallmentScheduleStatus.skipped,
              ),
            );
          }
        }
        await _repository.updateContractStatus(
          command.contractId,
          InstallmentContractStatus.closed,
        );
        return Result.success(post);
      },
    );
  }

  @override
  Future<Result<void>> revertRepayment(RevertRepaymentCommand command) async {
    final repayment =
        await _repository.findRepaymentByTransaction(command.transactionId);
    if (repayment == null) {
      return const Result.failure(
        Failure(
          code: 'installment_repayment_not_found',
          message: 'No installment repayment is linked to this transaction.',
        ),
      );
    }

    final deleteResult = await _transactionService.deleteTransaction(
      DeleteTransactionCommand(transactionId: command.transactionId),
    );
    return deleteResult.when(
      failure: Result.failure,
      success: (_) async {
        await _repository.deleteRepayment(repayment.id);
        switch (repayment.repaymentType) {
          case InstallmentRepaymentType.regular:
            if (repayment.scheduleId != null) {
              await _repository.updateSchedule(
                repayment.scheduleId!,
                const InstallmentSchedulePatch(
                  status: InstallmentScheduleStatus.pending,
                ),
              );
            }
            await _maybeUnmarkContractSettled(repayment.contractId);
          case InstallmentRepaymentType.extraPrincipal:
            await _recalculatePendingSchedules(repayment.contractId);
          case InstallmentRepaymentType.earlySettlement:
            final schedules =
                await _repository.listSchedules(repayment.contractId);
            for (final s in schedules) {
              if (s.status == InstallmentScheduleStatus.skipped) {
                await _repository.updateSchedule(
                  s.id,
                  const InstallmentSchedulePatch(
                    status: InstallmentScheduleStatus.pending,
                  ),
                );
              }
            }
            await _repository.updateContractStatus(
              repayment.contractId,
              InstallmentContractStatus.active,
            );
        }
        return const Result.success(null);
      },
    );
  }

  @override
  Future<List<InstallmentContract>> listContractsByLiabilityAccount(
    int liabilityAccountId,
  ) {
    return _repository.listContractsByLiabilityAccount(liabilityAccountId);
  }

  @override
  Future<InstallmentContract?> findContract(int contractId) {
    return _repository.findContract(contractId);
  }

  @override
  Future<List<InstallmentSchedule>> listSchedules(int contractId) {
    return _repository.listSchedules(contractId);
  }

  @override
  Future<List<InstallmentRepayment>> listRepayments(int contractId) {
    return _repository.listRepayments(contractId);
  }

  Future<void> _maybeMarkContractSettled(int contractId) async {
    final schedules = await _repository.listSchedules(contractId);
    final allDone = schedules.every(
      (s) =>
          s.status == InstallmentScheduleStatus.paid ||
          s.status == InstallmentScheduleStatus.skipped,
    );
    if (allDone && schedules.isNotEmpty) {
      await _repository.updateContractStatus(
        contractId,
        InstallmentContractStatus.settled,
      );
    }
  }

  Future<void> _maybeUnmarkContractSettled(int contractId) async {
    final contract = await _repository.findContract(contractId);
    if (contract == null) return;
    if (contract.status == InstallmentContractStatus.settled) {
      await _repository.updateContractStatus(
        contractId,
        InstallmentContractStatus.active,
      );
    }
  }

  /// 重算 pending 期次的金额（日期保持不变）。提前还本 / 撤销提前还本时调用。
  Future<void> _recalculatePendingSchedules(int contractId) async {
    final contract = await _repository.findContract(contractId);
    if (contract == null) return;

    final schedules = await _repository.listSchedules(contractId);
    final paid = schedules
        .where((s) => s.status == InstallmentScheduleStatus.paid)
        .toList()
      ..sort((a, b) => a.periodNo.compareTo(b.periodNo));
    final pending = schedules
        .where((s) => s.status == InstallmentScheduleStatus.pending)
        .toList()
      ..sort((a, b) => a.periodNo.compareTo(b.periodNo));
    if (pending.isEmpty) return;

    final paidPrincipalMinor = paid.fold<int>(
      0,
      (acc, s) => acc + s.expectedPrincipal.minorUnits,
    );
    final extraPrincipalMinor = await _extraPrincipalSumMinor(contractId);
    final remainingMinor = contract.principal.minorUnits -
        paidPrincipalMinor -
        extraPrincipalMinor;

    if (remainingMinor <= 0) {
      // 剩余本金归零 → pending 行清零并标 skipped。
      for (final s in pending) {
        await _repository.updateSchedule(
          s.id,
          InstallmentSchedulePatch(
            expectedPrincipal: Money.zero(currency: contract.principal.currency),
            expectedInterest: Money.zero(currency: contract.principal.currency),
            expectedFee: Money.zero(currency: contract.principal.currency),
            status: InstallmentScheduleStatus.skipped,
          ),
        );
      }
      return;
    }

    final paidFeeMinor = paid.fold<int>(
      0,
      (acc, s) => acc + s.expectedFee.minorUnits,
    );
    final remainingFeeMinor = contract.totalFeeMinor - paidFeeMinor;
    final anchorDate =
        paid.isEmpty ? contract.borrowingDate : paid.last.expectedRepaymentDate;

    final allocations = _generator.allocate(
      remainingPrincipal: Money(
        minorUnits: remainingMinor,
        currency: contract.principal.currency,
      ),
      anchorDate: anchorDate,
      pendingDates: [for (final p in pending) p.expectedRepaymentDate],
      method: contract.repaymentMethod,
      ratePeriod: contract.interestRatePeriod,
      ratePpm: contract.interestRatePpm,
      remainingFeeMinor: remainingFeeMinor < 0 ? 0 : remainingFeeMinor,
    );
    for (var i = 0; i < pending.length; i++) {
      final s = pending[i];
      final a = allocations[i];
      await _repository.updateSchedule(
        s.id,
        InstallmentSchedulePatch(
          expectedPrincipal: a.principal,
          expectedInterest: a.interest,
          expectedFee: a.fee,
        ),
      );
    }
  }

  /// 当 totalPeriods 增加导致 pending 行不足时，按 paid 不变 + pending 全新分配
  /// 来重建 schedule 表。
  Future<void> _rebuildSchedulesPreservingPaid({
    required int contractId,
    required InstallmentContract contract,
    required List<InstallmentSchedule> paid,
    required List<DateTime> pendingDates,
    required List<InstallmentAmountAllocation> allocations,
  }) async {
    final drafts = <InstallmentScheduleDraft>[];
    for (var i = 0; i < paid.length; i++) {
      final s = paid[i];
      drafts.add(
        InstallmentScheduleDraft(
          periodNo: i + 1,
          expectedRepaymentDate: s.expectedRepaymentDate,
          expectedPrincipal: s.expectedPrincipal,
          expectedInterest: s.expectedInterest,
          expectedFee: s.expectedFee,
        ),
      );
    }
    for (var i = 0; i < pendingDates.length; i++) {
      drafts.add(
        InstallmentScheduleDraft(
          periodNo: paid.length + i + 1,
          expectedRepaymentDate: pendingDates[i],
          expectedPrincipal: allocations[i].principal,
          expectedInterest: allocations[i].interest,
          expectedFee: allocations[i].fee,
        ),
      );
    }
    // replaceSchedules 会先删后插，paid 行需要重新建立和 paid repayment 的关联：
    // 由于 installment_repayments.schedule_id 引用 schedule 的旧 id，
    // 删除会破坏关联。这里采用渐进式 update + insert 而不是 replace。
    // (TODO: 真正的期数增加场景较少且属编辑高级用法；当前实现先保证 paid 不变。)
    // 简化：对已 paid 部分跳过插入，仅追加 pending 行。
    final existingSchedules = await _repository.listSchedules(contractId);
    final maxPeriodNo = existingSchedules.isEmpty
        ? 0
        : existingSchedules.map((s) => s.periodNo).reduce((a, b) => a > b ? a : b);
    // 计算需要补几行
    final desiredPending = pendingDates.length;
    final existingPending = existingSchedules
        .where((s) => s.status == InstallmentScheduleStatus.pending)
        .length;
    final toAdd = desiredPending - existingPending;
    if (toAdd <= 0) return;
    final newDrafts = <InstallmentScheduleDraft>[];
    for (var i = 0; i < toAdd; i++) {
      final allocIdx = existingPending + i;
      newDrafts.add(
        InstallmentScheduleDraft(
          periodNo: maxPeriodNo + i + 1,
          expectedRepaymentDate: pendingDates[allocIdx],
          expectedPrincipal: allocations[allocIdx].principal,
          expectedInterest: allocations[allocIdx].interest,
          expectedFee: allocations[allocIdx].fee,
        ),
      );
    }
    // 用 repository 的批量插入能力 — 改 repository 暴露 appendSchedules。
    await _repository.appendSchedules(contractId, newDrafts);
  }

  Future<int> _extraPrincipalSumMinor(int contractId) async {
    final repayments = await _repository.listRepayments(contractId);
    var sum = 0;
    for (final r in repayments) {
      if (r.repaymentType != InstallmentRepaymentType.extraPrincipal) continue;
      final view =
          await _queryRepository.watchTransactionDetail(r.transactionId).first;
      if (view == null) continue;
      for (final d in view.details) {
        if (d.type == TransactionDetailType.repaymentPrincipal) {
          sum += d.amount.minorUnits;
        }
      }
    }
    return sum;
  }

  Failure? _validateCreate({
    required Money principal,
    required int totalPeriods,
    required DateTime firstRepaymentDate,
    DateTime? lastRepaymentDate,
  }) {
    if (principal.minorUnits <= 0) {
      return const Failure(
        code: 'installment_principal_not_positive',
        message: 'Installment principal must be positive.',
      );
    }
    if (totalPeriods <= 0) {
      return const Failure(
        code: 'installment_total_periods_invalid',
        message: 'Total periods must be greater than zero.',
      );
    }
    if (lastRepaymentDate != null &&
        totalPeriods > 1 &&
        !lastRepaymentDate.isAfter(firstRepaymentDate)) {
      return const Failure(
        code: 'installment_dates_invalid',
        message: 'Last repayment date must be after first.',
      );
    }
    return null;
  }

  DateTime _defaultLastDate(DateTime firstDate, int totalPeriods) {
    return DateTime(
      firstDate.year,
      firstDate.month + totalPeriods - 1,
      firstDate.day,
    );
  }
}
