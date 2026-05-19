import '../../../core/result/result.dart';
import '../../../domain/enums/installment_enums.dart';
import '../../../domain/orchestration/transaction_action_policy.dart';
import '../../../domain/services/installment_service.dart';
import '../../../domain/services/transaction_service.dart';

/// 分期编排叠加层针对单笔交易的 action policy。
///
/// - 删除按 [InstallmentOwnerRole] 分流：还款撤销走 revertRepayment；
///   放款交易走 deleteContract（级联撤销其下所有还款）。
/// - 编辑路由先指向合同详情页占位，待编辑页另开工作流后再细化。
/// - 改账户 / 改时间 / 改备注不破坏合同状态，直接委托 [TransactionService]。
/// - 金额修改一律禁止，引导用户去合同详情或专属编辑页。
class InstallmentTransactionActionPolicy implements TransactionActionPolicy {
  const InstallmentTransactionActionPolicy({
    required InstallmentService installment,
    required TransactionService fallback,
    required int contractId,
    required InstallmentOwnerRole ownerRole,
    required int transactionId,
  }) : _installment = installment,
       _fallback = fallback,
       _contractId = contractId,
       _ownerRole = ownerRole,
       _transactionId = transactionId;

  final InstallmentService _installment;
  final TransactionService _fallback;
  final int _contractId;
  final InstallmentOwnerRole _ownerRole;
  final int _transactionId;

  @override
  Future<Result<void>> delete() {
    return switch (_ownerRole) {
      InstallmentOwnerRole.disbursement => _installment.deleteContract(
        DeleteContractCommand(contractId: _contractId),
      ),
      InstallmentOwnerRole.regularRepayment ||
      InstallmentOwnerRole.extraPrincipal ||
      InstallmentOwnerRole.earlySettlement => _installment.revertRepayment(
        RevertRepaymentCommand(transactionId: _transactionId),
      ),
    };
  }

  @override
  String editRoutePath() => '/installments/$_contractId';

  @override
  Future<Result<void>> changeSettlementAccount(int newAccountId) async {
    final result = await _fallback.updateTransactionBasics(
      UpdateTransactionBasicsCommand(
        transactionId: _transactionId,
        settlementAccountId: newAccountId,
      ),
    );
    if (result case FailureResult()) return result;
    // 分期放款交易的结算账户即合同的 disbursement 账户；
    // 同步合同表，避免下次还款 form 默认预填脱节。
    if (_ownerRole == InstallmentOwnerRole.disbursement) {
      return _installment.updateContractDisbursementAccount(
        _contractId,
        newAccountId,
      );
    }
    return result;
  }

  @override
  Future<Result<void>> changeOccurredAt(DateTime newTime) {
    return _fallback.updateTransactionBasics(
      UpdateTransactionBasicsCommand(
        transactionId: _transactionId,
        occurredAt: newTime,
      ),
    );
  }

  @override
  Future<Result<void>> changeNote(String? newNote) {
    return _fallback.updateTransactionMetadata(
      UpdateTransactionMetadataCommand(
        transactionId: _transactionId,
        note: newNote,
        noteChanged: true,
      ),
    );
  }

  @override
  EditPermission canEdit(EditableField field) {
    return switch (field) {
      EditableField.amount => const EditPermission.denied(
        reason: '请在分期合同详情页修改金额',
      ),
      _ => const EditPermission.allowed(),
    };
  }

  @override
  String? displayBanner() {
    return switch (_ownerRole) {
      InstallmentOwnerRole.disbursement => '此为分期合同放款，金额、账户、日期等需在合同详情页内调整',
      InstallmentOwnerRole.regularRepayment => '此为分期期次还款，撤销请在合同详情页操作',
      InstallmentOwnerRole.extraPrincipal => '此为分期提前还本，撤销请在合同详情页操作',
      InstallmentOwnerRole.earlySettlement => '此为分期提前结清，撤销请在合同详情页操作',
    };
  }
}
