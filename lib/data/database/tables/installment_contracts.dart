import 'package:drift/drift.dart';

import '../../../domain/enums/accounting_enums.dart';

@DataClassName('InstallmentContractRow')
class InstallmentContracts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get liabilityAccountId =>
      integer().named('liability_account_id')();
  TextColumn get sourceType =>
      textEnum<InstallmentSourceType>().named('source_type')();
  IntColumn get disbursementAccountId =>
      integer().named('disbursement_account_id').nullable()();
  IntColumn get disbursementTransactionId =>
      integer().named('disbursement_transaction_id').nullable()();
  IntColumn get principalMinor => integer().named('principal_minor')();
  IntColumn get totalPeriods => integer().named('total_periods')();
  DateTimeColumn get startDate => dateTime().named('start_date')();
  TextColumn get repaymentMethod =>
      textEnum<InstallmentRepaymentMethod>().named('repayment_method')();
  TextColumn get interestRatePeriod =>
      textEnum<InterestRatePeriod>().named('interest_rate_period').nullable()();
  IntColumn get interestRatePpm =>
      integer().named('interest_rate_ppm').nullable()();
  TextColumn get currencyCode =>
      text().named('currency_code').withLength(min: 3, max: 3)();
  TextColumn get status =>
      textEnum<InstallmentContractStatus>().named('status')();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
    'CHECK (principal_minor > 0)',
    'CHECK (total_periods > 0)',
    'CHECK (interest_rate_ppm IS NULL OR interest_rate_ppm >= 0)',
    'CHECK ('
        '(source_type = \'disbursement\' '
        'AND disbursement_account_id IS NOT NULL '
        'AND disbursement_transaction_id IS NOT NULL) '
        'OR (source_type = \'billConversion\' '
        'AND disbursement_account_id IS NULL '
        'AND disbursement_transaction_id IS NULL)'
        ')',
    'CHECK ('
        '(interest_rate_period IS NULL AND interest_rate_ppm IS NULL) '
        'OR (interest_rate_period IS NOT NULL AND interest_rate_ppm IS NOT NULL)'
        ')',
  ];
}
