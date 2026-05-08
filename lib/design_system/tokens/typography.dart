import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const fontFamilyFallback = <String>[
    'Roboto',
    'Noto Sans CJK SC',
    'Microsoft YaHei',
  ];

  static const double fontSizeXs = 12;
  static const double fontSizeSm = 14;
  static const double fontSizeMd = 15;
  static const double fontSizeLg = 20;
  static const double fontSizeXl = 22;

  static const titleWeight = FontWeight.w600;
  static const bodyWeight = FontWeight.w400;
}
