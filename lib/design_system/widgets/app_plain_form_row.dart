import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class AppPlainFormRow extends StatelessWidget {
  const AppPlainFormRow({
    required this.label,
    required this.child,
    super.key,
    this.onTap,
    this.labelWidth = 92,
    this.minHeight = 70,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final double labelWidth;
  final double minHeight;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(label, style: context.appTextStyles.formValue),
          ),
          Expanded(child: child),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

class AppPlainValueText extends StatelessWidget {
  const AppPlainValueText({
    required this.text,
    super.key,
    this.textAlign = TextAlign.left,
  });

  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        style: context.appTextStyles.formPlainValue,
      ),
    );
  }
}
