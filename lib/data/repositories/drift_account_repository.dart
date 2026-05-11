import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../domain/entities/account.dart' as domain;
import '../../domain/enums/accounting_enums.dart';
import '../../domain/ledger/ledger_rules.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/system_account_resolver.dart';
import '../../domain/services/account_service.dart';
import '../../domain/services/category_service.dart';
import '../database/app_database.dart';
import 'drift_system_account_resolver.dart';

class DriftAccountRepository implements AccountRepository, CategoryRepository {
  DriftAccountRepository(
    this._database, {
    SystemAccountResolver? systemAccounts,
  }) : _systemAccounts =
           systemAccounts ?? DriftSystemAccountResolver(_database);

  final AppDatabase _database;
  final SystemAccountResolver _systemAccounts;

  @override
  Future<domain.Account?> findAccountById(int id) async {
    final row =
        await (_database.select(_database.accounts)
          ..where((account) => account.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapAccount(row);
  }

  @override
  Future<List<domain.Account>> findAccountsByIds(Set<int> ids) async {
    if (ids.isEmpty) {
      return const [];
    }

    final rows =
        await (_database.select(_database.accounts)
          ..where((account) => account.id.isIn(ids))).get();
    return rows.map(_mapAccount).toList();
  }

  @override
  Stream<List<domain.Account>> watchAccounts(Set<AccountType> types) {
    final query =
        _database.select(_database.accounts)
          ..where(
            (account) =>
                account.archivedAt.isNull() &
                account.accountType.isInValues(types),
          )
          ..orderBy([
            (account) => OrderingTerm.asc(account.sortOrder),
            (account) => OrderingTerm.asc(account.name),
          ]);

    return query.watch().map((rows) => rows.map(_mapAccount).toList());
  }

  @override
  Future<domain.Account> createAccount(CreateAccountCommand command) {
    return _database.transaction(() async {
      final now = DateTime.now();
      final accountId = await _database
          .into(_database.accounts)
          .insert(
            AccountsCompanion.insert(
              name: command.name.trim(),
              accountType: command.type,
              accountSubtype: Value(command.subtype),
              currencyCode: command.currencyCode,
              balanceMinor: const Value(0),
              iconKey: Value(_blankToNull(command.iconKey)),
              note: Value(_blankToNull(command.note)),
              creditLimitMinor: Value(command.creditLimit?.minorUnits),
              billingDay: Value(command.billingDay),
              repaymentDay: Value(command.repaymentDay),
              sortOrder: Value(command.sortOrder),
              isHidden: Value(command.isHidden),
              source: const Value(AccountSource.user),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      if (command.openingBalance.minorUnits != 0) {
        await _postOpeningBalance(
          accountId: accountId,
          accountType: command.type,
          amount: command.openingBalance,
          occurredAt: command.openingOccurredAt ?? now,
          now: now,
        );
      }

      final row =
          await (_database.select(_database.accounts)
            ..where((account) => account.id.equals(accountId))).getSingle();
      return _mapAccount(row);
    });
  }

  @override
  Future<void> updateAccount(EditAccountCommand command) async {
    final now = DateTime.now();
    await (_database.update(_database.accounts)
      ..where((account) => account.id.equals(command.id))).write(
      AccountsCompanion(
        name: Value(command.name.trim()),
        accountSubtype: Value(command.subtype),
        iconKey: Value(_blankToNull(command.iconKey)),
        note: Value(_blankToNull(command.note)),
        creditLimitMinor: Value(command.creditLimit?.minorUnits),
        billingDay: Value(command.billingDay),
        repaymentDay: Value(command.repaymentDay),
        sortOrder: Value(command.sortOrder),
        isHidden: Value(command.isHidden),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<domain.Account?> findCategoryById(int id) async {
    final row =
        await (_database.select(_database.accounts)..where(
          (account) =>
              account.id.equals(id) &
              account.accountType.isInValues({
                AccountType.income,
                AccountType.expense,
              }),
        )).getSingleOrNull();
    return row == null ? null : _mapAccount(row);
  }

  @override
  Stream<List<domain.Account>> watchCategories(AccountType type) {
    final query =
        _database.select(_database.accounts)
          ..where(
            (account) =>
                account.archivedAt.isNull() &
                account.accountType.equalsValue(type),
          )
          ..orderBy([
            (account) => OrderingTerm.asc(account.parentId),
            (account) => OrderingTerm.asc(account.sortOrder),
            (account) => OrderingTerm.asc(account.name),
          ]);

    return query.watch().map((rows) => rows.map(_mapAccount).toList());
  }

  @override
  Future<domain.Account> createCategory(CreateCategoryCommand command) async {
    final now = DateTime.now();
    final id = await _database
        .into(_database.accounts)
        .insert(
          AccountsCompanion.insert(
            name: command.name.trim(),
            accountType: command.type,
            parentId: Value(command.parentId),
            currencyCode: command.currencyCode,
            iconKey: Value(_blankToNull(command.iconKey)),
            note: Value(_blankToNull(command.note)),
            sortOrder: Value(command.sortOrder),
            source: const Value(AccountSource.user),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    final row =
        await (_database.select(_database.accounts)
          ..where((account) => account.id.equals(id))).getSingle();
    return _mapAccount(row);
  }

  Future<void> _postOpeningBalance({
    required int accountId,
    required AccountType accountType,
    required Money amount,
    required DateTime occurredAt,
    required DateTime now,
  }) async {
    final openingAccountId = await _systemAccounts.resolveOpeningBalance(
      currencyCode: amount.currency,
    );
    final amountMinor = amount.minorUnits.abs();
    final targetDirection = _directionForBalanceDelta(
      accountType: accountType,
      deltaMinor: amount.minorUnits,
    );
    final openingDirection =
        targetDirection == EntryDirection.debit
            ? EntryDirection.credit
            : EntryDirection.debit;

    final transactionId = await _database
        .into(_database.transactions)
        .insert(
          TransactionsCompanion.insert(
            businessPurpose: BusinessPurpose.openingBalance,
            occurredAt: occurredAt,
            currencyCode: amount.currency,
            primaryAmountMinor: amountMinor,
            mutationKind: MutationKind.original,
            businessState: BusinessState.current,
            sourceKind: SourceKind.manual,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await (_database.update(_database.transactions)
      ..where((transaction) => transaction.id.equals(transactionId))).write(
      TransactionsCompanion(
        rootTransactionId: Value(transactionId),
        updatedAt: Value(now),
      ),
    );

    await _database.batch((batch) {
      batch.insert(
        _database.transactionDetails,
        TransactionDetailsCompanion.insert(
          transactionId: transactionId,
          lineNo: 1,
          detailType: TransactionDetailType.openingBalanceMain,
          amountMinor: amountMinor,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      batch.insertAll(_database.entries, [
        EntriesCompanion.insert(
          transactionId: transactionId,
          accountId: accountId,
          direction: targetDirection,
          amountMinor: amountMinor,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        EntriesCompanion.insert(
          transactionId: transactionId,
          accountId: openingAccountId,
          direction: openingDirection,
          amountMinor: amountMinor,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);
    });

    await _addBalanceDelta(accountId, amount.minorUnits, now);
    await _addBalanceDelta(
      openingAccountId,
      balanceDeltaMinor(
        accountType: AccountType.equity,
        direction: openingDirection,
        amountMinor: amountMinor,
      ),
      now,
    );
  }

  EntryDirection _directionForBalanceDelta({
    required AccountType accountType,
    required int deltaMinor,
  }) {
    final increasesOnDebit =
        accountType == AccountType.asset || accountType == AccountType.expense;
    final increase = deltaMinor > 0;

    if (increasesOnDebit) {
      return increase ? EntryDirection.debit : EntryDirection.credit;
    }

    return increase ? EntryDirection.credit : EntryDirection.debit;
  }

  Future<void> _addBalanceDelta(int accountId, int deltaMinor, DateTime now) {
    return _database.customUpdate(
      'UPDATE accounts '
      'SET balance_minor = balance_minor + ?, updated_at = ? '
      'WHERE id = ?',
      variables: [
        Variable<int>(deltaMinor),
        Variable<DateTime>(now),
        Variable<int>(accountId),
      ],
      updates: {_database.accounts},
    );
  }

  domain.Account _mapAccount(AccountRow row) {
    return domain.Account(
      id: row.id,
      name: row.name,
      type: row.accountType,
      subtype: row.accountSubtype,
      parentId: row.parentId,
      currencyCode: row.currencyCode,
      balance: Money(minorUnits: row.balanceMinor, currency: row.currencyCode),
      iconKey: row.iconKey,
      note: row.note,
      creditLimit:
          row.creditLimitMinor == null
              ? null
              : Money(
                minorUnits: row.creditLimitMinor!,
                currency: row.currencyCode,
              ),
      billingDay: row.billingDay,
      repaymentDay: row.repaymentDay,
      sortOrder: row.sortOrder,
      isHidden: row.isHidden,
      archivedAt: row.archivedAt,
      systemKey: row.systemKey,
      source: row.source,
    );
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
