import '../../../domain/orchestration/orchestration_contribution.dart';
import '../../../domain/orchestration/transaction_handlers.dart';
import '../../../domain/services/installment_service.dart';
import '../../../domain/services/transaction_service.dart';
import 'installment_transaction_handlers.dart';

/// 分期编排叠加层向 registry 注册的接入点。
class InstallmentContribution implements OrchestrationContribution {
  const InstallmentContribution(this._installment, this._fallback);

  final InstallmentService _installment;
  final TransactionService _fallback;

  @override
  Future<TransactionHandlers?> handlersFor(int transactionId) async {
    final link = await _installment.findLinkByTransaction(transactionId);
    if (link == null) return null;
    return InstallmentTransactionHandlers(
      installment: _installment,
      fallback: _fallback,
      link: link,
      transactionId: transactionId,
    );
  }
}
