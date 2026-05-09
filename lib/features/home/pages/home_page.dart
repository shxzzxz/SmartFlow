import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../design_system/theme/app_theme_extension.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_query_service.dart';
import '../../../widgets/business/category_icon.dart';
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: transactionsAsync.when(
          loading:
              () => _HomeLoadingView(
                visibleMonth: _visibleMonth,
                onMonthPressed: _pickMonth,
              ),
          error:
              (error, stackTrace) => _HomeErrorView(
                visibleMonth: _visibleMonth,
                error: error,
                onMonthPressed: _pickMonth,
              ),
          data:
              (transactions) => _HomeContent(
                visibleMonth: _visibleMonth,
                transactions: transactions,
                onMonthPressed: _pickMonth,
              ),
        ),
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

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.visibleMonth,
    required this.transactions,
    required this.onMonthPressed,
  });

  final DateTime visibleMonth;
  final List<TransactionListItem> transactions;
  final VoidCallback onMonthPressed;

  @override
  Widget build(BuildContext context) {
    final monthItems = _transactionsInMonth(transactions, visibleMonth);
    final groups = _groupByDate(monthItems);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space14,
        AppSpacing.space16,
        AppSpacing.space16,
      ),
      children: [
        _HomeHeader(visibleMonth: visibleMonth, onMonthPressed: onMonthPressed),
        const SizedBox(height: AppSpacing.space14),
        _MonthlySummaryCard(items: monthItems),
        const SizedBox(height: AppSpacing.space10),
        const _NewTransactionButton(),
        const SizedBox(height: AppSpacing.space16),
        if (groups.isEmpty)
          const _EmptyTransactionCard()
        else
          for (final group in groups) ...[
            _TransactionDaySection(group: group),
            const SizedBox(height: AppSpacing.space16),
          ],
      ],
    );
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

    return Row(
      children: [
        InkWell(
          onTap: onMonthPressed,
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${visibleMonth.year}年${visibleMonth.month}月',
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: AppTypography.fontSizeXl,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.space4),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: colors.onSurface,
                  size: AppSpacing.space20,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => context.go('/transactions'),
          icon: const Icon(Icons.search_rounded),
          iconSize: 27,
          tooltip: '搜索',
        ),
        IconButton(
          onPressed: () => context.go('/transactions'),
          icon: const Icon(Icons.filter_alt_outlined),
          iconSize: 27,
          tooltip: '筛选',
        ),
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
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16,
          AppSpacing.space18,
          AppSpacing.space16,
          AppSpacing.space18,
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
                ),
              ),
              const SizedBox(width: AppSpacing.space16),
              Expanded(
                child: _SummaryMetric(
                  label: '本月支出',
                  amountMinor: expenseMinor,
                  amountColor: financeColors.expense,
                  caption: '较上月 +12.3%',
                ),
              ),
              const SizedBox(width: AppSpacing.space16),
              Expanded(
                child: _SummaryMetric(
                  label: '剩余预算',
                  amountMinor: remainingBudgetMinor,
                  amountColor: colors.onSurface,
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

class _NewTransactionButton extends StatelessWidget {
  const _NewTransactionButton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurface(
      border: true,
      child: InkWell(
        onTap: () => context.push('/transactions/new'),
        borderRadius: BorderRadius.circular(AppRadius.radiusXl),
        child: SizedBox(
          height: 42,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_card_outlined,
                color: colors.primary,
                size: AppSpacing.space20,
              ),
              const SizedBox(width: AppSpacing.space8),
              Text(
                '新建记账',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontSize: AppTypography.fontSizeSm,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.amountMinor,
    required this.amountColor,
    required this.caption,
  });

  final String label;
  final int amountMinor;
  final Color amountColor;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  fontSize: AppTypography.fontSizeSm,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _formatCurrency(amountMinor),
            style: textTheme.titleMedium?.copyWith(
              fontSize: AppTypography.fontSizeLg,
              color: amountColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.space10),
        Text(
          caption,
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: AppTypography.fontSizeSm,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TransactionDaySection extends StatelessWidget {
  const _TransactionDaySection({required this.group});

  final _TransactionDayGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final sectionTextStyle = textTheme.titleSmall?.copyWith(
      fontSize: AppTypography.fontSizeSm,
      fontWeight: FontWeight.w500,
    );

    return Column(
      children: [
        Row(
          children: [
            Text(
              '${group.date.month}月${group.date.day}日',
              style: sectionTextStyle?.copyWith(color: colors.onSurface),
            ),
            const SizedBox(width: AppSpacing.space16),
            Text(
              _weekdayLabel(group.date),
              style: sectionTextStyle?.copyWith(color: colors.onSurfaceVariant),
            ),
            const Spacer(),
            _DayTotal(
              label: '收入',
              amountMinor: group.incomeMinor,
              color: financeColors.income,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space8,
              ),
              child: Text(
                '·',
                style: sectionTextStyle?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            _DayTotal(
              label: '支出',
              amountMinor: group.expenseMinor,
              color: financeColors.expense,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
        AppSurface(
          border: true,
          child: Column(
            children: [
              for (final item in group.items) _TransactionItemTile(item: item),
            ],
          ),
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
    final textTheme = Theme.of(context).textTheme;

    return Text.rich(
      TextSpan(
        text: label,
        style: textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: AppTypography.fontSizeSm,
          fontWeight: FontWeight.w400,
        ),
        children: [
          TextSpan(
            text: _formatCurrency(amountMinor),
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      maxLines: 1,
    );
  }
}

class _TransactionItemTile extends StatelessWidget {
  const _TransactionItemTile({required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final amountColor = _amountColor(colors, financeColors, item.businessPurpose);
    final title = _transactionPrimaryLabel(item);

    return InkWell(
      onTap: () => context.push('/transactions/${item.id}'),
      borderRadius: BorderRadius.circular(AppRadius.radiusXl),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space14,
          AppSpacing.space8,
          AppSpacing.space14,
          AppSpacing.space8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CategoryIcon(
              iconKey: _resolveCategoryIconKey(item),
              fallback: _categoryIconFallback(item.businessPurpose),
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
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space8),
                      if (_needsBadge(item.businessPurpose))
                        _PurposeBadge(purpose: item.businessPurpose),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    [
                      _formatTime(item.occurredAt),
                      if (item.note?.trim().isNotEmpty == true)
                        item.note!.trim(),
                    ].join('  '),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: AppTypography.fontSizeXs,
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 132),
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

class _AccountLine extends StatelessWidget {
  const _AccountLine({required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accountText = _transactionAccountLabel(item);
    final iconAsset = _accountIconAsset(accountText);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          iconAsset,
          width: AppTypography.fontSizeXs,
          height: AppTypography.fontSizeXs,
        ),
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
          ),
        ),
      ],
    );
  }
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
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.radiusSm),
      ),
      child: Text(
        transactionPurposeLabel(purpose),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: AppTypography.fontSizeXs,
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

    return Card(
      margin: EdgeInsets.zero,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radiusLg),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: colors.onSurfaceVariant),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Text(
                '本月暂无交易记录',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView({
    required this.visibleMonth,
    required this.onMonthPressed,
  });

  final DateTime visibleMonth;
  final VoidCallback onMonthPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space24),
      children: [
        _HomeHeader(visibleMonth: visibleMonth, onMonthPressed: onMonthPressed),
        const SizedBox(height: AppSpacing.space24),
        const Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.space24),
            child: LinearProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({
    required this.visibleMonth,
    required this.error,
    required this.onMonthPressed,
  });

  final DateTime visibleMonth;
  final Object error;
  final VoidCallback onMonthPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space24),
      children: [
        _HomeHeader(visibleMonth: visibleMonth, onMonthPressed: onMonthPressed),
        const SizedBox(height: AppSpacing.space24),
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.error_outline_rounded),
            title: const Text('数据加载失败'),
            subtitle: Text('$error'),
          ),
        ),
      ],
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

CategoryIconFallback _categoryIconFallback(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.dailyIncome => CategoryIconFallback.income,
    BusinessPurpose.dailyExpense => CategoryIconFallback.expense,
    _ => CategoryIconFallback.generic,
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
  final parts =
      item.accountNames
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

String _accountIconAsset(String accountNames) {
  if (accountNames.contains('支付宝')) {
    return 'assets/icons/account/alipay.svg';
  }
  if (accountNames.contains('微信')) {
    return 'assets/icons/account/wechat_pay.svg';
  }
  if (accountNames.contains('招商')) {
    return 'assets/icons/account/cmb_credit_card.svg';
  }
  if (accountNames.contains('中国银行') || accountNames.contains('储蓄')) {
    return 'assets/icons/account/boc_debit_card.svg';
  }
  return 'assets/icons/account/boc_debit_card.svg';
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
