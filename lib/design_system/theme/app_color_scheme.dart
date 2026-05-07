import 'package:flutter/material.dart';

import '../tokens/colors.dart';

abstract final class AppColorSchemes {
  static ColorScheme light() {
    return ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
    );
  }

  static ColorScheme dark() {
    return ColorScheme.fromSeed(
      seedColor: AppColors.brandDark,
      brightness: Brightness.dark,
    );
  }
}
