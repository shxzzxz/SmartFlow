import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../domain/entities/account.dart' as domain;
import '../../domain/repositories/posting_repository.dart';
import '../../domain/services/posting_command.dart';
import '../database/app_database.dart';

class DriftPostingRepository implements PostingRepository {
  const DriftPostingRepository(this._database);

  final AppDatabase _database;

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
  Future<PostTransactionResult> postTransaction({
    required PostTransactionCommand command,
    required Map<int, int> balanceDeltasMinor,
  }) {
    return _database.transaction(() async {
      return _insertPostedTransaction(
        command: command,
        balanceDeltasMinor: balanceDeltasMinor,
        now: DateTime.now(),
      );
    });
  }

  @override
  Future<List<PostTransactionResult>> mutateTransactions({
    required List<TransactionStateUpdate> stateUpdates,
    required List<PostTransactionMutation> posts,
  }) {
    return _database.transaction(() async {
      final now = DateTime.now();
      for (final update in stateUpdates) {
        await (_database.update(_database.transactions)
          ..where((t) => t.id.equals(update.transactionId))).write(
          TransactionsCompanion(
            businessState: Value(update.businessState),
            updatedAt: Value(now),
          ),
        );
      }

      final results = <PostTransactionResult>[];
      for (final post in posts) {
        results.add(
          await _insertPostedTransaction(
            command: post.command,
            balanceDeltasMinor: post.balanceDeltasMinor,
            now: now,
          ),
        );
      }
      return results;
    });
  }

  Future<PostTransactionResult> _insertPostedTransaction({
    required PostTransactionCommand command,
    required Map<int, int> balanceDeltasMinor,
    required DateTime now,
  }) async {
    final transactionId = await _database
        .into(_database.transactions)
        .insert(
          TransactionsCompanion.insert(
            businessPurpose: command.businessPurpose,
            occurredAt: command.occurredAt,
            currencyCode: command.currencyCode,
            primaryAmountMinor: command.primaryAmount.minorUnits,
            mutationKind: command.mutationKind,
            businessState: command.businessState,
            sourceKind: command.sourceKind,
            rootTransactionId: Value(command.rootTransactionId),
            counterpartyName: Value(command.counterpartyName),
            note: Value(command.note),
            parentTransactionId: Value(command.parentTransactionId),
            reimbursementExpenseAccountId: Value(
              command.reimbursementExpenseAccountId,
            ),
            mutationPreviousTransactionId: Value(
              command.mutationPreviousTransactionId,
            ),
            mutationReason: Value(command.mutationReason),
            isExcludedFromStats: Value(command.isExcludedFromStats),
            isExcludedFromBudget: Value(command.isExcludedFromBudget),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    final rootTransactionId = command.rootTransactionId ?? transactionId;
    if (command.rootTransactionId == null) {
      await (_database.update(_database.transactions)
        ..where((transaction) => transaction.id.equals(transactionId))).write(
        TransactionsCompanion(
          rootTransactionId: Value(rootTransactionId),
          updatedAt: Value(now),
        ),
      );
    }

    await _database.batch((batch) {
      batch.insertAll(
        _database.transactionDetails,
        command.details.map(
          (detail) => TransactionDetailsCompanion.insert(
            transactionId: transactionId,
            lineNo: detail.lineNo,
            detailType: detail.type,
            amountMinor: detail.amount.minorUnits,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        ),
      );
      batch.insertAll(
        _database.entries,
        command.entries.map(
          (entry) => EntriesCompanion.insert(
            transactionId: transactionId,
            accountId: entry.accountId,
            direction: entry.direction,
            amountMinor: entry.amount.minorUnits,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        ),
      );
    });

    for (final MapEntry(key: accountId, value: delta)
        in balanceDeltasMinor.entries) {
      await _database.customUpdate(
        'UPDATE accounts '
        'SET balance_minor = balance_minor + ?, updated_at = ? '
        'WHERE id = ?',
        variables: [
          Variable<int>(delta),
          Variable<DateTime>(now),
          Variable<int>(accountId),
        ],
        updates: {_database.accounts},
      );
    }

    return PostTransactionResult(
      transactionId: transactionId,
      rootTransactionId: rootTransactionId,
    );
  }

  @override
  Future<void> updateTransactionMetadata({
    required int transactionId,
    String? note,
    bool? isExcludedFromStats,
    bool? isExcludedFromBudget,
  }) async {
    if (note == null &&
        isExcludedFromStats == null &&
        isExcludedFromBudget == null) {
      return;
    }
    await (_database.update(_database.transactions)
      ..where((t) => t.id.equals(transactionId))).write(
      TransactionsCompanion(
        note:
            note == null
                ? const Value.absent()
                : Value(note.isEmpty ? null : note),
        isExcludedFromStats:
            isExcludedFromStats == null
                ? const Value.absent()
                : Value(isExcludedFromStats),
        isExcludedFromBudget:
            isExcludedFromBudget == null
                ? const Value.absent()
                : Value(isExcludedFromBudget),
        updatedAt: Value(DateTime.now()),
      ),
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
}
