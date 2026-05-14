import 'package:flutter/material.dart';

import '../../../design_system/theme/app_text_styles.dart';
import '../../../design_system/theme/app_theme_extension.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/services/financial_metrics_service.dart';
import '../view_models/transaction_row_presentation.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({required this.comparison, super.key});

  static const _monthlyBudgetMinor = 1000000;

  final CashflowComparison comparison;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final summary = comparison.current;
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
                  caption: formatPeriodChangeCaption(comparison.incomeChange),
                  showSign: true,
                ),
              ),
              _SummaryDivider(color: colors.outlineVariant),
              Expanded(
                child: _SummaryMetric(
                  label: '本月支出',
                  amountMinor: expenseMinor,
                  amountColor: financeColors.expense,
                  caption: formatPeriodChangeCaption(comparison.expenseChange),
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

String formatPeriodChangeCaption(PeriodChange change) {
  if (change.isFlat) {
    return '与上月持平';
  }
  if (change.isNewValue) {
    return '较上月新增';
  }
  final ratio = change.ratio;
  if (ratio == null) {
    return '上月无记录';
  }
  final sign = ratio >= 0 ? '+' : '-';
  return '较上月 $sign${(ratio.abs() * 100).toStringAsFixed(1)}%';
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
    final textStyles = context.appTextStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textStyles.metricLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.space6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatMonthlyAmount(amountMinor, showSign: showSign),
            style: textStyles.metricValue.copyWith(color: amountColor),
            maxLines: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.space6),
        Text(
          caption,
          style: textStyles.metricSupporting.copyWith(
            color: colors.onSurfaceVariant,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
