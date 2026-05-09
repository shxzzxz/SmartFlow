import 'package:flutter/material.dart';

import '../../../core/money/money.dart';
import '../../../design_system/theme/app_theme_extension.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../domain/services/transaction_query_service.dart';

/// 主交易行的"聚合 progress + 统计标记"badge 组。
///
/// 表达：退/报/利/费/差收/差支/不计统计/不计预算。
/// 金额为零的不显示；该 widget 自身只在有 badge 时占位，对外不再加额外间距。
class TransactionProgressBadges extends StatelessWidget {
  const TransactionProgressBadges({required this.item, super.key});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final badges = _resolveBadges(financeColors, item);
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AppSpacing.space6,
      runSpacing: 4,
      children: [for (final badge in badges) _BadgeChip(badge: badge)],
    );
  }
}

class _BadgeData {
  const _BadgeData({required this.label, required this.color});

  final String label;
  final Color color;
}

List<_BadgeData> _resolveBadges(
  AppThemeExtension financeColors,
  TransactionListItem item,
) {
  final badges = <_BadgeData>[];

  if (item.isExcludedFromStats) {
    badges.add(_BadgeData(label: '不计统计', color: financeColors.equity));
  }
  if (item.isExcludedFromBudget) {
    badges.add(_BadgeData(label: '不计预算', color: financeColors.equity));
  }
  if (item.refundedTotal != null) {
    badges.add(
      _BadgeData(
        label: '退 ${_format(item.refundedTotal!)}',
        color: financeColors.income,
      ),
    );
  }
  if (item.reimbursementReceivedTotal != null) {
    badges.add(
      _BadgeData(
        label: '报 ${_format(item.reimbursementReceivedTotal!)}',
        color: financeColors.info,
      ),
    );
  }
  if (item.repaymentInterest != null) {
    badges.add(
      _BadgeData(
        label: '利 ${_format(item.repaymentInterest!)}',
        color: financeColors.expense,
      ),
    );
  }
  if (item.repaymentFee != null) {
    badges.add(
      _BadgeData(
        label: '费 ${_format(item.repaymentFee!)}',
        color: financeColors.expense,
      ),
    );
  }
  if (item.reimbursementGapIncome != null) {
    badges.add(
      _BadgeData(
        label: '差收 ${_format(item.reimbursementGapIncome!)}',
        color: financeColors.income,
      ),
    );
  }
  if (item.reimbursementGapExpense != null) {
    badges.add(
      _BadgeData(
        label: '差支 ${_format(item.reimbursementGapExpense!)}',
        color: financeColors.expense,
      ),
    );
  }

  return badges;
}

String _format(Money money) {
  return Money(
    minorUnits: money.minorUnits.abs(),
    currency: money.currency,
  ).format();
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.badge});

  final _BadgeData badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badge.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.radiusSm),
      ),
      child: Text(
        badge.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: badge.color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
