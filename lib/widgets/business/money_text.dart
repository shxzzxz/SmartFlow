import 'package:flutter/material.dart';

import '../../core/money/money.dart';
import '../../design_system/theme/app_theme_extension.dart';

class MoneyText extends StatelessWidget {
  const MoneyText({
    required this.money,
    super.key,
    this.style,
    this.showSign = false,
    this.semantic,
  });

  final Money money;
  final TextStyle? style;
  final bool showSign;
  final MoneySemantic? semantic;

  @override
  Widget build(BuildContext context) {
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final color = switch (semantic) {
      MoneySemantic.income => financeColors.income,
      MoneySemantic.expense => financeColors.expense,
      MoneySemantic.asset => financeColors.asset,
      MoneySemantic.liability => financeColors.liability,
      MoneySemantic.equity => financeColors.equity,
      null => null,
    };
    final sign = showSign && money.minorUnits > 0 ? '+' : '';

    return Text(
      '$sign${money.format()}',
      style: style?.copyWith(color: color) ?? TextStyle(color: color),
      textAlign: TextAlign.end,
    );
  }
}

enum MoneySemantic {
  income,
  expense,
  asset,
  liability,
  equity,
}
