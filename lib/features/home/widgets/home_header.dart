import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.visibleMonth,
    required this.onMonthPressed,
    super.key,
  });

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
