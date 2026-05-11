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
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_query_service.dart';
import '../../../domain/services/transaction_service.dart';

class ReimbursementCloseFormPage extends ConsumerStatefulWidget {
  const ReimbursementCloseFormPage({
    required this.advanceTransactionId,
    super.key,
  });

  final int advanceTransactionId;

  @override
  ConsumerState<ReimbursementCloseFormPage> createState() =>
      _ReimbursementCloseFormPageState();
}

class _ReimbursementCloseFormPageState
    extends ConsumerState<ReimbursementCloseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _receiveAccountId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

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
    final outstanding = summary?.outstanding;
    final actualMinor = _parseMinorOrNull(_amountController.text);
    final gap =
        (outstanding != null && actualMinor != null)
            ? Money(
              minorUnits: actualMinor - outstanding.minorUnits,
              currency: outstanding.currency,
            )
            : null;

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
                title: '结束报销',
                subtitle: '记录最后一笔到账并对账差额',
                showBackButton: true,
              ),
              const SizedBox(height: AppSpacing.space14),
              if (outstanding != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                  child: Text('剩余应收：${outstanding.format()}'),
                ),
              if (gap != null && gap.minorUnits != 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                  child: Text(
                    gap.minorUnits > 0
                        ? '多收 ${gap.format()}（计入报销差额收入）'
                        : '少收 ${gap.abs().format()}（计入原报销支出分类）',
                  ),
                ),
              AppFormSection(
                children: [
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: '实收金额',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: _validateNonNegative,
                  ),
                  DropdownButtonFormField<int>(
                    initialValue: _receiveAccountId,
                    decoration: const InputDecoration(
                      labelText: '到账账户',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    items: [
                      for (final account in accounts)
                        DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        ),
                    ],
                    onChanged:
                        (value) => setState(() => _receiveAccountId = value),
                    validator: (value) {
                      final amount = _parseMinorOrNull(_amountController.text);
                      if (amount != null && amount > 0 && value == null) {
                        return '请选择账户';
                      }
                      return null;
                    },
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

  int? _parseMinorOrNull(String input) {
    try {
      return Money.parse(input).minorUnits;
    } on FormatException {
      return null;
    }
  }

  String? _validateNonNegative(String? value) {
    try {
      final money = Money.parse(value ?? '');
      return money.minorUnits >= 0 ? null : '金额不能小于 0';
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
    final amount = Money.parse(_amountController.text);
    setState(() => _submitting = true);
    final service = ref.read(transactionServiceProvider);
    final result = await service.closeReimbursement(
      CloseReimbursementCommand(
        actualReceivedAmount: amount,
        advanceTransactionId: widget.advanceTransactionId,
        receivableAccountId: receivableAccountId,
        receiveAccountId: _receiveAccountId ?? receivableAccountId,
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
