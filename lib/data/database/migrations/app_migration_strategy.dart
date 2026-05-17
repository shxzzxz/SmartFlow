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
      await database.customStatement(
        'CREATE INDEX installment_contracts_liability_status_idx '
        'ON installment_contracts (liability_account_id, status)',
      );
      await database.customStatement(
        'CREATE INDEX installment_schedules_contract_period_idx '
        'ON installment_schedules (contract_id, period_no)',
      );
      await database.customStatement(
        'CREATE UNIQUE INDEX installment_repayments_contract_schedule_unique '
        'ON installment_repayments (contract_id, schedule_id) '
        'WHERE schedule_id IS NOT NULL',
      );
      await database.customStatement(
        'CREATE INDEX installment_repayments_transaction_idx '
        'ON installment_repayments (transaction_id)',
      );
      await ensureBuiltinData(database);
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(database.appMetadata);
        await migrator.addColumn(database.accounts, database.accounts.source);
        await ensureBuiltinData(database);
      }
      if (from < 3) {
        await migrator.createTable(database.installmentContracts);
        await migrator.createTable(database.installmentSchedules);
        await migrator.createTable(database.installmentRepayments);
        await database.customStatement(
          'CREATE INDEX installment_contracts_liability_status_idx '
          'ON installment_contracts (liability_account_id, status)',
        );
        await database.customStatement(
          'CREATE INDEX installment_schedules_contract_period_idx '
          'ON installment_schedules (contract_id, period_no)',
        );
        await database.customStatement(
          'CREATE UNIQUE INDEX installment_repayments_contract_schedule_unique '
          'ON installment_repayments (contract_id, schedule_id) '
          'WHERE schedule_id IS NOT NULL',
        );
        await database.customStatement(
          'CREATE INDEX installment_repayments_transaction_idx '
          'ON installment_repayments (transaction_id)',
        );
      }
      if (from < 4) {
        // 拓展合同表：首期/末期还款日、总手续费。
        // 旧数据按"旧 generator 行为"回填：首期 = 起算日+1月，末期 = 起算日+N月。
        await database.customStatement(
          'ALTER TABLE installment_contracts ADD COLUMN '
          'first_repayment_date INTEGER NOT NULL DEFAULT 0',
        );
        await database.customStatement(
          'ALTER TABLE installment_contracts ADD COLUMN '
          'last_repayment_date INTEGER NOT NULL DEFAULT 0',
        );
        await database.customStatement(
          'ALTER TABLE installment_contracts ADD COLUMN '
          'total_fee_minor INTEGER NOT NULL DEFAULT 0',
        );
        await database.customStatement(
          "UPDATE installment_contracts SET "
          "first_repayment_date = CAST(strftime('%s', "
          "datetime(start_date, 'unixepoch', '+1 month')) AS INTEGER), "
          "last_repayment_date = CAST(strftime('%s', "
          "datetime(start_date, 'unixepoch', "
          "'+' || total_periods || ' month')) AS INTEGER) "
          "WHERE first_repayment_date = 0",
        );
      }
    },
    beforeOpen: (_) async {
      await ensureBuiltinData(database);
    },
  );
}
