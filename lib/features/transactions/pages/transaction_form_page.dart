import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/category_service.dart';
import '../../../domain/services/transaction_service.dart';
import '../../../widgets/business/finance_labels.dart';

enum _TransactionFormMode {
  expense,
  income,
  transfer,
}

class TransactionFormPage extends ConsumerStatefulWidget {
  const TransactionFormPage({super.key});

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _feeController = TextEditingController();
  final _counterpartyController = TextEditingController();
  final _noteController = TextEditingController();
  _TransactionFormMode _mode = _TransactionFormMode.expense;
  int? _fromAccountId;
  int? _toAccountId;
  int? _expenseCategoryId;
  int? _incomeCategoryId;
  int? _feeCategoryId;
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    _counterpartyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(accountListProvider);
    final expenseAsync = ref.watch(categoryTreeProvider(AccountType.expense));
    final incomeAsync = ref.watch(categoryTreeProvider(AccountType.income));
    final accounts = accountAsync.value ?? const <Account>[];
    final expenseCategories = _flatten(expenseAsync.value ?? const []);
    final incomeCategories = _flatten(incomeAsync.value ?? const []);

    return Scaffold(
      appBar: AppBar(title: const Text('新增交易')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.space16),
            children: [
              SegmentedButton<_TransactionFormMode>(
                segments: const [
                  ButtonSegment(
                    value: _TransactionFormMode.expense,
                    icon: Icon(Icons.remove_circle_outline),
                    label: Text('支出'),
                  ),
                  ButtonSegment(
                    value: _TransactionFormMode.income,
                    icon: Icon(Icons.add_circle_outline),
                    label: Text('收入'),
                  ),
                  ButtonSegment(
                    value: _TransactionFormMode.transfer,
                    icon: Icon(Icons.swap_horiz),
                    label: Text('转账'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() => _mode = selection.single);
                },
              ),
              const SizedBox(height: AppSpacing.space16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: '金额',
                  prefixIcon: Icon(Icons.payments),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validatePositiveMoney,
              ),
              const SizedBox(height: AppSpacing.space16),
              ..._buildModeFields(accounts, expenseCategories, incomeCategories),
              const SizedBox(height: AppSpacing.space16),
              TextFormField(
                controller: _counterpartyController,
                decoration: const InputDecoration(
                  labelText: '交易对象',
                  prefixIcon: Icon(Icons.storefront),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.space24),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildModeFields(
    List<Account> accounts,
    List<Account> expenseCategories,
    List<Account> incomeCategories,
  ) {
    return switch (_mode) {
      _TransactionFormMode.expense => [
          _accountDropdown(
            label: '付款账户',
            value: _fromAccountId,
            accounts: accounts,
            onChanged: (value) => setState(() => _fromAccountId = value),
          ),
          const SizedBox(height: AppSpacing.space16),
          _accountDropdown(
            label: '支出分类',
            value: _expenseCategoryId,
            accounts: expenseCategories,
            onChanged: (value) => setState(() => _expenseCategoryId = value),
          ),
        ],
      _TransactionFormMode.income => [
          _accountDropdown(
            label: '收款账户',
            value: _toAccountId,
            accounts: accounts,
            onChanged: (value) => setState(() => _toAccountId = value),
          ),
          const SizedBox(height: AppSpacing.space16),
          _accountDropdown(
            label: '收入分类',
            value: _incomeCategoryId,
            accounts: incomeCategories,
            onChanged: (value) => setState(() => _incomeCategoryId = value),
          ),
        ],
      _TransactionFormMode.transfer => [
          _accountDropdown(
            label: '转出账户',
            value: _fromAccountId,
            accounts: accounts,
            onChanged: (value) => setState(() => _fromAccountId = value),
          ),
          const SizedBox(height: AppSpacing.space16),
          _accountDropdown(
            label: '转入账户',
            value: _toAccountId,
            accounts: accounts,
            onChanged: (value) => setState(() => _toAccountId = value),
          ),
          const SizedBox(height: AppSpacing.space16),
          TextFormField(
            controller: _feeController,
            decoration: const InputDecoration(
              labelText: '手续费',
              prefixIcon: Icon(Icons.receipt_long),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validateOptionalMoney,
          ),
          const SizedBox(height: AppSpacing.space16),
          _accountDropdown(
            label: '手续费分类',
            value: _feeCategoryId,
            accounts: expenseCategories,
            required: false,
            onChanged: (value) => setState(() => _feeCategoryId = value),
          ),
        ],
    };
  }

  Widget _accountDropdown({
    required String label,
    required int? value,
    required List<Account> accounts,
    required ValueChanged<int?> onChanged,
    bool required = true,
  }) {
    final validValue = accounts.any((account) => account.id == value)
        ? value
        : null;

    return DropdownButtonFormField<int>(
      key: ValueKey(label),
      initialValue: validValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.account_balance),
      ),
      items: [
        for (final account in accounts)
          DropdownMenuItem(
            value: account.id,
            child: Text('${account.name} · ${accountTypeLabel(account.type)}'),
          ),
      ],
      onChanged: onChanged,
      validator: required
          ? (value) => value == null ? '请选择$label' : null
          : null,
    );
  }

  String? _validatePositiveMoney(String? value) {
    try {
      final money = Money.parse(value ?? '');
      return money.minorUnits > 0 ? null : '金额必须大于 0';
    } on FormatException {
      return '请输入有效金额';
    }
  }

  String? _validateOptionalMoney(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    try {
      final money = Money.parse(value);
      return money.minorUnits >= 0 ? null : '金额不能小于 0';
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
    final amount = Money.parse(_amountController.text);
    final fee = _feeController.text.trim().isEmpty
        ? null
        : Money.parse(_feeController.text);
    final occurredAt = DateTime.now();
    final counterparty = _blankToNull(_counterpartyController.text);
    final note = _blankToNull(_noteController.text);

    final result = switch (_mode) {
      _TransactionFormMode.expense => await service.createExpense(
          CreateExpenseCommand(
            amount: amount,
            paidFromAccountId: _fromAccountId!,
            expenseAccountId: _expenseCategoryId!,
            occurredAt: occurredAt,
            counterpartyName: counterparty,
            note: note,
          ),
        ),
      _TransactionFormMode.income => await service.createIncome(
          CreateIncomeCommand(
            amount: amount,
            receiveAccountId: _toAccountId!,
            incomeAccountId: _incomeCategoryId!,
            occurredAt: occurredAt,
            counterpartyName: counterparty,
            note: note,
          ),
        ),
      _TransactionFormMode.transfer => await service.createTransfer(
          CreateTransferCommand(
            amount: amount,
            fromAccountId: _fromAccountId!,
            toAccountId: _toAccountId!,
            feeAmount: fee,
            feeExpenseAccountId: fee != null && fee.minorUnits > 0
                ? _feeCategoryId
                : null,
            occurredAt: occurredAt,
            counterpartyName: counterparty,
            note: note,
          ),
        ),
    };

    if (!mounted) {
      return;
    }
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

  List<Account> _flatten(List<CategoryNode> nodes) {
    return [
      for (final node in nodes) ...[
        node.account,
        ...node.children,
      ],
    ];
  }

  String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
