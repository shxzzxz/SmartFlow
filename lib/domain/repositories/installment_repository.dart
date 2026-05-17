import '../../core/money/money.dart';
import '../entities/installment_contract.dart';
import '../entities/installment_repayment.dart';
import '../entities/installment_schedule.dart';
import '../enums/accounting_enums.dart';
import '../services/installment_schedule_generator.dart';

class InstallmentContractDraft {
  const InstallmentContractDraft({
    required this.liabilityAccountId,
    required this.sourceType,
    required this.principal,
    required this.totalPeriods,
    required this.startDate,
    required this.repaymentMethod,
    required this.status,
    this.disbursementAccountId,
    this.disbursementTransactionId,
    this.interestRatePeriod,
    this.interestRatePpm,
    this.note,
  });

  final int liabilityAccountId;
  final InstallmentSourceType sourceType;
  final int? disbursementAccountId;
  final int? disbursementTransactionId;
  final Money principal;
  final int totalPeriods;
  final DateTime startDate;
  final InstallmentRepaymentMethod repaymentMethod;
  final InterestRatePeriod? interestRatePeriod;
  final int? interestRatePpm;
  final InstallmentContractStatus status;
  final String? note;
}

class InstallmentSchedulePatch {
  const InstallmentSchedulePatch({
    this.expectedRepaymentDate,
    this.expectedPrincipal,
    this.expectedInterest,
    this.expectedFee,
    this.status,
    this.note,
    this.clearNote = false,
  });

  final DateTime? expectedRepaymentDate;
  final Money? expectedPrincipal;
  final Money? expectedInterest;
  final Money? expectedFee;
  final InstallmentScheduleStatus? status;
  final String? note;
  final bool clearNote;
}

class InstallmentRepaymentDraft {
  const InstallmentRepaymentDraft({
    required this.contractId,
    required this.repaymentType,
    required this.transactionId,
    this.scheduleId,
  });

  final int contractId;
  final InstallmentRepaymentType repaymentType;
  final int? scheduleId;
  final int transactionId;
}

abstract interface class InstallmentRepository {
  Future<InstallmentContract?> findContract(int id);

  Future<List<InstallmentContract>> listContractsByLiabilityAccount(
    int liabilityAccountId,
  );

  Future<List<InstallmentSchedule>> listSchedules(int contractId);

  Future<InstallmentSchedule?> findSchedule(int scheduleId);

  Future<List<InstallmentRepayment>> listRepayments(int contractId);

  Future<InstallmentRepayment?> findRepaymentByTransaction(int transactionId);

  Future<int> insertContract(InstallmentContractDraft draft);

  Future<void> replaceSchedules(
    int contractId,
    List<InstallmentScheduleDraft> drafts,
  );

  Future<void> updateSchedule(int scheduleId, InstallmentSchedulePatch patch);

  Future<int> insertRepayment(InstallmentRepaymentDraft draft);

  Future<void> deleteRepayment(int repaymentId);

  Future<void> updateContractStatus(
    int contractId,
    InstallmentContractStatus status,
  );
}
