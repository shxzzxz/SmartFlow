import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const fontFamilyFallback = <String>[
    'Roboto',
    'Noto Sans CJK SC',
    'Microsoft YaHei',
  ];

  static const titleWeight = FontWeight.w600;
  static const bodyWeight = FontWeight.w400;
}
