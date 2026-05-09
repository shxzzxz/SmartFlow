import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/theme/app_theme_extension.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_form_section.dart';
import '../../../design_system/widgets/app_page_header.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/category_service.dart';
import '../../../domain/services/transaction_service.dart';
import '../../../widgets/business/category_icon.dart';
import '../../../widgets/business/finance_labels.dart';
import '../../../widgets/business/money_text.dart';

enum _TransactionFormMode {
  expense,
  income,
  transfer,
  reimbursementAdvance,
  repayment,
  borrowing,
  balanceAdjustment,
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
  final _interestController = TextEditingController();
  final _repayFeeController = TextEditingController();
  final _targetBalanceController = TextEditingController();
  final _counterpartyController = TextEditingController();
  final _noteController = TextEditingController();
  _TransactionFormMode _mode = _TransactionFormMode.expense;
  int? _fromAccountId;
  int? _toAccountId;
  int? _expenseCategoryId;
  int? _incomeCategoryId;
  int? _feeCategoryId;
  int? _interestCategoryId;
  int? _repayFeeCategoryId;
  int? _liabilityAccountId;
  int? _receivableAccountId;
  int? _adjustmentAccountId;

  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    _interestController.dispose();
    _repayFeeController.dispose();
    _targetBalanceController.dispose();
    _counterpartyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final liabilityAccounts = accounts
        .where((a) => a.type == AccountType.liability)
        .toList();
    final receivableAccounts = accounts
        .where(
          (a) =>
              a.type == AccountType.asset &&
              a.subtype == AccountSubtype.reimbursement,
        )
        .toList();
    final assetOrLiabilityAccounts = accounts;
    final expenseCategories = _flatten(
      ref.watch(categoryTreeProvider(AccountType.expense)).value ?? const [],
    );
    final incomeCategories = _flatten(
      ref.watch(categoryTreeProvider(AccountType.income)).value ?? const [],
    );

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
                title: '新增交易',
                subtitle: '记录支出、收入、转账或复合交易',
                showBackButton: true,
              ),
              const SizedBox(height: AppSpacing.space14),
              _ModeTabs(
                mode: _mode,
                onChanged: (next) => setState(() => _mode = next),
              ),
              const SizedBox(height: AppSpacing.space16),
              _AmountHero(
                controller: _amountController,
                label: _amountLabel(_mode),
                semantic: _amountSemantic(_mode),
                validator: _validatePositiveMoney,
              ),
              const SizedBox(height: AppSpacing.space16),
              if (_mode == _TransactionFormMode.expense)
                _CategoryGrid(
                  categories: expenseCategories,
                  selectedId: _expenseCategoryId,
                  fallback: CategoryIconFallback.expense,
                  emptyLabel: '尚未创建支出分类',
                  onSelect: (id) =>
                      setState(() => _expenseCategoryId = id),
                ),
              if (_mode == _TransactionFormMode.income)
                _CategoryGrid(
                  categories: incomeCategories,
                  selectedId: _incomeCategoryId,
                  fallback: CategoryIconFallback.income,
                  emptyLabel: '尚未创建收入分类',
                  onSelect: (id) =>
                      setState(() => _incomeCategoryId = id),
                ),
              if (_mode == _TransactionFormMode.expense ||
                  _mode == _TransactionFormMode.income)
                const SizedBox(height: AppSpacing.space16),
              AppFormSection(
                children: _buildModeFields(
                  accounts: assetOrLiabilityAccounts,
                  liabilityAccounts: liabilityAccounts,
                  receivableAccounts: receivableAccounts,
                  expenseCategories: expenseCategories,
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              AppFormSection(
                children: [
                  TextFormField(
                    controller: _counterpartyController,
                    decoration: const InputDecoration(
                      labelText: '交易对象',
                      prefixIcon: Icon(Icons.storefront),
                    ),
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
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildModeFields({
    required List<Account> accounts,
    required List<Account> liabilityAccounts,
    required List<Account> receivableAccounts,
    required List<Account> expenseCategories,
  }) {
    return switch (_mode) {
      _TransactionFormMode.expense => [
          _accountDropdown(
            label: '付款账户',
            value: _fromAccountId,
            accounts: accounts,
            onChanged: (value) => setState(() => _fromAccountId = value),
          ),
        ],
      _TransactionFormMode.income => [
          _accountDropdown(
            label: '收款账户',
            value: _toAccountId,
            accounts: accounts,
            onChanged: (value) => setState(() => _toAccountId = value),
          ),
        ],
      _TransactionFormMode.transfer => [
          _accountDropdown(
            label: '转出账户',
            value: _fromAccountId,
            accounts: accounts,
            onChanged: (value) => setState(() => _fromAccountId = value),
          ),
          _accountDropdown(
            label: '转入账户',
            value: _toAccountId,
            accounts: accounts,
            onChanged: (value) => setState(() => _toAccountId = value),
          ),
          TextFormField(
            controller: _feeController,
            decoration: const InputDecoration(
              labelText: '手续费',
              prefixIcon: Icon(Icons.receipt_long),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            validator: _validateOptionalMoney,
          ),
          _accountDropdown(
            label: '手续费分类',
            value: _feeCategoryId,
            accounts: expenseCategories,
            required: false,
            onChanged: (value) => setState(() => _feeCategoryId = value),
          ),
        ],
      _TransactionFormMode.reimbursementAdvance => [
          _accountDropdown(
            label: '应收账户',
            value: _receivableAccountId,
            accounts: receivableAccounts,
            emptyHint: '请先创建报销账户（资产 · 报销）',
            onChanged: (value) => setState(() => _receivableAccountId = value),
          ),
          _accountDropdown(
            label: '垫付账户',
            value: _fromAccountId,
            accounts: accounts,
            onChanged: (value) => setState(() => _fromAccountId = value),
          ),
          _accountDropdown(
            label: '报销支出分类',
            value: _expenseCategoryId,
            accounts: expenseCategories,
            onChanged: (value) =>
                setState(() => _expenseCategoryId = value),
          ),
        ],
      _TransactionFormMode.repayment => [
          _accountDropdown(
            label: '负债账户',
            value: _liabilityAccountId,
            accounts: liabilityAccounts,
            onChanged: (value) => setState(() => _liabilityAccountId = value),
          ),
          _accountDropdown(
            label: '还款账户',
            value: _fromAccountId,
            accounts: accounts,
            onChanged: (value) => setState(() => _fromAccountId = value),
          ),
          TextFormField(
            controller: _interestController,
            decoration: const InputDecoration(
              labelText: '利息',
              prefixIcon: Icon(Icons.percent),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            validator: _validateOptionalMoney,
          ),
          _accountDropdown(
            label: '利息分类',
            value: _interestCategoryId,
            accounts: expenseCategories,
            required: false,
            onChanged: (value) =>
                setState(() => _interestCategoryId = value),
          ),
          TextFormField(
            controller: _repayFeeController,
            decoration: const InputDecoration(
              labelText: '手续费',
              prefixIcon: Icon(Icons.receipt_long),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            validator: _validateOptionalMoney,
          ),
          _accountDropdown(
            label: '手续费分类',
            value: _repayFeeCategoryId,
            accounts: expenseCategories,
            required: false,
            onChanged: (value) =>
                setState(() => _repayFeeCategoryId = value),
          ),
        ],
      _TransactionFormMode.borrowing => [
          _accountDropdown(
            label: '负债账户',
            value: _liabilityAccountId,
            accounts: liabilityAccounts,
            onChanged: (value) => setState(() => _liabilityAccountId = value),
          ),
          _accountDropdown(
            label: '到账账户（可选）',
            value: _toAccountId,
            accounts: accounts,
            required: false,
            onChanged: (value) => setState(() => _toAccountId = value),
          ),
        ],
      _TransactionFormMode.balanceAdjustment => [
          _accountDropdown(
            label: '调整账户',
            value: _adjustmentAccountId,
            accounts: accounts,
            onChanged: (value) =>
                setState(() => _adjustmentAccountId = value),
          ),
          TextFormField(
            controller: _targetBalanceController,
            decoration: const InputDecoration(
              labelText: '目标余额',
              prefixIcon: Icon(Icons.tune),
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            validator: _validateMoney,
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
    String? emptyHint,
  }) {
    final validValue =
        accounts.any((account) => account.id == value) ? value : null;
    if (accounts.isEmpty && emptyHint != null) {
      return InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          emptyHint,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      key: ValueKey('${_mode.name}_$label'),
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
      validator:
          required ? (value) => value == null ? '请选择$label' : null : null,
    );
  }

  String _amountLabel(_TransactionFormMode mode) {
    return switch (mode) {
      _TransactionFormMode.balanceAdjustment => '当前余额',
      _TransactionFormMode.repayment => '本金',
      _TransactionFormMode.borrowing => '借入金额',
      _TransactionFormMode.reimbursementAdvance => '垫付金额',
      _ => '金额',
    };
  }

  String? _validatePositiveMoney(String? value) {
    if (_mode == _TransactionFormMode.balanceAdjustment) {
      return null;
    }
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

  String? _validateMoney(String? value) {
    try {
      Money.parse(value ?? '');
      return null;
    } on FormatException {
      return '请输入有效金额';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_mode == _TransactionFormMode.expense && _expenseCategoryId == null) {
      _showError('请选择支出分类');
      return;
    }
    if (_mode == _TransactionFormMode.income && _incomeCategoryId == null) {
      _showError('请选择收入分类');
      return;
    }

    setState(() => _submitting = true);
    final service = ref.read(transactionServiceProvider);
    final now = DateTime.now();
    final counterparty = _blankToNull(_counterpartyController.text);
    final note = _blankToNull(_noteController.text);

    final result = await switch (_mode) {
      _TransactionFormMode.expense => service.createExpense(
          CreateExpenseCommand(
            amount: Money.parse(_amountController.text),
            paidFromAccountId: _fromAccountId!,
            expenseAccountId: _expenseCategoryId!,
            occurredAt: now,
            counterpartyName: counterparty,
            note: note,
          ),
        ),
      _TransactionFormMode.income => service.createIncome(
          CreateIncomeCommand(
            amount: Money.parse(_amountController.text),
            receiveAccountId: _toAccountId!,
            incomeAccountId: _incomeCategoryId!,
            occurredAt: now,
            counterpartyName: counterparty,
            note: note,
          ),
        ),
      _TransactionFormMode.transfer => service.createTransfer(
          CreateTransferCommand(
            amount: Money.parse(_amountController.text),
            fromAccountId: _fromAccountId!,
            toAccountId: _toAccountId!,
            feeAmount: _feeController.text.trim().isEmpty
                ? null
                : Money.parse(_feeController.text),
            feeExpenseAccountId: _feeController.text.trim().isEmpty
                ? null
                : _feeCategoryId,
            occurredAt: now,
            counterpartyName: counterparty,
            note: note,
          ),
        ),
      _TransactionFormMode.reimbursementAdvance =>
        service.createReimbursementAdvance(
          CreateReimbursementAdvanceCommand(
            amount: Money.parse(_amountController.text),
            receivableAccountId: _receivableAccountId!,
            paidFromAccountId: _fromAccountId!,
            expenseCategoryId: _expenseCategoryId!,
            occurredAt: now,
            counterpartyName: counterparty,
            note: note,
          ),
        ),
      _TransactionFormMode.repayment => service.createRepayment(
          CreateRepaymentCommand(
            principal: Money.parse(_amountController.text),
            interest: _interestController.text.trim().isEmpty
                ? null
                : Money.parse(_interestController.text),
            fee: _repayFeeController.text.trim().isEmpty
                ? null
                : Money.parse(_repayFeeController.text),
            liabilityAccountId: _liabilityAccountId!,
            paidFromAccountId: _fromAccountId!,
            interestExpenseAccountId: _interestCategoryId,
            feeExpenseAccountId: _repayFeeCategoryId,
            occurredAt: now,
            counterpartyName: counterparty,
            note: note,
          ),
        ),
      _TransactionFormMode.borrowing => service.createBorrowing(
          CreateBorrowingCommand(
            amount: Money.parse(_amountController.text),
            liabilityAccountId: _liabilityAccountId!,
            receiveAccountId: _toAccountId,
            occurredAt: now,
            counterpartyName: counterparty,
            note: note,
          ),
        ),
      _TransactionFormMode.balanceAdjustment => service.adjustBalance(
          AdjustBalanceCommand(
            accountId: _adjustmentAccountId!,
            targetBalance: Money.parse(_targetBalanceController.text),
            occurredAt: now,
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
        _showError(failure.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<Account> _flatten(List<CategoryNode> nodes) {
    return [
      for (final node in nodes) ...[node.account, ...node.children],
    ];
  }

  String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  MoneySemantic _amountSemantic(_TransactionFormMode mode) {
    return switch (mode) {
      _TransactionFormMode.expense => MoneySemantic.expense,
      _TransactionFormMode.income => MoneySemantic.income,
      _TransactionFormMode.reimbursementAdvance => MoneySemantic.expense,
      _TransactionFormMode.repayment => MoneySemantic.expense,
      _TransactionFormMode.borrowing => MoneySemantic.income,
      _ => MoneySemantic.neutral,
    };
  }
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.mode, required this.onChanged});

  final _TransactionFormMode mode;
  final ValueChanged<_TransactionFormMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      border: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final value in _TransactionFormMode.values)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space2,
                  ),
                  child: _ModeTabItem(
                    label: _modeLabel(value),
                    selected: value == mode,
                    onTap: () => onChanged(value),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTabItem extends StatelessWidget {
  const _ModeTabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      child: Container(
        height: AppSpacing.space32,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
        decoration: BoxDecoration(
          color: selected ? colors.primary.withValues(alpha: 0.10) : null,
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            color: selected ? colors.primary : colors.onSurfaceVariant,
            fontSize: AppTypography.fontSizeMd,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

String _modeLabel(_TransactionFormMode mode) {
  return switch (mode) {
    _TransactionFormMode.expense => '支出',
    _TransactionFormMode.income => '收入',
    _TransactionFormMode.transfer => '转账',
    _TransactionFormMode.reimbursementAdvance => '报销垫付',
    _TransactionFormMode.repayment => '还款',
    _TransactionFormMode.borrowing => '借入',
    _TransactionFormMode.balanceAdjustment => '余额调整',
  };
}

class _AmountHero extends StatelessWidget {
  const _AmountHero({
    required this.controller,
    required this.label,
    required this.semantic,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final MoneySemantic semantic;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final color = switch (semantic) {
      MoneySemantic.expense => financeColors.expense,
      MoneySemantic.income => financeColors.income,
      _ => colors.onSurface,
    };

    return AppSurface(
      border: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space20,
          AppSpacing.space16,
          AppSpacing.space20,
          AppSpacing.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: AppTypography.fontSizeSm,
              ),
            ),
            TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
              ],
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              validator: validator,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.fallback,
    required this.emptyLabel,
    required this.onSelect,
  });

  final List<Account> categories;
  final int? selectedId;
  final CategoryIconFallback fallback;
  final String emptyLabel;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return AppSurface(
        border: true,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space20),
          child: Row(
            children: [
              Icon(
                Icons.category_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Text(
                  emptyLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppSurface(
      border: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space16,
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: AppSpacing.space12,
            crossAxisSpacing: AppSpacing.space8,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryGridItem(
              category: category,
              fallback: fallback,
              selected: category.id == selectedId,
              onTap: () => onSelect(category.id),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  const _CategoryGridItem({
    required this.category,
    required this.fallback,
    required this.selected,
    required this.onTap,
  });

  final Account category;
  final CategoryIconFallback fallback;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSpacing.space48,
            height: AppSpacing.space48,
            decoration: BoxDecoration(
              color: selected
                  ? colors.primary.withValues(alpha: 0.12)
                  : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.radiusMd),
              border: selected
                  ? Border.all(color: colors.primary, width: 1.5)
                  : null,
            ),
            child: Center(
              child: CategoryIcon(
                iconKey: category.iconKey,
                size: 28,
                fallback: fallback,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: selected ? colors.primary : colors.onSurface,
              fontSize: AppTypography.fontSizeXs,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
