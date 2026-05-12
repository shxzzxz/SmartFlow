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
    await _pumpTransactionForm(tester);

    expect(find.text('支出'), findsOneWidget);
    expect(find.text('食品餐饮'), findsOneWidget);
    expect(find.text('点击填写备注'), findsOneWidget);
    expect(find.text('完成'), findsOneWidget);
  });

  testWidgets('transfer mode moves account pickers to main content', (
    tester,
  ) async {
    await _pumpTransactionForm(tester);

    await tester.tap(find.text('转账'));
    await tester.pump();

    expect(find.text('转出账户'), findsOneWidget);
    expect(find.text('转入账户'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    expect(find.text('不计收支'), findsNothing);
    expect(find.textContaining('报销账户'), findsNothing);
  });

  testWidgets('borrowing mode shows fund account picker in main content', (
    tester,
  ) async {
    await _pumpTransactionForm(tester);

    await tester.tap(find.text('借入'));
    await tester.pump();

    expect(find.text('借入账户'), findsOneWidget);
    expect(find.text('借出账户'), findsOneWidget);
    expect(find.textContaining('负债账户'), findsNothing);
    expect(find.text('不计收支'), findsNothing);
    expect(find.textContaining('报销账户'), findsNothing);
  });
}

Future<void> _pumpTransactionForm(WidgetTester tester) async {
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
}
