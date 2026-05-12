import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/data/database/database_provider.dart';
import 'package:smartflow/design_system/theme/app_theme.dart';
import 'package:smartflow/features/accounts/pages/accounts_page.dart';

import '../../helpers/test_app_database.dart';

void main() {
  testWidgets('renders account groups by fund liability and reimbursement', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light(), home: const AccountsPage()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('资金账户'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('负债账户'), 240);
    expect(find.text('负债账户'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('报销账户'), 240);
    expect(find.text('报销账户'), findsOneWidget);
  });
}
