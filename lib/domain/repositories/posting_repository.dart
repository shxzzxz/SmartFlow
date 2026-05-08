import '../entities/account.dart';
import '../services/posting_command.dart';

abstract interface class PostingRepository {
  Future<List<Account>> findAccountsByIds(Set<int> ids);

  Future<PostTransactionResult> postTransaction({
    required PostTransactionCommand command,
    required Map<int, int> balanceDeltasMinor,
  });
}
