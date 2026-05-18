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
    required this.borrowingDate,
    required this.firstRepaymentDate,
    required this.lastRepaymentDate,
    required this.repaymentMethod,
    required this.interestAccrualMethod,
    required this.status,
    this.disbursementAccountId,
    this.disbursementTransactionId,
    this.interestRatePeriod,
    this.interestRatePpm,
    this.totalFeeMinor = 0,
    this.note,
  });

  final int liabilityAccountId;
  final InstallmentSourceType sourceType;
  final int? disbursementAccountId;
  final int? disbursementTransactionId;
  final Money principal;
  final int totalPeriods;
  final DateTime borrowingDate;
  final DateTime firstRepaymentDate;
  final DateTime lastRepaymentDate;
  final InstallmentRepaymentMethod repaymentMethod;
  final InterestRatePeriod? interestRatePeriod;
  final int? interestRatePpm;
  final InterestAccrualMethod interestAccrualMethod;
  final int totalFeeMinor;
  final InstallmentContractStatus status;
  final String? note;
}

/// 合同字段编辑补丁，仅包含可变字段。
/// 借款日期、source、放款交易等不可改字段不在此列。
class InstallmentContractPatch {
  const InstallmentContractPatch({
    this.totalPeriods,
    this.firstRepaymentDate,
    this.lastRepaymentDate,
    this.repaymentMethod,
    this.interestRatePeriod,
    this.interestRatePpm,
    this.interestAccrualMethod,
    this.totalFeeMinor,
    this.note,
    this.clearRate = false,
    this.clearNote = false,
  });

  final int? totalPeriods;
  final DateTime? firstRepaymentDate;
  final DateTime? lastRepaymentDate;
  final InstallmentRepaymentMethod? repaymentMethod;
  final InterestRatePeriod? interestRatePeriod;
  final int? interestRatePpm;
  final InterestAccrualMethod? interestAccrualMethod;
  final int? totalFeeMinor;
  final String? note;

  /// 设为 true 时清空利率字段（period + ppm 都置空）。
  final bool clearRate;
  final bool clearNote;
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

  /// 反查：transaction 是否为某合同的放款交易；若是返回该合同，否则返回 null。
  /// 仅 `sourceType == disbursement` 的合同会命中。
  Future<InstallmentContract?> findContractByDisbursementTransaction(
    int transactionId,
  );

  Future<int> insertContract(InstallmentContractDraft draft);

  Future<void> updateContract(int contractId, InstallmentContractPatch patch);

  Future<void> replaceSchedules(
    int contractId,
    List<InstallmentScheduleDraft> drafts,
  );

  /// 追加 pending 期次行（不动现有 schedule 行）。
  /// drafts 中的 periodNo 由调用方负责，保证全表 periodNo 唯一。
  Future<void> appendSchedules(
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

  /// 物理删除合同：连同 schedules 与 repayments 一并清理。
  /// 调用方负责先把对应的放款 / 还款交易撤回，本方法不动 transactions 表。
  Future<void> deleteContract(int contractId);
}
