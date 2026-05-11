import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/theme/app_theme_extension.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_service.dart';
import '../../../widgets/business/category_grid_picker.dart';
import '../../../widgets/business/finance_labels.dart';
import '../../../widgets/business/money_text.dart';

enum _TransactionFormMode { expense, income, transfer, borrowing }

class TransactionFormPage extends ConsumerStatefulWidget {
  const TransactionFormPage({super.key});

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  _TransactionFormMode _mode = _TransactionFormMode.expense;
  DateTime _occurredAt = DateTime.now();
  bool _submitting = false;
  bool _excludeStats = false;
  bool _excludeBudget = false;

  int? _expenseCategoryId;
  int? _expenseRootId;
  int? _incomeCategoryId;
  int? _incomeRootId;
  int? _fromAccountId;
  int? _toAccountId;
  int? _reimbursementAccountId;
  int? _liabilityAccountId;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final moneyAccounts =
        accounts.where((account) {
          return account.archivedAt == null &&
              (account.type == AccountType.asset ||
                  account.type == AccountType.liability);
        }).toList();
    final liabilityAccounts =
        moneyAccounts
            .where((account) => account.type == AccountType.liability)
            .toList();
    final reimbursementAccounts =
        moneyAccounts
            .where((account) => account.subtype == AccountSubtype.reimbursement)
            .toList();
    final expenseTree =
        ref.watch(categoryTreeProvider(AccountType.expense)).value ?? const [];
    final incomeTree =
        ref.watch(categoryTreeProvider(AccountType.income)).value ?? const [];
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final keyboardVisible = keyboardInset > 0;

