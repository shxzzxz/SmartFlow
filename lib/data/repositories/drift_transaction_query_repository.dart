import 'package:drift/drift.dart';

import '../../core/money/money.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/enums/accounting_enums.dart';
import '../../domain/repositories/transaction_query_repository.dart';
import '../../domain/services/transaction_query_service.dart';
import '../database/app_database.dart';

class DriftTransactionQueryRepository implements TransactionQueryRepository {
  const DriftTransactionQueryRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<TransactionListItem>> watchTransactions(
    TransactionListQuery query,
  ) {
    final accountFilter = query.accountId == null
        ? ''
        : 'AND EXISTS ('
            'SELECT 1 FROM entries ae '
            'WHERE ae.transaction_id = t.id AND ae.account_id = ?'
            ') ';
    final variables = <Variable<Object>>[
      Variable<String>(BusinessState.current.name),
      if (query.accountId != null) Variable<int>(query.accountId!),
      Variable<int>(query.limit),
      Variable<int>(query.offset),
    ];

    return _database
        .customSelect(
          'SELECT t.id, t.business_purpose, t.occurred_at, '
          't.currency_code, t.primary_amount_minor, t.counterparty_name, '
          "t.note, COALESCE(group_concat(a.name, ' / '), '') AS account_names "
          'FROM transactions t '
          'LEFT JOIN entries e ON e.transaction_id = t.id '
          'LEFT JOIN accounts a ON a.id = e.account_id '
          'WHERE t.business_state = ? '
          '$accountFilter'
          'GROUP BY t.id '
          'ORDER BY t.occurred_at DESC, t.id DESC '
          'LIMIT ? OFFSET ?',
          variables: variables,
          readsFrom: {
            _database.transactions,
            _database.entries,
            _database.accounts,
          },
        )
        .watch()
        .map((rows) => rows.map(_mapListItem).toList());
  }

  @override
  Stream<TransactionDetailView?> watchTransactionDetail(int transactionId) {
    return _database
        .customSelect(
          'SELECT t.id FROM transactions t '
          'LEFT JOIN transaction_details td ON td.transaction_id = t.id '
          'LEFT JOIN entries e ON e.transaction_id = t.id '
          'LEFT JOIN accounts a ON a.id = e.account_id '
          'WHERE t.id = ? '
          'LIMIT 1',
          variables: [Variable<int>(transactionId)],
          readsFrom: {
            _database.transactions,
            _database.transactionDetails,
            _database.entries,
            _database.accounts,
          },
        )
        .watch()
        .asyncMap((_) => _getTransactionDetail(transactionId));
  }

  Future<TransactionDetailView?> _getTransactionDetail(int transactionId) async {
    final transaction = await (_database.select(_database.transactions)
          ..where((row) => row.id.equals(transactionId)))
        .getSingleOrNull();
    if (transaction == null) {
      return null;
    }

    final details = await (_database.select(_database.transactionDetails)
          ..where((row) => row.transactionId.equals(transactionId))
          ..orderBy([(row) => OrderingTerm.asc(row.lineNo)]))
        .get();

    final entryRows = await (_database.select(_database.entries).join([
      innerJoin(
        _database.accounts,
        _database.accounts.id.equalsExp(_database.entries.accountId),
      ),
    ])
          ..where(_database.entries.transactionId.equals(transactionId))
          ..orderBy([OrderingTerm.asc(_database.entries.id)]))
        .get();

    return TransactionDetailView(
      transaction: _mapTransaction(transaction),
      details: [
        for (final detail in details)
          TransactionDetailLineView(
            lineNo: detail.lineNo,
            type: detail.detailType,
            amount: Money(
              minorUnits: detail.amountMinor,
              currency: transaction.currencyCode,
            ),
          ),
      ],
      entries: [
        for (final row in entryRows)
          EntryLineView(
            accountId: row.readTable(_database.accounts).id,
            accountName: row.readTable(_database.accounts).name,
            accountType: row.readTable(_database.accounts).accountType,
            direction: row.readTable(_database.entries).direction,
            amount: Money(
              minorUnits: row.readTable(_database.entries).amountMinor,
              currency: transaction.currencyCode,
            ),
          ),
      ],
    );
  }

  TransactionListItem _mapListItem(QueryRow row) {
    final currencyCode = row.read<String>('currency_code');
    return TransactionListItem(
      id: row.read<int>('id'),
      businessPurpose: BusinessPurpose.values.byName(
        row.read<String>('business_purpose'),
      ),
      occurredAt: row.read<DateTime>('occurred_at'),
      primaryAmount: Money(
        minorUnits: row.read<int>('primary_amount_minor'),
        currency: currencyCode,
      ),
      counterpartyName: row.read<String?>('counterparty_name'),
      note: row.read<String?>('note'),
      accountNames: row.read<String>('account_names'),
    );
  }

  domain.Transaction _mapTransaction(TransactionRow row) {
    return domain.Transaction(
      id: row.id,
      rootTransactionId: row.rootTransactionId ?? row.id,
      businessPurpose: row.businessPurpose,
      occurredAt: row.occurredAt,
      currencyCode: row.currencyCode,
      primaryAmount: Money(
        minorUnits: row.primaryAmountMinor,
        currency: row.currencyCode,
      ),
      counterpartyName: row.counterpartyName,
      note: row.note,
      parentTransactionId: row.parentTransactionId,
      reimbursementExpenseAccountId: row.reimbursementExpenseAccountId,
      mutationKind: row.mutationKind,
      mutationPreviousTransactionId: row.mutationPreviousTransactionId,
      mutationReason: row.mutationReason,
      businessState: row.businessState,
      isExcludedFromStats: row.isExcludedFromStats,
      isExcludedFromBudget: row.isExcludedFromBudget,
      sourceKind: row.sourceKind,
    );
  }
}
