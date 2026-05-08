import 'package:drift/drift.dart';

MigrationStrategy buildMigrationStrategy(GeneratedDatabase database) {
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
    },
    beforeOpen: (details) async {
      await database.customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