    return Scaffold(
      backgroundColor: AppColors.neutral99,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              mode: _mode,
              onBack: () => context.pop(),
              onModeChanged: _switchMode,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space16,
                  AppSpacing.space8,
                  AppSpacing.space16,
                  AppSpacing.space12,
                ),
                children: [
                  if (_mode == _TransactionFormMode.expense)
                    CategoryGridPicker(
                      nodes: expenseTree,
                      selectedRootId: _expenseRootId,
                      selectedCategoryId: _expenseCategoryId,
                      emptyLabel: '尚未创建支出分类',
                      onRootSelected: (account) {
                        setState(() {
                          _expenseRootId = account.id;
                          _expenseCategoryId = account.id;
                        });
                      },
                      onChildSelected: (root, child) {
                        setState(() {
                          _expenseRootId = root.id;
                          _expenseCategoryId = child.id;
                        });
                      },
                      onAddRoot: () => _openCategoryForm(AccountType.expense),
                      onAddChild:
                          (rootId) => _openCategoryForm(
                            AccountType.expense,
                            parentId: rootId,
                          ),
                    ),
                  if (_mode == _TransactionFormMode.income)
                    CategoryGridPicker(
                      nodes: incomeTree,
                      selectedRootId: _incomeRootId,
                      selectedCategoryId: _incomeCategoryId,
                      emptyLabel: '尚未创建收入分类',
                      onRootSelected: (account) {
                        setState(() {
                          _incomeRootId = account.id;
                          _incomeCategoryId = account.id;
                        });
                      },
                      onChildSelected: (root, child) {
                        setState(() {
                          _incomeRootId = root.id;
                          _incomeCategoryId = child.id;
                        });
                      },
                      onAddRoot: () => _openCategoryForm(AccountType.income),
                      onAddChild:
                          (rootId) => _openCategoryForm(
                            AccountType.income,
                            parentId: rootId,
                          ),
                    ),
                  if (_mode == _TransactionFormMode.transfer)
                    _SimpleModeHint(
                      icon: Icons.swap_horiz,
                      title: '账户转账',
                      description: '记录两个资金账户之间的资金移动。',
                    ),
                  if (_mode == _TransactionFormMode.borrowing)
                    _SimpleModeHint(
                      icon: Icons.account_balance_wallet_outlined,
                      title: '借入',
                      description: '记录新增负债，可选择资金实际到账账户。',
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space16,
                AppSpacing.space4,
                AppSpacing.space16,
                AppSpacing.space8,
              ),
              child: Column(
                children: [
                  _AmountNotePanel(
                    amountController: _amountController,
                    noteController: _noteController,
                    semantic: _amountSemantic(_mode),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  _TransactionOptionsPanel(
                    mode: _mode,
                    occurredAt: _occurredAt,
                    moneyAccounts: moneyAccounts,
                    liabilityAccounts: liabilityAccounts,
                    reimbursementAccounts: reimbursementAccounts,
                    fromAccountId: _fromAccountId,
                    toAccountId: _toAccountId,
                    reimbursementAccountId: _reimbursementAccountId,
                    liabilityAccountId: _liabilityAccountId,
                    excludeStats: _excludeStats,
                    excludeBudget: _excludeBudget,
                    onPickDate: _pickDate,
                    onFromAccountChanged:
                        (value) => setState(() => _fromAccountId = value),
                    onToAccountChanged:
                        (value) => setState(() => _toAccountId = value),
                    onReimbursementAccountChanged:
                        (value) =>
                            setState(() => _reimbursementAccountId = value),
                    onLiabilityAccountChanged:
                        (value) => setState(() => _liabilityAccountId = value),
                    onExcludeStatsChanged:
                        (value) => setState(() => _excludeStats = value),
                    onExcludeBudgetChanged:
                        (value) => setState(() => _excludeBudget = value),
                  ),
                  if (keyboardVisible)
                    SizedBox(height: keyboardInset)
                  else ...[
                    const SizedBox(height: AppSpacing.space6),
                    _NumberPad(
                      submitting: _submitting,
                      onInput: _handleNumberInput,
                      onBackspace: _deleteAmountDigit,
                      onClear: _clearForNext,
                      onCancel: () => context.pop(),
                      onSubmit: _submit,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _switchMode(_TransactionFormMode mode) {
    if (mode == _mode) {
      return;
    }
    setState(() {
      _mode = mode;
      _reimbursementAccountId = null;
      if (mode != _TransactionFormMode.expense) {
        _excludeBudget = false;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) {
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (!mounted) {
      return;
    }
    final time = pickedTime ?? TimeOfDay.fromDateTime(_occurredAt);
    setState(() {
      _occurredAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _openCategoryForm(AccountType type, {int? parentId}) {
    final query =
        Uri(
          path: '/categories/new',
          queryParameters: {
            'type': type.name,
            if (parentId != null) 'parentId': parentId.toString(),
          },
        ).toString();
    context.push(query);
  }

  void _handleNumberInput(String value) {
    final current = _amountController.text;
    if (value == '.') {
      if (current.contains('.')) {
        return;
      }
      _amountController.text = current.isEmpty ? '0.' : '$current.';
      return;
    }

    final next = current == '0' ? value : '$current$value';
    final decimalIndex = next.indexOf('.');
    if (decimalIndex >= 0 && next.length - decimalIndex > 3) {
      return;
    }
    _amountController.text = next;
  }

  void _deleteAmountDigit() {
    final text = _amountController.text;
    if (text.isEmpty) {
      return;
    }
    _amountController.text = text.substring(0, text.length - 1);
  }

  void _clearForNext() {
    setState(() {
      _amountController.clear();
      _noteController.clear();
      _reimbursementAccountId = null;
      _excludeStats = false;
      _excludeBudget = false;
      _occurredAt = DateTime.now();
    });
  }

  Future<void> _submit() async {
    final amount = _parsePositiveAmount();
    if (amount == null) {
      _showError('请输入有效金额');
      return;
    }

    final accounts = ref.read(accountListProvider).value ?? const <Account>[];
    final moneyAccounts =
        accounts.where((account) {
          return account.archivedAt == null &&
              (account.type == AccountType.asset ||
                  account.type == AccountType.liability);
        }).toList();
    final liabilityAccounts =
        moneyAccounts
            .where((account) => account.type == AccountType.liability)
            .toList();
    final reimbursementAccounts =
        moneyAccounts
            .where((account) => account.subtype == AccountSubtype.reimbursement)
            .toList();

    final service = ref.read(transactionServiceProvider);
    final note = _blankToNull(_noteController.text);

    setState(() => _submitting = true);
    final Result result;
    switch (_mode) {
      case _TransactionFormMode.expense:
        final expenseCategoryId = _expenseCategoryId;
        final paidFromAccountId = _effectiveId(_fromAccountId, moneyAccounts);
        if (expenseCategoryId == null) {
          setState(() => _submitting = false);
          _showError('请选择支出分类');
          return;
        }
        if (paidFromAccountId == null) {
          setState(() => _submitting = false);
          _showError('请选择支出账户');
          return;
        }
        final reimbursementAccountId = _effectiveId(
          _reimbursementAccountId,
          reimbursementAccounts,
        );
        if (reimbursementAccountId == null) {
          result = await service.createExpense(
            CreateExpenseCommand(
              amount: amount,
              paidFromAccountId: paidFromAccountId,
              expenseAccountId: expenseCategoryId,
              occurredAt: _occurredAt,
              note: note,
              isExcludedFromStats: _excludeStats,
              isExcludedFromBudget: _excludeBudget,
            ),
          );
        } else {
          result = await service.createReimbursementAdvance(
            CreateReimbursementAdvanceCommand(
              amount: amount,
              receivableAccountId: reimbursementAccountId,
              paidFromAccountId: paidFromAccountId,
              expenseCategoryId: expenseCategoryId,
              occurredAt: _occurredAt,
              note: note,
              isExcludedFromStats: _excludeStats,
              isExcludedFromBudget: _excludeBudget,
            ),
          );
        }
      case _TransactionFormMode.income:
        final incomeCategoryId = _incomeCategoryId;
        final receiveAccountId = _effectiveId(_toAccountId, moneyAccounts);
        if (incomeCategoryId == null) {
          setState(() => _submitting = false);
          _showError('请选择收入分类');
          return;
        }
        if (receiveAccountId == null) {
          setState(() => _submitting = false);
          _showError('请选择收入账户');
          return;
        }
        result = await service.createIncome(
          CreateIncomeCommand(
            amount: amount,
            receiveAccountId: receiveAccountId,
            incomeAccountId: incomeCategoryId,
            occurredAt: _occurredAt,
            note: note,
            isExcludedFromStats: _excludeStats,
            isExcludedFromBudget: false,
          ),
        );
      case _TransactionFormMode.transfer:
        final fromAccountId = _effectiveId(_fromAccountId, moneyAccounts);
        final toAccountId = _effectiveId(_toAccountId, moneyAccounts);
        if (fromAccountId == null || toAccountId == null) {
          setState(() => _submitting = false);
          _showError('请选择转出和转入账户');
          return;
        }
        result = await service.createTransfer(
          CreateTransferCommand(
            amount: amount,
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            occurredAt: _occurredAt,
            note: note,
            isExcludedFromStats: _excludeStats,
            isExcludedFromBudget: false,
          ),
        );
      case _TransactionFormMode.borrowing:
        final liabilityAccountId = _effectiveId(
          _liabilityAccountId,
          liabilityAccounts,
        );
        final receiveAccountId =
            _toAccountId != null &&
                    moneyAccounts.any((account) => account.id == _toAccountId)
                ? _toAccountId
                : null;
        if (liabilityAccountId == null) {
          setState(() => _submitting = false);
          _showError('请选择负债账户');
          return;
        }
        result = await service.createBorrowing(
          CreateBorrowingCommand(
            amount: amount,
            liabilityAccountId: liabilityAccountId,
            receiveAccountId: receiveAccountId,
            occurredAt: _occurredAt,
            note: note,
            isExcludedFromStats: _excludeStats,
            isExcludedFromBudget: false,
          ),
        );
    }

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

  Money? _parsePositiveAmount() {
    try {
      final money = Money.parse(_amountController.text);
      return money.minorUnits > 0 ? money : null;
    } on FormatException {
      return null;
    }
  }

  int? _effectiveId(int? selectedId, List<Account> options) {
    if (selectedId != null &&
        options.any((account) => account.id == selectedId)) {
      return selectedId;
    }
    return options.isEmpty ? null : options.first.id;
  }

  String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  MoneySemantic _amountSemantic(_TransactionFormMode mode) {
    return switch (mode) {
      _TransactionFormMode.expense => MoneySemantic.expense,
      _TransactionFormMode.income => MoneySemantic.income,
      _TransactionFormMode.transfer => MoneySemantic.neutral,
      _TransactionFormMode.borrowing => MoneySemantic.income,
    };
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.mode,
    required this.onBack,
    required this.onModeChanged,
  });

  final _TransactionFormMode mode;
  final VoidCallback onBack;
  final ValueChanged<_TransactionFormMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space8,
        AppSpacing.space6,
        AppSpacing.space8,
        AppSpacing.space2,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: '返回',
          ),
          Expanded(child: _ModeTabs(mode: mode, onChanged: onModeChanged)),
          const SizedBox(width: AppSpacing.space48),
        ],
      ),
    );
  }
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.mode, required this.onChanged});

  final _TransactionFormMode mode;
  final ValueChanged<_TransactionFormMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final value in _TransactionFormMode.values)
          _ModeTabItem(
            label: _modeLabel(value),
            selected: value == mode,
            onTap: () => onChanged(value),
          ),
      ],
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
      borderRadius: BorderRadius.circular(AppRadius.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space6,
          vertical: AppSpacing.space6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                color: selected ? colors.primary : colors.onSurfaceVariant,
                fontSize: AppTypography.fontSizeMd,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.space6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: selected ? 40 : AppSpacing.space0,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.radiusSm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleModeHint extends StatelessWidget {
  const _SimpleModeHint({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurface(
      border: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primary.withValues(alpha: 0.12),
              foregroundColor: colors.primary,
              child: Icon(icon),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountNotePanel extends StatelessWidget {
  const _AmountNotePanel({
    required this.amountController,
    required this.noteController,
    required this.semantic,
  });

  final TextEditingController amountController;
  final TextEditingController noteController;
  final MoneySemantic semantic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>();
    final amountColor = switch (semantic) {
      MoneySemantic.expense => financeColors?.expense ?? colors.error,
      MoneySemantic.income => financeColors?.income ?? colors.primary,
      _ => colors.onSurface,
    };

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      color: AppColors.neutral99,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: noteController,
              minLines: 1,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: const InputDecoration(
                hintText: '点击填写备注',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space10),
          SizedBox(
            width: 104,
            child: TextField(
              controller: amountController,
              readOnly: true,
              showCursor: false,
              textAlign: TextAlign.end,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: TextStyle(
                color: amountColor,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: amountColor.withValues(alpha: 0.58),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionOptionsPanel extends StatelessWidget {
  const _TransactionOptionsPanel({
    required this.mode,
    required this.occurredAt,
    required this.moneyAccounts,
    required this.liabilityAccounts,
    required this.reimbursementAccounts,
    required this.fromAccountId,
    required this.toAccountId,
    required this.reimbursementAccountId,
    required this.liabilityAccountId,
    required this.excludeStats,
    required this.excludeBudget,
    required this.onPickDate,
    required this.onFromAccountChanged,
    required this.onToAccountChanged,
    required this.onReimbursementAccountChanged,
    required this.onLiabilityAccountChanged,
    required this.onExcludeStatsChanged,
    required this.onExcludeBudgetChanged,
  });

  final _TransactionFormMode mode;
  final DateTime occurredAt;
  final List<Account> moneyAccounts;
  final List<Account> liabilityAccounts;
  final List<Account> reimbursementAccounts;
  final int? fromAccountId;
  final int? toAccountId;
  final int? reimbursementAccountId;
  final int? liabilityAccountId;
  final bool excludeStats;
  final bool excludeBudget;
  final VoidCallback onPickDate;
  final ValueChanged<int?> onFromAccountChanged;
  final ValueChanged<int?> onToAccountChanged;
  final ValueChanged<int?> onReimbursementAccountChanged;
  final ValueChanged<int?> onLiabilityAccountChanged;
  final ValueChanged<bool> onExcludeStatsChanged;
  final ValueChanged<bool> onExcludeBudgetChanged;

  @override
  Widget build(BuildContext context) {
    final accountLabel = switch (mode) {
      _TransactionFormMode.expense => '支出账户',
      _TransactionFormMode.income => '收入账户',
      _TransactionFormMode.transfer => '转出账户',
      _TransactionFormMode.borrowing => '到账账户',
    };
    final primaryAccountId = switch (mode) {
      _TransactionFormMode.expense => fromAccountId,
      _TransactionFormMode.income => toAccountId,
      _TransactionFormMode.transfer => fromAccountId,
      _TransactionFormMode.borrowing => toAccountId,
    };
    final primaryChanged = switch (mode) {
      _TransactionFormMode.expense => onFromAccountChanged,
      _TransactionFormMode.income => onToAccountChanged,
      _TransactionFormMode.transfer => onFromAccountChanged,
      _TransactionFormMode.borrowing => onToAccountChanged,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickActionChip(
            icon: Icons.schedule,
            label: _formatDateTime(occurredAt),
            selected: false,
            onTap: onPickDate,
          ),
          _AccountSelectorChip(
            icon: Icons.account_balance_wallet_outlined,
            label: accountLabel,
            accounts: moneyAccounts,
            selectedId: primaryAccountId,
            allowNone: mode == _TransactionFormMode.borrowing,
            noneLabel: '不记录到账',
            onChanged: primaryChanged,
          ),
          if (mode == _TransactionFormMode.transfer)
            _AccountSelectorChip(
              icon: Icons.call_received,
              label: '转入账户',
              accounts: moneyAccounts,
              selectedId: toAccountId,
              onChanged: onToAccountChanged,
            ),
          if (mode == _TransactionFormMode.expense)
            _AccountSelectorChip(
              icon: Icons.assignment_return_outlined,
              label: '报销垫付',
              accounts: reimbursementAccounts,
              selectedId: reimbursementAccountId,
              allowNone: true,
              noneLabel: '不报销',
              onChanged: onReimbursementAccountChanged,
            ),
          if (mode == _TransactionFormMode.borrowing)
            _AccountSelectorChip(
              icon: Icons.account_balance_outlined,
              label: '负债账户',
              accounts: liabilityAccounts,
              selectedId: liabilityAccountId,
              onChanged: onLiabilityAccountChanged,
            ),
          _ToggleChip(
            icon: Icons.remove_circle_outline,
            label: '不计收支',
            selected: excludeStats,
            onChanged: onExcludeStatsChanged,
          ),
          if (mode == _TransactionFormMode.expense)
            _ToggleChip(
              icon: Icons.pie_chart_outline,
              label: '不计预算',
              selected: excludeBudget,
              onChanged: onExcludeBudgetChanged,
            ),
        ],
      ),
    );
  }
}

class _AccountSelectorChip extends StatelessWidget {
  const _AccountSelectorChip({
    required this.icon,
    required this.label,
    required this.accounts,
    required this.selectedId,
    required this.onChanged,
    this.allowNone = false,
    this.noneLabel = '无',
  });

  final IconData icon;
  final String label;
  final List<Account> accounts;
  final int? selectedId;
  final ValueChanged<int?> onChanged;
  final bool allowNone;
  final String noneLabel;

  @override
  Widget build(BuildContext context) {
    final selected =
        selectedId == null
            ? null
            : accounts.where((account) => account.id == selectedId).firstOrNull;
    final effective = selected ?? (accounts.isEmpty ? null : accounts.first);
    final text =
        allowNone && selectedId == null
            ? noneLabel
            : effective == null
            ? '$label为空'
            : effective.name;

    return _QuickActionChip(
      icon: icon,
      label: text,
      selected: false,
      onTap: () => _showAccountSheet(context),
    );
  }

  void _showAccountSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (allowNone)
                ListTile(
                  leading: Icon(
                    selectedId == null
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(noneLabel),
                  onTap: () {
                    onChanged(null);
                    Navigator.pop(context);
                  },
                ),
              for (final account in accounts)
                ListTile(
                  leading: Icon(
                    account.id ==
                            (selectedId ??
                                (allowNone ? null : accounts.first.id))
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(account.name),
                  subtitle: Text(accountTypeLabel(account.type)),
                  onTap: () {
                    onChanged(account.id);
                    Navigator.pop(context);
                  },
                ),
              if (accounts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.space20),
                  child: Text(
                    '$label暂无可选账户',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _QuickActionChip(
      icon: icon,
      label: label,
      selected: selected,
      onTap: () => onChanged(!selected),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected ? colors.primary : colors.onSurface;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.space2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        child: Container(
          constraints: const BoxConstraints(minHeight: 30),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space6,
            vertical: AppSpacing.space4,
          ),
          decoration: BoxDecoration(
            color:
                selected
                    ? colors.primary.withValues(alpha: 0.08)
                    : AppColors.neutral99,
            borderRadius: BorderRadius.circular(AppRadius.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: AppSpacing.space2),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 96),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.submitting,
    required this.onInput,
    required this.onBackspace,
    required this.onClear,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool submitting;
  final ValueChanged<String> onInput;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 236,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                for (final row in const [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                  ['再记', '0', '.'],
                ])
                  Row(
                    children: [
                      for (final value in row)
                        Expanded(
                          child: _PadKey(
                            label: value,
                            onTap:
                                value == '再记' ? onClear : () => onInput(value),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              children: [
                _PadKey(icon: Icons.backspace_outlined, onTap: onBackspace),
                const SizedBox(height: AppSpacing.space4),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _ActionKey(
                          label: '取消',
                          onTap: onCancel,
                          filled: false,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Expanded(
                        child: _ActionKey(
                          label: '完成',
                          onTap: onSubmit,
                          filled: true,
                          submitting: submitting,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space2),
      child: Material(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
          child: SizedBox(
            height: 52,
            child: Center(
              child:
                  icon == null
                      ? Text(
                        label!,
                        style: (label == '再记'
                                ? Theme.of(context).textTheme.titleMedium
                                : Theme.of(context).textTheme.titleLarge)
                            ?.copyWith(fontWeight: FontWeight.w600),
                      )
                      : Icon(icon, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionKey extends StatelessWidget {
  const _ActionKey({
    required this.label,
    required this.onTap,
    required this.filled,
    this.submitting = false,
  });

  final String label;
  final bool submitting;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space2),
      child:
          filled
              ? FilledButton(
                onPressed: submitting ? null : onTap,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                  ),
                  backgroundColor: colors.primary,
                ),
                child:
                    submitting
                        ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(label),
              )
              : TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                  ),
                ),
                child: Text(label),
              ),
    );
  }
}

String _modeLabel(_TransactionFormMode mode) {
  return switch (mode) {
    _TransactionFormMode.expense => '支出',
    _TransactionFormMode.income => '收入',
    _TransactionFormMode.transfer => '转账',
    _TransactionFormMode.borrowing => '借入',
  };
}

String _formatDateTime(DateTime date) {
  final now = DateTime.now();
  final time =
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return '今天 $time';
  }
  return '${date.month}/${date.day} $time';
}
