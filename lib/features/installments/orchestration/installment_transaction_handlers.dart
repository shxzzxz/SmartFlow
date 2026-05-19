import '../../../core/result/result.dart';
import '../../../domain/enums/installment_enums.dart';
import '../../../domain/orchestration/transaction_handlers.dart';
import '../../../domain/services/installment_service.dart';
import '../../../domain/services/transaction_service.dart';

/// 分期编排叠加层针对单笔交易的 handler。
///
/// - 删除按 [InstallmentLink] 分流：还款撤销走 revertRepayment；
///   放款交易走 deleteContract（级联撤销其下所有还款）。
/// - 编辑路由先指向合同详情页占位，待编辑页另开工作流后再细化。
/// - 改账户 / 改时间 / 改备注不破坏合同状态，直接委托 [TransactionService]。
/// - 金额修改一律禁止，引导用户去合同详情或专属编辑页。
class InstallmentTransactionHandlers implements TransactionHandlers {
  const InstallmentTransactionHandlers({
    required InstallmentService installment,
    required TransactionService fallback,
    required InstallmentLink link,
    required int transactionId,
  })  : _installment = installment,
        _fallback = fallback,
        _link = link,
        _transactionId = transactionId;

  final InstallmentService _installment;
  final TransactionService _fallback;
  final InstallmentLink _link;
  final int _transactionId;

  @override
  Future<Result<void>> delete() {
    return switch (_link) {
      InstallmentRepaymentLink() => _installment.revertRepayment(
          RevertRepaymentCommand(transactionId: _transactionId),
        ),
      InstallmentDisbursementLink(:final contractId) =>
        _installment.deleteContract(
          DeleteContractCommand(contractId: contractId),
        ),
    };
  }

  @override
  String editRoutePath() => '/installments/${_link.contractId}';

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
    if (_link case InstallmentDisbursementLink(:final contractId)) {
      return _installment.updateContractDisbursementAccount(
        contractId,
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
      EditableField.amount =>
        const EditPermission.denied(reason: '请在分期合同详情页修改金额'),
      _ => const EditPermission.allowed(),
    };
  }

  @override
  String? displayBanner() {
    return switch (_link) {
      InstallmentDisbursementLink() =>
        '此为分期合同放款，金额、账户、日期等需在合同详情页内调整',
      InstallmentRepaymentLink(:final repaymentType) => switch (repaymentType) {
          InstallmentRepaymentType.regular => '此为分期期次还款，撤销请在合同详情页操作',
          InstallmentRepaymentType.extraPrincipal =>
            '此为分期提前还本，撤销请在合同详情页操作',
          InstallmentRepaymentType.earlySettlement =>
            '此为分期提前结清，撤销请在合同详情页操作',
        },
    };
  }
}
