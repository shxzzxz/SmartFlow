import 'package:drift/drift.dart';

import '../../../domain/enums/accounting_enums.dart';
import 'transactions.dart';

@DataClassName('TransactionDetailRow')
class TransactionDetails extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().named('transaction_id').references(Transactions, #id)();
  IntColumn get lineNo => integer().named('line_no')();
  TextColumn get detailType =>
      textEnum<TransactionDetailType>().named('detail_type')();
  IntColumn get amountMinor => integer().named('amount_minor')();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
    'UNIQUE (transaction_id, line_no)',
  ];
}
