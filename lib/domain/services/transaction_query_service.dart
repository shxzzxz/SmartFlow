import '../../core/money/money.dart';
import '../entities/transaction.dart';
import '../enums/accounting_enums.dart';
import '../repositories/transaction_query_repository.dart';

abstract interface class TransactionQueryService {
  Stream<List<TransactionListItem>> watchTransactions(
    TransactionListQuery query,
  );

  Stream<CashflowSummary> watchCashflowSummary(CashflowSummaryQuery query);

  Stream<TransactionDetailView?> watchTransactionDetail(int transactionId);

  Future<Transaction?> findTransactionById(int transactionId);

  Future<Money> getRefundedTotal(int rootTransactionId, {String currencyCode});

  Future<ReimbursementSummary?> getReimbursementSummary(int rootTransactionId);
}

class TransactionQueryServiceImpl implements TransactionQueryService {
  const TransactionQueryServiceImpl(this._repository);

  final TransactionQueryRepository _repository;

  @override
  Stream<List<TransactionListItem>> watchTransactions(
    TransactionListQuery query,
  ) {
    return _repository.watchTransactions(query);
  }

  @override
  Stream<CashflowSummary> watchCashflowSummary(CashflowSummaryQuery query) {
    return _repository.watchCashflowSummary(query);
  }

  @override
  Stream<TransactionDetailView?> watchTransactionDetail(int transactionId) {
    return _repository.watchTransactionDetail(transactionId);
  }

  @override
  Future<Transaction?> findTransactionById(int transactionId) {
    return _repository.findTransactionById(transactionId);
  }

  @override
  Future<Money> getRefundedTotal(
    int rootTransactionId, {
    String currencyCode = Money.defaultCurrency,
  }) {
    return _repository.getRefundedTotal(
      rootTransactionId,
      currencyCode: currencyCode,
    );
  }

  @override
  Future<ReimbursementSummary?> getReimbursementSummary(int rootTransactionId) {
    return _repository.getReimbursementSummary(rootTransactionId);
  }
}

class TransactionListQuery {
  const TransactionListQuery({
    this.accountId,
    this.topLevelOnly = true,
    this.occurredFrom,
    this.occurredUntil,
    this.limit = 100,
    this.offset = 0,
  });

  final int? accountId;
  final bool topLevelOnly;

  /// 包含下界。
  final DateTime? occurredFrom;

  /// 不包含上界（半开区间），便于按月份切片。
  final DateTime? occurredUntil;
  final int limit;
  final int offset;
}

class CashflowSummaryQuery {
  const CashflowSummaryQuery({
    required this.occurredFrom,
    required this.occurredUntil,
    this.currencyCode = Money.defaultCurrency,
  });

  /// 包含下界。
  final DateTime occurredFrom;

  /// 不包含上界（半开区间），便于按月份切片。
  final DateTime occurredUntil;
  final String currencyCode;
}

class CashflowSummary {
  const CashflowSummary({required this.income, required this.expense});

  final Money income;
  final Money expense;

  Money get net => income - expense;
}

/// 首页 / 流水页消费的主交易行视图。
///
/// 子交易（退款、报销到账、结束报销）不再作为独立行出现，而是聚合到这里
/// 由对应主交易行通过 badge 表达。详情仍可在交易详情页查看。
class TransactionListItem {
  const TransactionListItem({
    required this.id,
    required this.businessPurpose,
    required this.occurredAt,
    required this.primaryAmount,
    required this.accountNames,
    required this.isExcludedFromStats,
    required this.isExcludedFromBudget,
    this.categoryName,
    this.categoryIconKey,
    this.flowOutAccountId,
    this.flowInAccountId,
    this.flowOutAccountName,
    this.flowInAccountName,
    this.counterpartyName,
    this.note,
    this.refundedTotal,
    this.refundChildCount = 0,
    this.reimbursementReceivedTotal,
    this.reimbursementChildCount = 0,
    this.reimbursementGapIncome,
    this.reimbursementGapExpense,
    this.repaymentInterest,
    this.repaymentFee,
  });

  final int id;
  final BusinessPurpose businessPurpose;
  final DateTime occurredAt;
  final Money primaryAmount;
  final String accountNames;
  final String? categoryName;
  final String? categoryIconKey;
  final int? flowOutAccountId;
  final int? flowInAccountId;
  final String? flowOutAccountName;
  final String? flowInAccountName;
  final String? counterpartyName;
  final String? note;

  /// 该主交易是否标记为不计入收支统计。
  final bool isExcludedFromStats;

  /// 该主交易是否标记为不计入预算。
  final bool isExcludedFromBudget;

  /// 该主交易下退款子交易（business_purpose = refund）的累计金额；
  /// 仅普通支出可能非空。
  final Money? refundedTotal;
  final int refundChildCount;

  /// 该主交易下报销到账 + 结束报销子交易的累计金额；
  /// 仅报销垫付可能非空。
  final Money? reimbursementReceivedTotal;
  final int reimbursementChildCount;

  /// 报销结束子交易携带的"差额收入"（公司多给）合计，仅报销垫付可能非空。
  final Money? reimbursementGapIncome;

  /// 报销结束子交易携带的"差额支出"（公司少给）合计，仅报销垫付可能非空。
  final Money? reimbursementGapExpense;

  /// 还款主交易的利息分项合计，仅还款可能非空。
  final Money? repaymentInterest;

  /// 还款主交易的手续费分项合计，仅还款可能非空。
  final Money? repaymentFee;
}

class TransactionDetailView {
  const TransactionDetailView({
    required this.transaction,
    required this.details,
    required this.entries,
    this.children = const [],
    this.refundedTotal,
    this.reimbursementSummary,
  });

  final Transaction transaction;
  final List<TransactionDetailLineView> details;
  final List<EntryLineView> entries;
  final List<TransactionListItem> children;
  final Money? refundedTotal;
  final ReimbursementSummary? reimbursementSummary;
}

class TransactionDetailLineView {
  const TransactionDetailLineView({
    required this.lineNo,
    required this.type,
    required this.amount,
  });

  final int lineNo;
  final TransactionDetailType type;
  final Money amount;
}

class EntryLineView {
  const EntryLineView({
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.direction,
    required this.amount,
  });

  final int accountId;
  final String accountName;
  final AccountType accountType;
  final EntryDirection direction;
  final Money amount;
}

class ReimbursementSummary {
  const ReimbursementSummary({
    required this.advanceAmount,
    required this.receivedAmount,
    required this.outstanding,
    required this.isClosed,
  });

  final Money advanceAmount;
  final Money receivedAmount;
  final Money outstanding;
  final bool isClosed;
}
