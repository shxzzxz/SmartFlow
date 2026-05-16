import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/design_system/theme/app_theme.dart';
import 'package:smartflow/features/accounts/pages/account_form_page.dart';

void main() {
  testWidgets('loan account form only shows repayment day field', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AccountFormPage(),
        ),
      ),
    );

    await tester.tap(find.text('贷款'));
    await tester.pump();

    expect(find.text('还款日'), findsWidgets);
    expect(find.text('出账还款日'), findsNothing);
    expect(find.text('出账日'), findsNothing);
  });
}
