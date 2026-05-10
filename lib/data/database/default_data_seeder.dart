import 'package:drift/drift.dart';

import '../../domain/enums/accounting_enums.dart';
import 'app_database.dart';

const _defaultCurrency = 'CNY';

Future<void> seedDefaultData(AppDatabase database) async {
  await database.transaction(() async {
    final hasUserCategories = await _hasUserCategories(database);
    if (!hasUserCategories) {
      await _seedDefaultCategoryTree(database);
    }

    await _ensureOperationalCategories(database);
  });
}

Future<bool> _hasUserCategories(AppDatabase database) async {
  final row =
      await database
          .customSelect(
            'SELECT COUNT(*) AS count FROM accounts '
            "WHERE account_type IN ('income', 'expense') "
            'AND system_key IS NULL',
          )
          .getSingle();
  return row.read<int>('count') > 0;
}

Future<void> _seedDefaultCategoryTree(AppDatabase database) async {
  for (final definition in _defaultCategories) {
    final parentId = await _ensureCategory(database, definition);
    for (final child in definition.children) {
      await _ensureCategory(
        database,
        child.copyWith(parentId: parentId, type: definition.type),
      );
    }
  }
}

Future<void> _ensureOperationalCategories(AppDatabase database) async {
  final financeExpenseId = await _ensureCategory(
    database,
    const _CategorySeed(
      name: '财务费用',
      type: AccountType.expense,
      iconKey: 'loan',
      sortOrder: 900,
    ),
  );
  await _ensureCategory(
    database,
    const _CategorySeed(
      name: '利息',
      iconKey: 'loan',
      sortOrder: 901,
    ).copyWith(type: AccountType.expense, parentId: financeExpenseId),
  );
  await _ensureCategory(
    database,
    const _CategorySeed(
      name: '手续费',
      iconKey: 'transfer',
      sortOrder: 902,
    ).copyWith(type: AccountType.expense, parentId: financeExpenseId),
  );
  await _ensureCategory(
    database,
    const _CategorySeed(
      name: '报销差额收入',
      type: AccountType.income,
      iconKey: 'income',
      sortOrder: 900,
      systemKey: SystemKey.reimbursementGapIncome,
    ),
  );
}

