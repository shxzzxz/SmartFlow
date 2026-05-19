import 'transaction_handlers.dart';

/// 单个编排叠加层的接入贡献。
///
/// 给定 transactionId：
/// - 若该笔归本编排层管 → 返回装配好的 [TransactionHandlers]；
/// - 否则 → 返回 null。
abstract interface class OrchestrationContribution {
  Future<TransactionHandlers?> handlersFor(int transactionId);
}
