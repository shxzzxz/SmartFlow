import 'package:drift/drift.dart';

import '../app_database.dart';
import '../builtin_data.dart';

MigrationStrategy buildMigrationStrategy(AppDatabase database) {
  return MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await database.customStatement(
        'CREATE UNIQUE INDEX budgets_total_unique '
        'ON budgets (month_key, currency_code) '
        'WHERE account_id IS NULL',
      );
      await database.customStatement(
        'CREATE UNIQUE INDEX budgets_account_unique '
        'ON budgets (month_key, account_id, currency_code) '
        'WHERE account_id IS NOT NULL',
      );
      await database.customStatement(
        'CREATE INDEX transactions_current_main_occurred_idx '
        'ON transactions (business_state, parent_transaction_id, '
        'occurred_at, id)',
      );
      await database.customStatement(
        'CREATE INDEX transactions_root_current_child_purpose_idx '
        'ON transactions (root_transaction_id, business_state, '
        'parent_transaction_id, business_purpose)',
      );
      await database.customStatement(
        'CREATE INDEX transactions_current_occurred_stats_idx '
        'ON transactions (business_state, occurred_at, '
        'is_excluded_from_stats)',
      );
      await database.customStatement(
        'CREATE INDEX entries_transaction_idx ON entries (transaction_id)',
      );
      await database.customStatement(
        'CREATE INDEX entries_account_transaction_idx '
        'ON entries (account_id, transaction_id)',
      );
      await ensureBuiltinData(database);
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(database.appMetadata);
        await migrator.addColumn(database.accounts, database.accounts.source);
        await ensureBuiltinData(database);
      }
    },
    beforeOpen: (_) async {
      await ensureBuiltinData(database);
    },
  );
}
