import '../entities/account.dart';
import '../services/posting_command.dart';

abstract interface class PostingRepository {
  Future<List<Account>> findAccountsByIds(Set<int> ids);

  Future<PostTransactionResult> postTransaction({
    required PostTransactionCommand command,
    required Map<int, int> balanceDeltasMinor,
  });

  Future<List<PostTransactionResult>> mutateTransactions({
    required List<TransactionStateUpdate> stateUpdates,
    required List<PostTransactionMutation> posts,
  });

  Future<void> updateTransactionMetadata({
    required int transactionId,
    bool updateNote = false,
    String? note,
    bool? isExcludedFromStats,
    bool? isExcludedFromBudget,
  });

  Future<void> updateTransactionBasics({
    required int transactionId,
    DateTime? occurredAt,
    List<EntryAccountReassignment> entryAccountReassignments = const [],
  });
}
