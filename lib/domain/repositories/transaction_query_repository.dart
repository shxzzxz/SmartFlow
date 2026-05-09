import '../../core/money/money.dart';
import '../entities/transaction.dart';
import '../services/transaction_query_service.dart';

abstract interface class TransactionQueryRepository {
  Stream<List<TransactionListItem>> watchTransactions(
    TransactionListQuery query,
  );

  Stream<TransactionDetailView?> watchTransactionDetail(int transactionId);

  Future<Transaction?> findTransactionById(int transactionId);

  Future<Money> getRefundedTotal(
    int rootTransactionId, {
    String currencyCode = Money.defaultCurrency,
  });

  Future<ReimbursementSummary?> getReimbursementSummary(int rootTransactionId);
}
