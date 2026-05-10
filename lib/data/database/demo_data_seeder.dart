import 'package:drift/drift.dart';

import '../../domain/enums/accounting_enums.dart';
import 'app_database.dart';

const _currency = 'CNY';
const _markerNote = '饭后来一杯美式';

Future<void> seedDemoData(AppDatabase database) async {
  await database.transaction(() async {
    if (await _hasDemoData(database)) {
      return;
    }

    final accounts = await _ensureDemoAccounts(database);
    final categories = await _loadCategories(database);
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);

    await _insertDailyExpense(
      database,
      occurredAt: month.add(const Duration(days: 7, hours: 9, minutes: 16)),
      amountMinor: 2800,
      note: '饭后来一杯美式',
      categoryId: categories['茶叶'] ?? categories['食品餐饮']!,
      accountId: accounts.cmbCredit,
    );
    await _insertDailyExpense(
      database,
      occurredAt: month.add(const Duration(days: 7, hours: 8, minutes: 45)),
      amountMinor: 600,
      note: '上班通勤',
      categoryId: categories['地铁'] ?? categories['出行交通']!,
      accountId: accounts.alipay,
    );
    await _insertDailyIncome(
      database,
      occurredAt: month.add(const Duration(days: 7, hours: 8, minutes: 30)),
      amountMinor: 30000,
      note: '${now.month}月工资',
      categoryId: categories['工资']!,
      accountId: accounts.bocDebit,
    );
    await _insertDailyExpense(
      database,
      occurredAt: month.add(const Duration(days: 6, hours: 19, minutes: 36)),
      amountMinor: 12850,
      note: '晚上买菜',
      categoryId: categories['购物消费']!,
      accountId: accounts.wechat,
    );
    await _insertDailyExpense(
      database,
      occurredAt: month.add(const Duration(days: 6, hours: 18, minutes: 45)),
      amountMinor: 8200,
      note: '和朋友聚餐',
      categoryId: categories['晚餐'] ?? categories['食品餐饮']!,
      accountId: accounts.cmbCredit,
      isExcludedFromBudget: true,
    );
    await _insertDailyExpense(
      database,
      occurredAt: month.add(const Duration(days: 6, hours: 17, minutes: 20)),
      amountMinor: 2550,
      note: '回家打车',
      categoryId: categories['打车'] ?? categories['出行交通']!,
      accountId: accounts.alipay,
    );
    await _insertDailyExpense(
      database,
      occurredAt: month.add(const Duration(days: 6, hours: 14, minutes: 33)),
      amountMinor: 17400,
      note: '买了新书',
      categoryId: categories['文化教育']!,
      accountId: accounts.alipay,
    );
    await _insertDailyExpense(
      database,
      occurredAt: month.add(const Duration(days: 5, hours: 20, minutes: 10)),
      amountMinor: 8573,
      note: '看电影',
      categoryId: categories['电影'] ?? categories['休闲娱乐']!,
      accountId: accounts.wechat,
    );
  });
}

Future<bool> _hasDemoData(AppDatabase database) async {
  final row =
      await database
          .customSelect(
            'SELECT COUNT(*) AS count FROM transactions WHERE note = ?',
            variables: [const Variable<String>(_markerNote)],
            readsFrom: {database.transactions},
          )
          .getSingle();
  return row.read<int>('count') > 0;
}

Future<_DemoAccounts> _ensureDemoAccounts(AppDatabase database) async {
  final bocDebit = await _ensureAccount(
    database,
    name: '中国银行 储蓄卡（6789）',
    type: AccountType.asset,
    subtype: AccountSubtype.bankCard,
    iconKey: 'boc_debit_card',
    balanceMinor: 765030,
    sortOrder: 10,
  );
  final alipay = await _ensureAccount(
    database,
    name: '支付宝余额',
    type: AccountType.asset,
    subtype: AccountSubtype.thirdParty,
    iconKey: 'alipay',
    balanceMinor: 432000,
    sortOrder: 20,
  );
  final wechat = await _ensureAccount(
    database,
    name: '微信零钱',
    type: AccountType.asset,
    subtype: AccountSubtype.thirdParty,
    iconKey: 'wechat_pay',
    balanceMinor: 510000,
    sortOrder: 30,
  );
  final cmbCredit = await _ensureAccount(
    database,
    name: '招商银行信用卡（1234）',
    type: AccountType.liability,
    subtype: AccountSubtype.creditCard,
    iconKey: 'cmb_credit_card',
    balanceMinor: 227550,
    billingDay: 10,
    repaymentDay: 28,
    sortOrder: 40,
  );

  return _DemoAccounts(
    bocDebit: bocDebit,
    alipay: alipay,
    wechat: wechat,
    cmbCredit: cmbCredit,
  );
}

