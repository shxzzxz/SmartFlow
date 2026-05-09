import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_form_section.dart';
import '../../../design_system/widgets/app_page_header.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/services/transaction_service.dart';

class RefundFormPage extends ConsumerStatefulWidget {
  const RefundFormPage({required this.parentTransactionId, super.key});

  final int parentTransactionId;

  @override
  ConsumerState<RefundFormPage> createState() => _RefundFormPageState();
}

class _RefundFormPageState extends ConsumerState<RefundFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _refundToAccountId;
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
    final detailAsync = ref.watch(
      transactionDetailProvider(widget.parentTransactionId),
    );

    final remaining = detailAsync.value?.let((detail) {
      final amount = detail.transaction.primaryAmount;
      final refunded = detail.refundedTotal ??
          Money(minorUnits: 0, currency: amount.currency);
      return amount - refunded;
    });

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
                title: '退款',
                subtitle: '退还到指定账户，并自然抵减原支出统计',
                showBackButton: true,
              ),
              const SizedBox(height: AppSpacing.space14),
              if (remaining != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                  child: Text('当前可退余额：${remaining.format()}'),
                ),
              AppFormSection(
                children: [
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: '退款金额',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: _validatePositive,
                  ),
                  DropdownButtonFormField<int>(
                    initialValue: _refundToAccountId,
                    decoration: const InputDecoration(
                      labelText: '退款到账户',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    items: [
                      for (final account in accounts)
                        DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _refundToAccountId = value),
                    validator: (value) => value == null ? '请选择账户' : null,
                  ),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space24),
              SizedBox(
                height: AppSpacing.space48,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    final service = ref.read(transactionServiceProvider);
    final result = await service.createRefund(
      CreateRefundCommand(
        amount: Money.parse(_amountController.text),
        parentTransactionId: widget.parentTransactionId,
        refundToAccountId: _refundToAccountId!,
        occurredAt: DateTime.now(),
        note: _noteController.text.trim().isEmpty
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }
}

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
