import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/data/database/app_database.dart';
import 'package:smartflow/domain/enums/accounting_enums.dart';

import '../../helpers/test_app_database.dart';

void main() {
  group('stage 1 database schema', () {
    late AppDatabase database;

    setUp(() {
      database = createTestDatabase();
    });

    tearDown(() async {
      await database.close();
    });

    test('creates core accounting tables', () async {
      final rows = await database
          .customSelect(
            "SELECT name FROM sqlite_master "
            "WHERE type = 'table' AND name IN "
            "('accounts', 'transactions', 'transaction_details', "
            "'entries', 'budgets') "
            "ORDER BY name",
          )
          .get();

      expect(
        rows.map((row) => row.read<String>('name')),
        ['accounts', 'budgets', 'entries', 'transaction_details', 'transactions'],
      );
    });

    test('does not rely on sqlite foreign key checks', () async {
      final row = await database.customSelect('PRAGMA foreign_keys').getSingle();

      expect(row.read<int>('foreign_keys'), 0);
    });

    test('enforces total and category budget uniqueness', () async {
      final accountId = await database.into(database.accounts).insert(
            AccountsCompanion.insert(
              name: 'Food',
              accountType: AccountType.expense,
              currencyCode: 'CNY',
            ),
          );

      await database.into(database.budgets).insert(
            BudgetsCompanion.insert(
              monthKey: 202605,
              accountId: Value(null),
              amountMinor: 100000,
              currencyCode: 'CNY',
            ),
          );
      await database.into(database.budgets).insert(
            BudgetsCompanion.insert(
              monthKey: 202605,
              accountId: Value(accountId),
              amountMinor: 50000,
              currencyCode: 'CNY',
            ),
          );

      expect(
        () => database.into(database.budgets).insert(
              BudgetsCompanion.insert(
                monthKey: 202605,
                accountId: Value(null),
                amountMinor: 120000,
                currencyCode: 'CNY',
              ),
            ),
        throwsA(isA<Exception>()),
      );
      expect(
        () => database.into(database.budgets).insert(
              BudgetsCompanion.insert(
                monthKey: 202605,
                accountId: Value(accountId),
                amountMinor: 80000,
                currencyCode: 'CNY',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