Future<int> _ensureCategory(AppDatabase database, _CategorySeed seed) async {
  final existing =
      await (database.select(database.accounts)..where(
        (account) =>
            account.name.equals(seed.name) &
            account.accountType.equalsValue(seed.type!) &
            (seed.parentId == null
                ? account.parentId.isNull()
                : account.parentId.equals(seed.parentId!)) &
            (seed.systemKey == null
                ? account.systemKey.isNull()
                : account.systemKey.equalsValue(seed.systemKey!)),
      )).getSingleOrNull();
  if (existing != null) {
    return existing.id;
  }

  final now = DateTime.now();
  return database
      .into(database.accounts)
      .insert(
        AccountsCompanion.insert(
          name: seed.name,
          accountType: seed.type!,
          parentId: Value(seed.parentId),
          currencyCode: _defaultCurrency,
          iconKey: Value(seed.iconKey),
          sortOrder: Value(seed.sortOrder),
          systemKey: Value(seed.systemKey),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
}

class _CategorySeed {
  const _CategorySeed({
    required this.name,
    this.type,
    this.parentId,
    this.iconKey,
    this.sortOrder = 0,
    this.systemKey,
    this.children = const [],
  });

  final String name;
  final AccountType? type;
  final int? parentId;
  final String? iconKey;
  final int sortOrder;
  final SystemKey? systemKey;
  final List<_CategorySeed> children;

  _CategorySeed copyWith({AccountType? type, int? parentId}) {
    return _CategorySeed(
      name: name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      iconKey: iconKey,
      sortOrder: sortOrder,
      systemKey: systemKey,
      children: children,
    );
  }
}

const _defaultCategories = [
  _CategorySeed(
    name: '人情社交',
    type: AccountType.expense,
    iconKey: 'social',
    sortOrder: 10,
    children: [
      _CategorySeed(name: '请客吃饭', iconKey: 'meal', sortOrder: 11),
      _CategorySeed(name: '送礼人情', iconKey: 'gift', sortOrder: 12),
    ],
  ),
  _CategorySeed(
    name: '家里',
    type: AccountType.expense,
    iconKey: 'home',
    sortOrder: 20,
  ),
  _CategorySeed(
    name: '食品餐饮',
    type: AccountType.expense,
    iconKey: 'meal',
    sortOrder: 30,
    children: [
      _CategorySeed(name: '茶叶', iconKey: 'coffee', sortOrder: 31),
      _CategorySeed(name: '早餐', iconKey: 'breakfast', sortOrder: 32),
      _CategorySeed(name: '午餐', iconKey: 'lunch', sortOrder: 33),
      _CategorySeed(name: '晚餐', iconKey: 'dinner', sortOrder: 34),
      _CategorySeed(name: '饮料酒水', iconKey: 'drink', sortOrder: 35),
      _CategorySeed(name: '休闲零食', iconKey: 'snack', sortOrder: 36),
      _CategorySeed(name: '生鲜食品', iconKey: 'seafood', sortOrder: 37),
      _CategorySeed(name: '请客吃饭', iconKey: 'meal', sortOrder: 38),
      _CategorySeed(name: '粮油调味', iconKey: 'seasoning', sortOrder: 39),
    ],
  ),
  _CategorySeed(
    name: '购物消费',
    type: AccountType.expense,
    iconKey: 'shopping',
    sortOrder: 40,
    children: [
      _CategorySeed(name: '日用品', iconKey: 'shopping', sortOrder: 41),
      _CategorySeed(name: '衣物', iconKey: 'shopping', sortOrder: 42),
    ],
  ),
  _CategorySeed(
    name: '居家生活',
    type: AccountType.expense,
    iconKey: 'home',
    sortOrder: 50,
    children: [
      _CategorySeed(name: '房租', iconKey: 'home', sortOrder: 51),
      _CategorySeed(name: '水电', iconKey: 'home', sortOrder: 52),
      _CategorySeed(name: '物业', iconKey: 'home', sortOrder: 53),
    ],
  ),
  _CategorySeed(
    name: '出行交通',
    type: AccountType.expense,
    iconKey: 'metro',
    sortOrder: 60,
    children: [
      _CategorySeed(name: '地铁', iconKey: 'metro', sortOrder: 61),
      _CategorySeed(name: '打车', iconKey: 'taxi', sortOrder: 62),
      _CategorySeed(name: '公交', iconKey: 'metro', sortOrder: 63),
    ],
  ),
  _CategorySeed(
    name: '休闲娱乐',
    type: AccountType.expense,
    iconKey: 'movie',
    sortOrder: 70,
    children: [
      _CategorySeed(name: '电影', iconKey: 'movie', sortOrder: 71),
      _CategorySeed(name: '游戏', iconKey: 'movie', sortOrder: 72),
    ],
  ),
  _CategorySeed(
    name: '文化教育',
    type: AccountType.expense,
    iconKey: 'book',
    sortOrder: 80,
  ),
  _CategorySeed(
    name: '健康医疗',
    type: AccountType.expense,
    iconKey: 'health',
    sortOrder: 90,
  ),
  _CategorySeed(
    name: '通讯',
    type: AccountType.expense,
    iconKey: 'phone',
    sortOrder: 100,
  ),
  _CategorySeed(
    name: '其他',
    type: AccountType.expense,
    iconKey: 'category',
    sortOrder: 110,
  ),
  _CategorySeed(
    name: '工资',
    type: AccountType.income,
    iconKey: 'salary',
    sortOrder: 10,
  ),
  _CategorySeed(
    name: '兼职',
    type: AccountType.income,
    iconKey: 'salary',
    sortOrder: 20,
  ),
  _CategorySeed(
    name: '投资收益',
    type: AccountType.income,
    iconKey: 'income',
    sortOrder: 30,
  ),
  _CategorySeed(
    name: '其他收入',
    type: AccountType.income,
    iconKey: 'income',
    sortOrder: 40,
  ),
];