Future<int> _ensureAccount(
  AppDatabase database, {
  required String name,
  required AccountType type,
  required AccountSubtype subtype,
  required String iconKey,
  required int balanceMinor,
  required int sortOrder,
  int? billingDay,
  int? repaymentDay,
}) async {
  final existing =
      await (database.select(database.accounts)..where(
        (account) =>
            account.name.equals(name) &
            account.accountType.equalsValue(type) &
            account.systemKey.isNull(),
      )).getSingleOrNull();
  if (existing != null) {
    return existing.id;
  }

  final now = DateTime.now();
  return database
      .into(database.accounts)
      .insert(
        AccountsCompanion.insert(
          name: name,
          accountType: type,
          accountSubtype: Value(subtype),
          currencyCode: _currency,
          balanceMinor: Value(balanceMinor),
          iconKey: Value(iconKey),
          billingDay: Value(billingDay),
          repaymentDay: Value(repaymentDay),
          sortOrder: Value(sortOrder),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
}

Future<Map<String, int>> _loadCategories(AppDatabase database) async {
  final rows =
      await (database.select(database.accounts)..where(
        (account) => account.accountType.isInValues({
          AccountType.income,
          AccountType.expense,
        }),
      )).get();
  return {for (final row in rows) row.name: row.id};
}

Future<void> _insertDailyExpense(
  AppDatabase database, {
  required DateTime occurredAt,
  required int amountMinor,
  required String note,
  required int categoryId,
  required int accountId,
  bool isExcludedFromBudget = false,
}) async {
  final id = await _insertTransaction(
    database,
    purpose: BusinessPurpose.dailyExpense,
    occurredAt: occurredAt,
    amountMinor: amountMinor,
    note: note,
    isExcludedFromBudget: isExcludedFromBudget,
  );
  await _insertDetail(
    database,
    transactionId: id,
    type: TransactionDetailType.primaryExpense,
    amountMinor: amountMinor,
  );
  await _insertEntries(
    database,
    transactionId: id,
    debitAccountId: categoryId,
    creditAccountId: accountId,
    amountMinor: amountMinor,
  );
}

Future<void> _insertDailyIncome(
  AppDatabase database, {
  required DateTime occurredAt,
  required int amountMinor,
  required String note,
  required int categoryId,
  required int accountId,
}) async {
  final id = await _insertTransaction(
    database,
    purpose: BusinessPurpose.dailyIncome,
    occurredAt: occurredAt,
    amountMinor: amountMinor,
    note: note,
  );
  await _insertDetail(
    database,
    transactionId: id,
    type: TransactionDetailType.primaryIncome,
    amountMinor: amountMinor,
  );
  await _insertEntries(
    database,
    transactionId: id,
    debitAccountId: accountId,
    creditAccountId: categoryId,
    amountMinor: amountMinor,
  );
}

Future<int> _insertTransaction(
  AppDatabase database, {
  required BusinessPurpose purpose,
  required DateTime occurredAt,
  required int amountMinor,
  required String note,
  bool isExcludedFromBudget = false,
}) async {
  final now = DateTime.now();
  final id = await database
      .into(database.transactions)
      .insert(
        TransactionsCompanion.insert(
          businessPurpose: purpose,
          occurredAt: occurredAt,
          currencyCode: _currency,
          primaryAmountMinor: amountMinor,
          note: Value(note),
          mutationKind: MutationKind.original,
          businessState: BusinessState.current,
          isExcludedFromBudget: Value(isExcludedFromBudget),
          sourceKind: SourceKind.manual,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
  await (database.update(database.transactions)
        ..where((transaction) => transaction.id.equals(id)))
      .write(
    TransactionsCompanion(
      rootTransactionId: Value(id),
      updatedAt: Value(now),
    ),
  );
  return id;
}

Future<void> _insertDetail(
  AppDatabase database, {
  required int transactionId,
  required TransactionDetailType type,
  required int amountMinor,
}) async {
  final now = DateTime.now();
  await database.into(database.transactionDetails).insert(
        TransactionDetailsCompanion.insert(
          transactionId: transactionId,
          lineNo: 1,
          detailType: type,
          amountMinor: amountMinor,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
}

Future<void> _insertEntries(
  AppDatabase database, {
  required int transactionId,
  required int debitAccountId,
  required int creditAccountId,
  required int amountMinor,
}) async {
  final now = DateTime.now();
  await database.batch((batch) {
    batch.insertAll(database.entries, [
      EntriesCompanion.insert(
        transactionId: transactionId,
        accountId: debitAccountId,
        direction: EntryDirection.debit,
        amountMinor: amountMinor,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      EntriesCompanion.insert(
        transactionId: transactionId,
        accountId: creditAccountId,
        direction: EntryDirection.credit,
        amountMinor: amountMinor,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    ]);
  });
}

class _DemoAccounts {
  const _DemoAccounts({
    required this.bocDebit,
    required this.alipay,
    required this.wechat,
    required this.cmbCredit,
  });

  final int bocDebit;
  final int alipay;
  final int wechat;
  final int cmbCredit;
}
