import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/app/app.dart';
import 'package:smartflow/data/database/database_provider.dart';

import '../helpers/test_app_database.dart';

void main() {
  testWidgets('renders the stage 2 app shell', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const SmartFlowApp(),
      ),
    );
    await tester.pump();

    expect(find.text('SmartFlow'), findsOneWidget);
    expect(find.text('净资产'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('记一笔'), findsWidgets);
  });
}
