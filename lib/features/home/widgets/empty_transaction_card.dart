import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_surface.dart';

class EmptyTransactionCard extends StatelessWidget {
  const EmptyTransactionCard({super.key});

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
