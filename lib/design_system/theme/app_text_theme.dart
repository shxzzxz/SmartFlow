import 'package:flutter/material.dart';

import '../tokens/typography.dart';

abstract final class AppTextThemes {
  static TextTheme textTheme(ColorScheme colors) {
    return Typography.material2021().black.apply(
      bodyColor: colors.onSurface,
      displayColor: colors.onSurface,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
    );
  }
}
