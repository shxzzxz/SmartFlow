import '../services/transaction_query_service.dart';

abstract interface class TransactionQueryRepository {
  Stream<List<TransactionListItem>> watchTransactions(
    TransactionListQuery query,
  );

  Stream<TransactionDetailView?> watchTransactionDetail(int transactionId);
}
