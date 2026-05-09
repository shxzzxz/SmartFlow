import 'package:drift/drift.dart';

import '../../domain/enums/accounting_enums.dart';
import '../../domain/repositories/system_account_resolver.dart';
import '../database/app_database.dart';

class DriftSystemAccountResolver implements SystemAccountResolver {
  const DriftSystemAccountResolver(this._database);

  final AppDatabase _database;

  @override
  Future<int> resolveOpeningBalance({String currencyCode = 'CNY'}) {
    return _resolve(
      systemKey: SystemKey.openingBalance,
      accountType: AccountType.equity,
      defaultName: '系统期初余额($currencyCode)',
      currencyCode: currencyCode,
    );
  }

  @override
  Future<int> resolveReimbursementGapIncome({String currencyCode = 'CNY'}) {
    return _resolve(
      systemKey: SystemKey.reimbursementGapIncome,
      accountType: AccountType.income,
      defaultName: '报销差额收入',
      currencyCode: currencyCode,
    );
  }

  Future<int> _resolve({
    required SystemKey systemKey,
    required AccountType accountType,
    required String defaultName,
    required String currencyCode,
  }) async {
    final existing = await (_database.select(_database.accounts)
          ..where(
            (account) =>
                account.systemKey.equalsValue(systemKey) &
                account.currencyCode.equals(currencyCode),
          ))
        .getSingleOrNull();
    if (existing != null) {
      return existing.id;
    }

    final now = DateTime.now();
    return _database.into(_database.accounts).insert(
          AccountsCompanion.insert(
            name: defaultName,
            accountType: accountType,
            currencyCode: currencyCode,
            systemKey: Value(systemKey),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }
}
