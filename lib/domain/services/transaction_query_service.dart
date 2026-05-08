import '../../core/money/money.dart';
import '../entities/transaction.dart';
import '../enums/accounting_enums.dart';
import '../repositories/transaction_query_repository.dart';

abstract interface class TransactionQueryService {
  Stream<List<TransactionListItem>> watchTransactions(
    TransactionListQuery query,
  );

  Stream<TransactionDetailView?> watchTransactionDetail(int transactionId);
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
  Stream<TransactionDetailView?> watchTransactionDetail(int transactionId) {
    return _repository.watchTransactionDetail(transactionId);
  }
}

class TransactionListQuery {
  const TransactionListQuery({
    this.accountId,
    this.limit = 100,
    this.offset = 0,
  });

  final int? accountId;
  final int limit;
  final int offset;
}

class TransactionListItem {
  const TransactionListItem({
    required this.id,
    required this.businessPurpose,
    required this.occurredAt,
    required this.primaryAmount,
    required this.accountNames,
    this.categoryName,
    this.flowOutAccountName,
    this.flowInAccountName,
    this.counterpartyName,
    this.note,
  });

  final int id;
  final BusinessPurpose businessPurpose;
  final DateTime occurredAt;
  final Money primaryAmount;
  final String accountNames;
  final String? categoryName;
  final String? flowOutAccountName;
  final String? flowInAccountName;
  final String? counterpartyName;
  final String? note;
}

class TransactionDetailView {
  const TransactionDetailView({
    required this.transaction,
    required this.details,
    required this.entries,
  });

  final Transaction transaction;
  final List<TransactionDetailLineView> details;
  final List<EntryLineView> entries;
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
