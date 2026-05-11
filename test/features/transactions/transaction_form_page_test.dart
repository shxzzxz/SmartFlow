import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/data/database/database_provider.dart';
import 'package:smartflow/features/transactions/pages/transaction_form_page.dart';

import '../../helpers/test_app_database.dart';

void main() {
  testWidgets('renders seeded expense transaction form content', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: TransactionFormPage()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('支出'), findsOneWidget);
    expect(find.text('食品餐饮'), findsOneWidget);
    expect(find.text('点击填写备注'), findsOneWidget);
    expect(find.text('完成'), findsOneWidget);
  });
}
