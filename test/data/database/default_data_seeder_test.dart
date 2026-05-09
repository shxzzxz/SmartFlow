import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/data/database/default_data_seeder.dart';
import 'package:smartflow/domain/enums/accounting_enums.dart';

import '../../helpers/test_app_database.dart';

void main() {
  group('seedDefaultData', () {
    test('creates default income and expense categories once', () async {
      final database = createTestDatabase();
      addTearDown(database.close);

      await seedDefaultData(database);
      await seedDefaultData(database);

      final expenseRows =
          await (database.select(database.accounts)..where(
            (account) =>
                account.accountType.equalsValue(AccountType.expense) &
                account.systemKey.isNull(),
          )).get();
      final incomeRows =
          await (database.select(database.accounts)..where(
            (account) => account.accountType.equalsValue(AccountType.income),
          )).get();

      expect(expenseRows.where((row) => row.parentId == null), isNotEmpty);
      expect(incomeRows.where((row) => row.name == '工资'), hasLength(1));
      expect(expenseRows.where((row) => row.name == '食品餐饮'), hasLength(1));
      expect(expenseRows.where((row) => row.name == '早餐'), hasLength(1));
    });

    test('ensures operational categories for money flows', () async {
      final database = createTestDatabase();
      addTearDown(database.close);

      await seedDefaultData(database);

      final rows = await database.select(database.accounts).get();

      expect(rows.where((row) => row.name == '利息'), hasLength(1));
      expect(rows.where((row) => row.name == '手续费'), hasLength(1));
      expect(
        rows.where(
          (row) =>
              row.name == '报销差额收入' &&
              row.systemKey == SystemKey.reimbursementGapIncome,
        ),
        hasLength(1),
      );
    });
  });
}
