import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/accounting/enums/accounting_enums.dart';
import '../../domain/enums/installment_enums.dart';
import 'migrations/app_migration_strategy.dart';
import 'tables/accounts.dart';
import 'tables/app_metadata.dart';
import 'tables/budgets.dart';
import 'tables/entries.dart';
import 'tables/installment_contracts.dart';
import 'tables/installment_repayments.dart';
import 'tables/installment_schedules.dart';
import 'tables/transaction_details.dart';
import 'tables/transactions.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    AppMetadata,
    Transactions,
    TransactionDetails,
    Entries,
    Budgets,
    InstallmentContracts,
    InstallmentSchedules,
    InstallmentRepayments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'smartflow.sqlite',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
