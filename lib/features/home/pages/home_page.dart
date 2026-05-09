import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../design_system/theme/app_theme_extension.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_query_service.dart';
import '../../../widgets/business/account_icon.dart';
import '../../../widgets/business/category_avatar.dart';
import '../../../widgets/business/finance_labels.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _HomeHeader(
              visibleMonth: _visibleMonth,
              onMonthPressed: _pickMonth,
            ),
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('加载失败：$error')),
                data: (transactions) => _HomeContent(
                  visibleMonth: _visibleMonth,
                  transactions: transactions,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/new'),
        tooltip: '新建记账',
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(RemixIcons.add_line),
      ),
    );
  }

  Future<void> _pickMonth() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _visibleMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '选择月份',
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _visibleMonth = DateTime(selected.year, selected.month);
    });
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.visibleMonth, required this.onMonthPressed});

  final DateTime visibleMonth;
  final VoidCallback onMonthPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space10,
        AppSpacing.space8,
        AppSpacing.space12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onMonthPressed,
            borderRadius: BorderRadius.circular(AppRadius.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${visibleMonth.year}年${visibleMonth.month}月',
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: AppTypography.fontSizeLg,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space4),
                  Icon(
                    RemixIcons.arrow_down_s_line,
                    color: colors.onSurfaceVariant,
                    size: AppSpacing.space20,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.go('/transactions'),
            icon: const Icon(RemixIcons.search_line),
            iconSize: 22,
            color: colors.onSurface,
            tooltip: '搜索',
          ),
          IconButton(
            onPressed: () => context.go('/transactions'),
            icon: const Icon(RemixIcons.equalizer_line),
            iconSize: 22,
            color: colors.onSurface,
            tooltip: '筛选',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.visibleMonth, required this.transactions});

  final DateTime visibleMonth;
  final List<TransactionListItem> transactions;

  @override
  Widget build(BuildContext context) {
    final monthItems = _transactionsInMonth(transactions, visibleMonth);
    final groups = _groupByDate(monthItems);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        0,
        AppSpacing.space16,
        AppSpacing.space24 + 56, // 留给 FAB
      ),
      children: [
        _MonthlySummaryCard(items: monthItems),
        const SizedBox(height: AppSpacing.space20),
        if (groups.isEmpty)
          const _EmptyTransactionCard()
        else
          for (final group in groups) ...[
            _TransactionDayCard(group: group),
            const SizedBox(height: AppSpacing.space10),
          ],
      ],
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({required this.items});

  static const _monthlyBudgetMinor = 1000000;

  final List<TransactionListItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final incomeMinor = _sumMinor(items, _isIncomePurpose);
    final expenseMinor = _sumMinor(items, _isExpensePurpose);
    final remainingBudgetMinor = _monthlyBudgetMinor - expenseMinor;
    final remainingPercent =
        (((_monthlyBudgetMinor - expenseMinor) / _monthlyBudgetMinor) * 100)
            .clamp(0, 100)
            .round();

    return AppSurface(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: '本月收入',
                  amountMinor: incomeMinor,
                  amountColor: financeColors.income,
                  caption: '较上月 +8.6%',
                  showSign: true,
                ),
              ),
              _SummaryDivider(color: colors.outlineVariant),
              Expanded(
                child: _SummaryMetric(
                  label: '本月支出',
                  amountMinor: expenseMinor,
                  amountColor: financeColors.expense,
                  caption: '较上月 +12.3%',
                ),
              ),
              _SummaryDivider(color: colors.outlineVariant),
              Expanded(
                child: _SummaryMetric(
                  label: '剩余预算',
                  amountMinor: remainingBudgetMinor,
                  amountColor: colors.primary,
                  caption: '剩余 $remainingPercent%',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space4,
      ),
      color: color.withValues(alpha: 0.6),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.amountMinor,
    required this.amountColor,
    required this.caption,
    this.showSign = false,
  });

  final String label;
  final int amountMinor;
  final Color amountColor;
  final String caption;
  final bool showSign;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontSize: AppTypography.fontSizeXs,
            color: colors.onSurface,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.space6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _formatMonthlyAmount(amountMinor, showSign: showSign),
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              color: amountColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.space6),
        Text(
          caption,
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TransactionDayCard extends StatelessWidget {
  const _TransactionDayCard({required this.group});

  final _TransactionDayGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dividerColor = colors.outlineVariant.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            0,
            AppSpacing.space4,
            AppSpacing.space8,
          ),
          child: _DayHeader(group: group),
        ),
        AppSurface(
          child: Column(
            children: [
              for (var i = 0; i < group.items.length; i++) ...[
                _TransactionRow(item: group.items[i]),
                if (i < group.items.length - 1)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                    ),
                    height: 1,
                    color: dividerColor,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.group});

  final _TransactionDayGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;

    return Row(
      children: [
        Text(
          '${group.date.month}月${group.date.day}日',
          style: textTheme.titleSmall?.copyWith(
            fontSize: AppTypography.fontSizeMd,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(width: AppSpacing.space8),
        Text(
          _weekdayLabel(group.date),
          style: textTheme.bodySmall?.copyWith(
            fontSize: AppTypography.fontSizeXs,
            color: colors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        _DayTotal(
          label: '收入',
          amountMinor: group.incomeMinor,
          color: financeColors.income,
        ),
        const SizedBox(width: AppSpacing.space12),
        _DayTotal(
          label: '支出',
          amountMinor: group.expenseMinor,
          color: financeColors.expense,
        ),
      ],
    );
  }
}

class _DayTotal extends StatelessWidget {
  const _DayTotal({
    required this.label,
    required this.amountMinor,
    required this.color,
  });

  final String label;
  final int amountMinor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text.rich(
      TextSpan(
        text: '$label ',
        style: textTheme.bodySmall?.copyWith(
          fontSize: AppTypography.fontSizeXs,
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
        children: [
          TextSpan(
            text: _formatCurrency(amountMinor),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: AppTypography.fontSizeXs,
            ),
          ),
        ],
      ),
      maxLines: 1,
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final amountColor = _amountColor(colors, financeColors, item.businessPurpose);
    final title = _transactionPrimaryLabel(item);
    final note = item.note?.trim();
    final hasNote = note != null && note.isNotEmpty;
    final subtitle = hasNote
        ? '${_formatTime(item.occurredAt)}  $note'
        : _formatTime(item.occurredAt);

    return InkWell(
      onTap: () => context.push('/transactions/${item.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CategoryAvatar(
              iconKey: _resolveCategoryIconKey(item),
              fallback: _categoryAvatarFallback(item.businessPurpose),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: textTheme.titleSmall?.copyWith(
                            fontSize: AppTypography.fontSizeMd,
                            fontWeight: FontWeight.w400,
                            color: colors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (_needsBadge(item.businessPurpose)) ...[
                        const SizedBox(width: AppSpacing.space6),
                        _PurposeBadge(purpose: item.businessPurpose),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: AppTypography.fontSizeXs,
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTransactionAmount(item),
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: AppTypography.fontSizeMd,
                      color: amountColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  _AccountLine(item: item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountLine extends ConsumerWidget {
  const _AccountLine({required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accountText = _transactionAccountLabel(item);
    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final iconKey = _resolveIconKey(item, accounts);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AccountIcon(iconKey: iconKey, size: 12),
        const SizedBox(width: AppSpacing.space4),
        Flexible(
          child: Text(
            accountText.isEmpty ? '未分配账户' : accountText,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: AppTypography.fontSizeXs,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

String? _resolveIconKey(TransactionListItem item, List<Account> accounts) {
  final accountId = switch (item.businessPurpose) {
    BusinessPurpose.dailyExpense ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose.debtRepayment =>
      item.flowOutAccountId ?? item.flowInAccountId,
    _ => item.flowInAccountId ?? item.flowOutAccountId,
  };
  if (accountId == null) return null;
  for (final account in accounts) {
    if (account.id == accountId) return account.iconKey;
  }
  return null;
}

class _PurposeBadge extends StatelessWidget {
  const _PurposeBadge({required this.purpose});

  final BusinessPurpose purpose;

  @override
  Widget build(BuildContext context) {
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final color = _purposeAccentColor(financeColors, purpose);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.radiusSm),
      ),
      child: Text(
        _shortPurposeLabel(purpose),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmptyTransactionCard extends StatelessWidget {
  const _EmptyTransactionCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurface(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Row(
          children: [
            Icon(RemixIcons.file_list_3_line, color: colors.onSurfaceVariant),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Text(
                '本月暂无交易记录',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionDayGroup {
  const _TransactionDayGroup({
    required this.date,
    required this.items,
    required this.incomeMinor,
    required this.expenseMinor,
  });

  final DateTime date;
  final List<TransactionListItem> items;
  final int incomeMinor;
  final int expenseMinor;
}

List<TransactionListItem> _transactionsInMonth(
  List<TransactionListItem> transactions,
  DateTime month,
) {
  return transactions
      .where(
        (item) =>
            item.occurredAt.year == month.year &&
            item.occurredAt.month == month.month,
      )
      .toList();
}

List<_TransactionDayGroup> _groupByDate(List<TransactionListItem> items) {
  final groups = <DateTime, List<TransactionListItem>>{};
  for (final item in items) {
    final date = DateTime(
      item.occurredAt.year,
      item.occurredAt.month,
      item.occurredAt.day,
    );
    groups.putIfAbsent(date, () => []).add(item);
  }

  final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final date in dates)
      _TransactionDayGroup(
        date: date,
        items: groups[date]!,
        incomeMinor: _sumMinor(groups[date]!, _isIncomePurpose),
        expenseMinor: _sumMinor(groups[date]!, _isExpensePurpose),
      ),
  ];
}

int _sumMinor(
  Iterable<TransactionListItem> items,
  bool Function(BusinessPurpose purpose) predicate,
) {
  return items
      .where((item) => predicate(item.businessPurpose))
      .fold(0, (sum, item) => sum + item.primaryAmount.minorUnits.abs());
}

bool _isIncomePurpose(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.dailyIncome ||
    BusinessPurpose.refund ||
    BusinessPurpose.reimbursementReceipt ||
    BusinessPurpose.borrowing => true,
    _ => false,
  };
}

bool _isExpensePurpose(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.dailyExpense ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose.debtRepayment => true,
    _ => false,
  };
}

bool _needsBadge(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.refund ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose.reimbursementReceipt ||
    BusinessPurpose.reimbursementClose => true,
    _ => false,
  };
}

String _shortPurposeLabel(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.refund => '退',
    BusinessPurpose.reimbursementAdvance => '报',
    BusinessPurpose.reimbursementReceipt => '收',
    BusinessPurpose.reimbursementClose => '结',
    _ => transactionPurposeLabel(purpose),
  };
}

String? _resolveCategoryIconKey(TransactionListItem item) {
  return switch (item.businessPurpose) {
    BusinessPurpose.dailyExpense ||
    BusinessPurpose.dailyIncome => item.categoryIconKey,
    BusinessPurpose.transfer => 'transfer',
    BusinessPurpose.debtRepayment ||
    BusinessPurpose.borrowing => 'loan',
    BusinessPurpose.refund ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose.reimbursementReceipt ||
    BusinessPurpose.reimbursementClose ||
    BusinessPurpose.openingBalance ||
    BusinessPurpose.balanceAdjustment => null,
  };
}

CategoryAvatarFallback _categoryAvatarFallback(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.dailyIncome ||
    BusinessPurpose.refund ||
    BusinessPurpose.reimbursementReceipt ||
    BusinessPurpose.borrowing => CategoryAvatarFallback.income,
    BusinessPurpose.dailyExpense ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose.debtRepayment => CategoryAvatarFallback.expense,
    BusinessPurpose.transfer => CategoryAvatarFallback.transfer,
    _ => CategoryAvatarFallback.generic,
  };
}

String _transactionPrimaryLabel(TransactionListItem item) {
  return switch (item.businessPurpose) {
    BusinessPurpose.dailyExpense || BusinessPurpose.dailyIncome =>
      _cleanText(item.categoryName) ??
          transactionPurposeLabel(item.businessPurpose),
    _ => transactionPurposeLabel(item.businessPurpose),
  };
}

String _transactionAccountLabel(TransactionListItem item) {
  return switch (item.businessPurpose) {
    BusinessPurpose.dailyExpense =>
      _cleanText(item.flowOutAccountName) ?? _firstAccountName(item),
    BusinessPurpose.dailyIncome =>
      _cleanText(item.flowInAccountName) ?? _firstAccountName(item),
    _ => _flowAccountLabel(item),
  };
}

String _flowAccountLabel(TransactionListItem item) {
  final flowOut = _cleanText(item.flowOutAccountName);
  final flowIn = _cleanText(item.flowInAccountName);
  if (flowOut != null && flowIn != null) {
    return '$flowOut → $flowIn';
  }
  return flowOut ?? flowIn ?? _firstAccountName(item);
}

String _firstAccountName(TransactionListItem item) {
  final parts = item.accountNames
      .split('/')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return '';
  }
  return parts.first;
}

String? _cleanText(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}


Color _amountColor(
  ColorScheme colors,
  AppThemeExtension financeColors,
  BusinessPurpose purpose,
) {
  return switch (purpose) {
    BusinessPurpose.dailyIncome ||
    BusinessPurpose.refund ||
    BusinessPurpose.reimbursementReceipt ||
    BusinessPurpose.borrowing => financeColors.income,
    BusinessPurpose.dailyExpense ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose.debtRepayment => financeColors.expense,
    BusinessPurpose.transfer ||
    BusinessPurpose.openingBalance ||
    BusinessPurpose.balanceAdjustment ||
    BusinessPurpose.reimbursementClose => colors.onSurface,
  };
}

Color _purposeAccentColor(AppThemeExtension colors, BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.dailyIncome ||
    BusinessPurpose.refund ||
    BusinessPurpose.reimbursementReceipt ||
    BusinessPurpose.borrowing => colors.income,
    BusinessPurpose.dailyExpense ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose.debtRepayment => colors.expense,
    BusinessPurpose.transfer => colors.transfer,
    BusinessPurpose.openingBalance ||
    BusinessPurpose.balanceAdjustment => colors.equity,
    BusinessPurpose.reimbursementClose => colors.info,
  };
}

String _formatCurrency(int minorUnits) {
  return Money(minorUnits: minorUnits.abs()).format();
}

String _formatMonthlyAmount(int minorUnits, {required bool showSign}) {
  final formatted = Money(minorUnits: minorUnits.abs()).format();
  if (!showSign) return formatted;
  return minorUnits >= 0 ? formatted : '-$formatted';
}

String _formatTransactionAmount(TransactionListItem item) {
  final prefix = switch (item.businessPurpose) {
    BusinessPurpose.dailyIncome ||
    BusinessPurpose.refund ||
    BusinessPurpose.reimbursementReceipt ||
    BusinessPurpose.borrowing => '+',
    BusinessPurpose.dailyExpense ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose.debtRepayment => '-',
    _ => '',
  };
  return '$prefix${_formatCurrency(item.primaryAmount.minorUnits)}';
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _weekdayLabel(DateTime value) {
  const labels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return labels[value.weekday - 1];
}
