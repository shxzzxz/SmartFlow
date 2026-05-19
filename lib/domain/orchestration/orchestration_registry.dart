import 'orchestration_contribution.dart';
import 'transaction_handlers.dart';

/// 编排叠加层注册表。
///
/// 启动时由 Provider 收集所有 [OrchestrationContribution]，
/// UI 查 registry：首个命中即返回；全部不命中由调用方回落到默认 handler。
class OrchestrationRegistry {
  OrchestrationRegistry(List<OrchestrationContribution> contributions)
      : _contributions = List.unmodifiable(contributions);

  final List<OrchestrationContribution> _contributions;

  Future<TransactionHandlers?> handlersFor(int transactionId) async {
    for (final contribution in _contributions) {
      final handlers = await contribution.handlersFor(transactionId);
      if (handlers != null) return handlers;
    }
    return null;
  }
}
