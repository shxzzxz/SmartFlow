import '../../core/money/money.dart';
import '../enums/accounting_enums.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.rootTransactionId,
    required this.businessPurpose,
    required this.occurredAt,
    required this.currencyCode,
    required this.primaryAmount,
    required this.mutationKind,
    required this.businessState,
    required this.isExcludedFromStats,
    required this.isExcludedFromBudget,
    required this.sourceKind,
    this.counterpartyName,
    this.note,
    this.parentTransactionId,
    this.reimbursementExpenseAccountId,
    this.mutationPreviousTransactionId,
    this.mutationReason,
  });

  final int id;
  final int rootTransactionId;
  final BusinessPurpose businessPurpose;
  final DateTime occurredAt;
  final String currencyCode;
  final Money primaryAmount;
  final String? counterpartyName;
  final String? note;
  final int? parentTransactionId;
  final int? reimbursementExpenseAccountId;
  final MutationKind mutationKind;
  final int? mutationPreviousTransactionId;
  final MutationReason? mutationReason;
  final BusinessState businessState;
  final bool isExcludedFromStats;
  final bool isExcludedFromBudget;
  final SourceKind sourceKind;
}
