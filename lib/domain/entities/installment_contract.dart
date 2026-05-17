import '../../core/money/money.dart';
import '../enums/accounting_enums.dart';

class InstallmentContract {
  const InstallmentContract({
    required this.id,
    required this.liabilityAccountId,
    required this.sourceType,
    required this.principal,
    required this.totalPeriods,
    required this.startDate,
    required this.repaymentMethod,
    required this.status,
    required this.createdAt,
    this.disbursementAccountId,
    this.disbursementTransactionId,
    this.interestRatePeriod,
    this.interestRatePpm,
    this.note,
  });

  final int id;
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
  final DateTime createdAt;
}
