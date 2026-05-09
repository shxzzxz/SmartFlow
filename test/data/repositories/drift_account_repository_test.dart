import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/core/money/money.dart';
import 'package:smartflow/core/result/result.dart';
import 'package:smartflow/data/database/app_database.dart';
import 'package:smartflow/data/repositories/drift_account_repository.dart';
import 'package:smartflow/domain/enums/accounting_enums.dart';
import 'package:smartflow/domain/services/account_service.dart';
import 'package:smartflow/domain/services/category_service.dart';

import '../../helpers/test_app_database.dart';

void main() {
  group('DriftAccountRepository', () {
    late AppDatabase database;
    late DriftAccountRepository repository;

    setUp(() {
      database = createTestDatabase();
      repository = DriftAccountRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test(
      'creates an account with opening balance in one posting chain',
      () async {
        final service = AccountServiceImpl(repository);

        final result = await service.createAccount(
          CreateAccountCommand(
            name: '招行',
            type: AccountType.asset,
            openingBalance: const Money(minorUnits: 5000000),
            openingOccurredAt: DateTime(2026, 5),
          ),
        );

        expect(result, isA<Success>());
        final account = (result as Success).value;
        expect(account.balance, const Money(minorUnits: 5000000));

        final transactions = await database.select(database.transactions).get();
        final details =
            await database.select(database.transactionDetails).get();
        final entries = await database.select(database.entries).get();
        final systemAccounts =
            await (database.select(database.accounts)..where(
              (row) => row.systemKey.equalsValue(SystemKey.openingBalance),
            )).get();

        expect(transactions, hasLength(1));
        expect(
          transactions.single.businessPurpose,
          BusinessPurpose.openingBalance,
        );
        expect(
          details.single.detailType,
          TransactionDetailType.openingBalanceMain,
        );
        expect(entries, hasLength(2));
        expect(systemAccounts.single.accountType, AccountType.equity);
        expect(systemAccounts.single.balanceMinor, 5000000);
      },
    );

    test('creates reimbursement account as asset subtype', () async {
      final service = AccountServiceImpl(repository);

      final result = await service.createAccount(
        const CreateAccountCommand(
          name: '公司报销',
          type: AccountType.asset,
          subtype: AccountSubtype.reimbursement,
        ),
      );

      expect(result, isA<Success>());
      final account = (result as Success).value;
      expect(account.type, AccountType.asset);
      expect(account.subtype, AccountSubtype.reimbursement);
    });

    test('builds income and expense category trees', () async {
      final service = CategoryServiceImpl(repository);
      final parentResult = await service.createCategory(
        const CreateCategoryCommand(name: '餐饮', type: AccountType.expense),
      );
      final parent = (parentResult as Success).value;

      await service.createCategory(
        CreateCategoryCommand(
          name: '咖啡',
          type: AccountType.expense,
          parentId: parent.id,
        ),
      );

      final tree = await service.watchCategoryTree(AccountType.expense).first;

      expect(tree, hasLength(1));
      expect(tree.single.account.name, '餐饮');
      expect(tree.single.children.single.name, '咖啡');
    });
  });
}
