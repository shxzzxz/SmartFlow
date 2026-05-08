import 'package:drift/drift.dart';

import '../../../domain/enums/accounting_enums.dart';
import 'accounts.dart';
import 'transactions.dart';

@DataClassName('EntryRow')
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().named('transaction_id').references(Transactions, #id)();
  IntColumn get accountId =>
      integer().named('account_id').references(Accounts, #id)();
  TextColumn get direction => textEnum<EntryDirection>()();
  IntColumn get amountMinor => integer().named('amount_minor')();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
}
