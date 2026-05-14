import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_form_field.dart';
import '../../../design_system/widgets/app_form_section.dart';
import '../../../design_system/widgets/app_page_header.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_query_service.dart';
import '../../../domain/services/transaction_service.dart';

class ReimbursementReceiptFormPage extends ConsumerStatefulWidget {
  const ReimbursementReceiptFormPage({
    required this.advanceTransactionId,
    super.key,
  });

  final int advanceTransactionId;

  @override
  ConsumerState<ReimbursementReceiptFormPage> createState() =>
      _ReimbursementReceiptFormPageState();
}

class _ReimbursementReceiptFormPageState
    extends ConsumerState<ReimbursementReceiptFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _receiveAccountId;
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final detail =
        ref.watch(transactionDetailProvider(widget.advanceTransactionId)).value;
    final summary = detail?.reimbursementSummary;
    final receivable = _resolveReceivable(detail);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              AppSpacing.space14,
              AppSpacing.space16,
              AppSpacing.space24,
            ),
            children: [
              const AppPageHeader(
                title: '记一笔到账',
                subtitle: '将报销款记入资金账户',
                showBackButton: true,
              ),
              const SizedBox(height: AppSpacing.space14),
              if (summary != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                  child: Text('剩余应收：${summary.outstanding.format()}'),
                ),
              AppFormSection(
                children: [
                  AppTextFormField(
                    controller: _amountController,
                    labelText: '到账金额',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: _validatePositive,
                  ),
                  AppDropdownFormField<int>(
                    initialValue: _receiveAccountId,
                    labelText: '到账账户',
                    prefixIcon: const Icon(Icons.account_balance),
                    items: [
                      for (final account in accounts)
                        DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        ),
                    ],
                    onChanged:
                        (value) => setState(() => _receiveAccountId = value),
                    validator: (value) => value == null ? '请选择账户' : null,
                  ),
                  AppTextFormField(
                    controller: _noteController,
                    labelText: '备注',
                    prefixIcon: const Icon(Icons.notes),
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space24),
              SizedBox(
                height: AppSpacing.space48,
                child: FilledButton(
                  onPressed:
                      (_submitting || receivable == null)
                          ? null
                          : () => _submit(receivable),
                  child:
                      _submitting
                          ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validatePositive(String? value) {
    try {
      final money = Money.parse(value ?? '');
      return money.minorUnits > 0 ? null : '金额必须大于 0';
    } on FormatException {
      return '请输入有效金额';
    }
  }

  int? _resolveReceivable(TransactionDetailView? detail) {
    if (detail == null) return null;
    for (final entry in detail.entries) {
      if (entry.accountType == AccountType.asset &&
          entry.direction == EntryDirection.debit) {
        return entry.accountId;
      }
    }
    return null;
  }

  Future<void> _submit(int receivableAccountId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    final service = ref.read(transactionServiceProvider);
    final result = await service.createReimbursementReceipt(
      CreateReimbursementReceiptCommand(
        amount: Money.parse(_amountController.text),
        advanceTransactionId: widget.advanceTransactionId,
        receivableAccountId: receivableAccountId,
        receiveAccountId: _receiveAccountId!,
        occurredAt: DateTime.now(),
        note:
            _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (result) {
      case Success():
        context.pop();
      case FailureResult(:final failure):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
}
