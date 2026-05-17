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
    required this.startDate,
    required this.repaymentMethod,
    required this.occurredAt,
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
  final DateTime startDate;
  final InstallmentRepaymentMethod repaymentMethod;
  final InterestRatePeriod? interestRatePeriod;
  final int? interestRatePpm;
  final int totalFeeMinor;
  final DateTime occurredAt;
  final String? note;
  final String? counterpartyName;
}

class CreateBillConversionContractCommand {
  const CreateBillConversionContractCommand({
    required this.liabilityAccountId,
    required this.principal,
    required this.totalPeriods,
    required this.startDate,
    required this.repaymentMethod,
    this.interestRatePeriod,
    this.interestRatePpm,
    this.totalFeeMinor = 0,
    this.note,
  });

  final int liabilityAccountId;
  final Money principal;
  final int totalPeriods;
  final DateTime startDate;
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
    this.fee,
    this.feeExpenseAccountId,
    this.note,
    this.counterpartyName,
  });

  final int contractId;
  final Money principal;
  final Money? fee;
  final int paidFromAccountId;
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
    if (command.principal.minorUnits <= 0) {
      return const Result.failure(
        Failure(
          code: 'installment_principal_not_positive',
          message: 'Installment principal must be positive.',
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

    final borrowingResult = await _transactionService.createBorrowing(
      CreateBorrowingCommand(
        amount: command.principal,
        liabilityAccountId: command.liabilityAccountId,
        occurredAt: command.occurredAt,
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
          totalPeriods: command.totalPeriods,
          startDate: command.startDate,
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
            startDate: command.startDate,
            repaymentMethod: command.repaymentMethod,
            interestRatePeriod: command.interestRatePeriod,
            interestRatePpm: command.interestRatePpm,
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
    if (command.principal.minorUnits <= 0) {
      return const Result.failure(
        Failure(
          code: 'installment_principal_not_positive',
          message: 'Installment principal must be positive.',
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

    final drafts = _generator.generate(
      principal: command.principal,
      totalPeriods: command.totalPeriods,
      startDate: command.startDate,
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
        startDate: command.startDate,
        repaymentMethod: command.repaymentMethod,
        interestRatePeriod: command.interestRatePeriod,
        interestRatePpm: command.interestRatePpm,
        status: InstallmentContractStatus.active,
        note: command.note,
      ),
    );
    await _repository.replaceSchedules(contractId, drafts);
    return Result.success(CreateContractResult(contractId: contractId));
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
        fee: command.fee,
        liabilityAccountId: contract.liabilityAccountId,
        paidFromAccountId: command.paidFromAccountId,
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

  /// 重算所有 PENDING 期次的金额，PAID / SKIPPED 行不动。
  Future<void> _recalculatePendingSchedules(int contractId) async {
    final contract = await _repository.findContract(contractId);
    if (contract == null) return;

    final schedules = await _repository.listSchedules(contractId);
    final paidPrincipalSum = schedules
        .where((s) => s.status == InstallmentScheduleStatus.paid)
        .fold<int>(0, (acc, s) => acc + s.expectedPrincipal.minorUnits);
    final paidCount = schedules
        .where((s) => s.status == InstallmentScheduleStatus.paid)
        .length;

    final repayments = await _repository.listRepayments(contractId);
    var extraPrincipalSum = 0;
    for (final r in repayments) {
      if (r.repaymentType == InstallmentRepaymentType.extraPrincipal) {
        final view =
            await _queryRepository.watchTransactionDetail(r.transactionId).first;
        if (view == null) continue;
        for (final d in view.details) {
          if (d.type == TransactionDetailType.repaymentPrincipal) {
            extraPrincipalSum += d.amount.minorUnits;
          }
        }
      }
    }

    final remainingPrincipalMinor =
        contract.principal.minorUnits - paidPrincipalSum - extraPrincipalSum;
    final remainingPeriods = contract.totalPeriods - paidCount;

    if (remainingPeriods <= 0 || remainingPrincipalMinor <= 0) {
      // 剩余本金已被还清 / 期数已用满，剩余 PENDING 行金额清零并标记 SKIPPED
      for (final s in schedules) {
        if (s.status == InstallmentScheduleStatus.pending) {
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
      return;
    }

    final newDrafts = _generator.generate(
      principal: Money(
        minorUnits: remainingPrincipalMinor,
        currency: contract.principal.currency,
      ),
      totalPeriods: remainingPeriods,
      startDate: contract.startDate,
      method: contract.repaymentMethod,
      ratePeriod: contract.interestRatePeriod,
      ratePpm: contract.interestRatePpm,
    );

    final pendingSchedules = schedules
        .where((s) => s.status == InstallmentScheduleStatus.pending)
        .toList()
      ..sort((a, b) => a.periodNo.compareTo(b.periodNo));

    final count = pendingSchedules.length < newDrafts.length
        ? pendingSchedules.length
        : newDrafts.length;
    for (var i = 0; i < count; i++) {
      final schedule = pendingSchedules[i];
      final draft = newDrafts[i];
      await _repository.updateSchedule(
        schedule.id,
        InstallmentSchedulePatch(
          expectedPrincipal: draft.expectedPrincipal,
          expectedInterest: draft.expectedInterest,
          expectedFee: draft.expectedFee,
        ),
      );
    }
  }
}
