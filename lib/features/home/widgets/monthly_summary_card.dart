import 'package:flutter/material.dart';

import '../../../design_system/theme/app_theme_extension.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/services/transaction_query_service.dart';
import '../view_models/transaction_row_presentation.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({required this.summary, super.key});

  static const _monthlyBudgetMinor = 1000000;

  final CashflowSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final incomeMinor = summary.income.minorUnits;
    final expenseMinor = summary.expense.minorUnits;
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
            formatMonthlyAmount(amountMinor, showSign: showSign),
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
