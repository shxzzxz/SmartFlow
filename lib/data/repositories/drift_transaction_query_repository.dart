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
    final topLevelFilter =
        query.topLevelOnly ? 'AND t.parent_transaction_id IS NULL ' : '';
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
          't.note, '
          "COALESCE(group_concat(a.name, ' / '), '') AS account_names, "
          "MAX(CASE WHEN t.business_purpose = 'dailyExpense' "
          "AND a.account_type = 'expense' THEN a.name "
          "WHEN t.business_purpose = 'dailyIncome' "
          "AND a.account_type = 'income' THEN a.name END) AS category_name, "
          "MAX(CASE WHEN t.business_purpose = 'dailyExpense' "
          "AND a.account_type = 'expense' THEN a.icon_key "
          "WHEN t.business_purpose = 'dailyIncome' "
          "AND a.account_type = 'income' THEN a.icon_key END) "
          'AS category_icon_key, '
          "MAX(CASE WHEN a.account_type IN ('asset', 'liability') "
          "AND e.direction = 'credit' THEN a.name END) "
          'AS flow_out_account_name, '
          "MAX(CASE WHEN a.account_type IN ('asset', 'liability') "
          "AND e.direction = 'debit' THEN a.name END) "
          'AS flow_in_account_name '
          'FROM transactions t '
          'LEFT JOIN entries e ON e.transaction_id = t.id '
          'LEFT JOIN accounts a ON a.id = e.account_id '
          'WHERE t.business_state = ? '
          '$topLevelFilter'
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
          'WHERE t.id = ? OR t.parent_transaction_id = ? '
          'LIMIT 1',
          variables: [
            Variable<int>(transactionId),
            Variable<int>(transactionId),
          ],
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

  @override
  Future<domain.Transaction?> findTransactionById(int transactionId) async {
    final row = await (_database.select(_database.transactions)
          ..where((t) => t.id.equals(transactionId)))
        .getSingleOrNull();
    if (row == null) return null;
    return _mapTransaction(row);
  }

  @override
  Future<Money> getRefundedTotal(
    int rootTransactionId, {
    String currencyCode = Money.defaultCurrency,
  }) async {
    final row = await _database.customSelect(
      'SELECT COALESCE(SUM(t.primary_amount_minor), 0) AS total '
      'FROM transactions t '
      'WHERE t.root_transaction_id = ? '
      "AND t.business_purpose = 'refund' "
      "AND t.business_state = 'current'",
      variables: [Variable<int>(rootTransactionId)],
      readsFrom: {_database.transactions},
    ).getSingle();
    return Money(
      minorUnits: row.read<int>('total'),
      currency: currencyCode,
    );
  }

  @override
  Future<ReimbursementSummary?> getReimbursementSummary(
    int rootTransactionId,
  ) async {
    final advance = await (_database.select(_database.transactions)
          ..where(
            (t) =>
                t.id.equals(rootTransactionId) &
                t.businessPurpose.equalsValue(
                  BusinessPurpose.reimbursementAdvance,
                ),
          ))
        .getSingleOrNull();
    if (advance == null) {
      return null;
    }

    final children = await (_database.select(_database.transactions)
          ..where(
            (t) =>
                t.rootTransactionId.equals(rootTransactionId) &
                t.businessPurpose.isInValues({
                  BusinessPurpose.reimbursementReceipt,
                  BusinessPurpose.reimbursementClose,
                }) &
                t.businessState.equalsValue(BusinessState.current),
          ))
        .get();

    var receivedMinor = 0;
    var isClosed = false;
    for (final child in children) {
      receivedMinor += child.primaryAmountMinor;
      if (child.businessPurpose == BusinessPurpose.reimbursementClose) {
        isClosed = true;
      }
    }

    final advanceAmount = Money(
      minorUnits: advance.primaryAmountMinor,
      currency: advance.currencyCode,
    );
    final receivedAmount = Money(
      minorUnits: receivedMinor,
      currency: advance.currencyCode,
    );
    final outstanding = isClosed
        ? Money(minorUnits: 0, currency: advance.currencyCode)
        : advanceAmount - receivedAmount;
    return ReimbursementSummary(
      advanceAmount: advanceAmount,
      receivedAmount: receivedAmount,
      outstanding: outstanding,
      isClosed: isClosed,
    );
  }

  Future<TransactionDetailView?> _getTransactionDetail(
    int transactionId,
  ) async {
    final transaction =
        await (_database.select(_database.transactions)
          ..where((row) => row.id.equals(transactionId))).getSingleOrNull();
    if (transaction == null) {
      return null;
    }

    final details =
        await (_database.select(_database.transactionDetails)
              ..where((row) => row.transactionId.equals(transactionId))
              ..orderBy([(row) => OrderingTerm.asc(row.lineNo)]))
            .get();

    final entryRows =
        await (_database.select(_database.entries).join([
                innerJoin(
                  _database.accounts,
                  _database.accounts.id.equalsExp(_database.entries.accountId),
                ),
              ])
              ..where(_database.entries.transactionId.equals(transactionId))
              ..orderBy([OrderingTerm.asc(_database.entries.id)]))
            .get();

    final children = await _loadChildren(transactionId);
    Money? refundedTotal;
    if (transaction.businessPurpose == BusinessPurpose.dailyExpense) {
      refundedTotal = await getRefundedTotal(
        transaction.rootTransactionId ?? transaction.id,
        currencyCode: transaction.currencyCode,
      );
    }
    ReimbursementSummary? reimbursementSummary;
    if (transaction.businessPurpose == BusinessPurpose.reimbursementAdvance) {
      reimbursementSummary = await getReimbursementSummary(transaction.id);
    }

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
      children: children,
      refundedTotal: refundedTotal,
      reimbursementSummary: reimbursementSummary,
    );
  }

  Future<List<TransactionListItem>> _loadChildren(int parentId) async {
    final variables = <Variable<Object>>[
      Variable<int>(parentId),
      Variable<String>(BusinessState.current.name),
    ];
    final rows = await _database.customSelect(
      'SELECT t.id, t.business_purpose, t.occurred_at, '
      't.currency_code, t.primary_amount_minor, t.counterparty_name, '
      't.note, '
      "COALESCE(group_concat(a.name, ' / '), '') AS account_names, "
      'NULL AS category_name, NULL AS category_icon_key, '
      "MAX(CASE WHEN a.account_type IN ('asset', 'liability') "
      "AND e.direction = 'credit' THEN a.name END) "
      'AS flow_out_account_name, '
      "MAX(CASE WHEN a.account_type IN ('asset', 'liability') "
      "AND e.direction = 'debit' THEN a.name END) "
      'AS flow_in_account_name '
      'FROM transactions t '
      'LEFT JOIN entries e ON e.transaction_id = t.id '
      'LEFT JOIN accounts a ON a.id = e.account_id '
      'WHERE t.parent_transaction_id = ? AND t.business_state = ? '
      'GROUP BY t.id '
      'ORDER BY t.occurred_at DESC, t.id DESC',
      variables: variables,
      readsFrom: {
        _database.transactions,
        _database.entries,
        _database.accounts,
      },
    ).get();
    return rows.map(_mapListItem).toList();
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
      categoryName: row.read<String?>('category_name'),
      categoryIconKey: row.read<String?>('category_icon_key'),
      flowOutAccountName: row.read<String?>('flow_out_account_name'),
      flowInAccountName: row.read<String?>('flow_in_account_name'),
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
