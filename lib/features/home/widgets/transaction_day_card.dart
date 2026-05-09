import 'package:flutter/material.dart';

import '../../../design_system/theme/app_theme_extension.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../view_models/home_transaction_group.dart';
import '../view_models/transaction_row_presentation.dart';
import 'transaction_row.dart';

class TransactionDayCard extends StatelessWidget {
  const TransactionDayCard({required this.group, super.key});

  final HomeTransactionDayGroup group;

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
                TransactionRow(item: group.items[i]),
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

  final HomeTransactionDayGroup group;

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
          weekdayLabel(group.date),
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
            text: formatMinorAmount(amountMinor),
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
