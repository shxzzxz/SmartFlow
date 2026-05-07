import 'package:flutter/material.dart';

import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/theme/app_theme_extension.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('SmartFlow')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('本地复式记账', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.space8),
              Text(
                '工程骨架已就绪，下一阶段将接入账户、分录和交易过账。',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
              Wrap(
                spacing: AppSpacing.space8,
                runSpacing: AppSpacing.space8,
                children: [
                  _StatusChip(
                    label: 'Material 3',
                    color: financeColors.info,
                  ),
                  _StatusChip(
                    label: 'Riverpod',
                    color: financeColors.transfer,
                  ),
                  _StatusChip(
                    label: 'drift',
                    color: financeColors.asset,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(Icons.check_circle, color: color, size: 18),
      label: Text(label),
      backgroundColor: colors.surfaceContainerHighest,
      side: BorderSide(color: colors.outlineVariant),
    );
  }
}
