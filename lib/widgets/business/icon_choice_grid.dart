import 'package:flutter/material.dart';

import '../../design_system/tokens/radius.dart';
import '../../design_system/tokens/spacing.dart';
import '../../design_system/tokens/typography.dart';

class IconChoiceGrid extends StatelessWidget {
  const IconChoiceGrid({
    required this.choices,
    required this.selectedKey,
    required this.onChanged,
    super.key,
    this.crossAxisCount = 5,
    this.maxVisibleRows = 4,
    this.iconSize = 32,
    this.bubbleSize = 44,
    this.tileMainExtent = 70,
    this.mainAxisSpacing = AppSpacing.space8,
    this.crossAxisSpacing = AppSpacing.space16,
    this.bubbleColor,
    this.selectedBubbleColor,
  });

  final List<IconChoiceGridItem> choices;
  final String? selectedKey;
  final ValueChanged<String> onChanged;
  final int crossAxisCount;
  final int maxVisibleRows;
  final double iconSize;
  final double bubbleSize;
  final double tileMainExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Color? bubbleColor;
  final Color? selectedBubbleColor;

  @override
  Widget build(BuildContext context) {
    if (choices.isEmpty) {
      return const SizedBox.shrink();
    }

    final rowCount = (choices.length / crossAxisCount).ceil();
    final height =
        maxVisibleRows * tileMainExtent +
        (maxVisibleRows - 1) * mainAxisSpacing;

    return SizedBox(
      height: height,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        primary: false,
        itemCount: choices.length,
        physics:
            rowCount > maxVisibleRows
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisExtent: tileMainExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        ),
        itemBuilder: (context, index) {
          final choice = choices[index];
          return _IconChoiceTile(
            choice: choice,
            selected: choice.iconKey == selectedKey,
            iconSize: iconSize,
            bubbleSize: bubbleSize,
            bubbleColor: bubbleColor,
            selectedBubbleColor: selectedBubbleColor,
            onTap: () => onChanged(choice.iconKey),
          );
        },
      ),
    );
  }
}

class IconChoiceGridItem {
  const IconChoiceGridItem({
    required this.iconKey,
    required this.label,
    required this.iconBuilder,
    this.accentColor,
  });

  final String iconKey;
  final String label;
  final Widget Function(BuildContext context, double size) iconBuilder;
  final Color? accentColor;
}

class _IconChoiceTile extends StatelessWidget {
  const _IconChoiceTile({
    required this.choice,
    required this.selected,
    required this.iconSize,
    required this.bubbleSize,
    required this.bubbleColor,
    required this.selectedBubbleColor,
    required this.onTap,
  });

  final IconChoiceGridItem choice;
  final bool selected;
  final double iconSize;
  final double bubbleSize;
  final Color? bubbleColor;
  final Color? selectedBubbleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radiusLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: bubbleSize,
            height: bubbleSize,
            decoration: BoxDecoration(
              color:
                  selected
                      ? selectedBubbleColor ??
                          bubbleColor ??
                          colors.primary.withValues(alpha: 0.12)
                      : bubbleColor ?? Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(child: choice.iconBuilder(context, iconSize)),
          ),
          const SizedBox(height: AppSpacing.space6),
          Text(
            choice.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontSize: AppTypography.fontSizeXs,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
