import '../../core/money/money.dart';
import '../enums/accounting_enums.dart';

class PostTransactionCommand {
  const PostTransactionCommand({
    required this.businessPurpose,
    required this.occurredAt,
    required this.primaryAmount,
    required this.details,
    required this.entries,
    this.currencyCode = Money.defaultCurrency,
    this.rootTransactionId,
    this.counterpartyName,
    this.note,
    this.parentTransactionId,
    this.reimbursementExpenseAccountId,
    this.mutationKind = MutationKind.original,
    this.mutationPreviousTransactionId,
    this.mutationReason,
    this.businessState = BusinessState.current,
    this.isExcludedFromStats = false,
    this.isExcludedFromBudget = false,
    this.sourceKind = SourceKind.manual,
  });

  final BusinessPurpose businessPurpose;
  final DateTime occurredAt;
  final String currencyCode;
  final Money primaryAmount;
  final List<PostTransactionDetailInput> details;
  final List<PostEntryInput> entries;
  final int? rootTransactionId;
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

class PostTransactionDetailInput {
  const PostTransactionDetailInput({
    required this.lineNo,
    required this.type,
    required this.amount,
  });

  final int lineNo;
  final TransactionDetailType type;
  final Money amount;
}

class PostEntryInput {
  const PostEntryInput({
    required this.accountId,
    required this.direction,
    required this.amount,
  });

  final int accountId;
  final EntryDirection direction;
  final Money amount;
}

class PostTransactionResult {
  const PostTransactionResult({
    required this.transactionId,
    required this.rootTransactionId,
  });

  final int transactionId;
  final int rootTransactionId;
}
