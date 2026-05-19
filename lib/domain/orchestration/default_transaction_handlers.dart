import '../../core/result/result.dart';
import '../services/transaction_service.dart';
import 'transaction_handlers.dart';

/// 普通交易的默认 handler：所有 universal 动作直接走 [TransactionService]。
class DefaultTransactionHandlers implements TransactionHandlers {
  const DefaultTransactionHandlers({
    required TransactionService service,
    required int transactionId,
  })  : _service = service,
        _transactionId = transactionId;

  final TransactionService _service;
  final int _transactionId;

  @override
  Future<Result<void>> delete() {
    return _service.deleteTransaction(
      DeleteTransactionCommand(transactionId: _transactionId),
    );
  }

  @override
  String editRoutePath() => '/transactions/$_transactionId/edit';

  @override
  Future<Result<void>> changeSettlementAccount(int newAccountId) {
    return _service.updateTransactionBasics(
      UpdateTransactionBasicsCommand(
        transactionId: _transactionId,
        settlementAccountId: newAccountId,
      ),
    );
  }

  @override
  Future<Result<void>> changeOccurredAt(DateTime newTime) {
    return _service.updateTransactionBasics(
      UpdateTransactionBasicsCommand(
        transactionId: _transactionId,
        occurredAt: newTime,
      ),
    );
  }

  @override
  Future<Result<void>> changeNote(String? newNote) {
    return _service.updateTransactionMetadata(
      UpdateTransactionMetadataCommand(
        transactionId: _transactionId,
        note: newNote,
        noteChanged: true,
      ),
    );
  }

  @override
  EditPermission canEdit(EditableField field) => const EditPermission.allowed();

  @override
  String? displayBanner() => null;
}
