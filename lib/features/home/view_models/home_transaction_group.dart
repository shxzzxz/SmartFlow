import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_query_service.dart';

/// 同一日的主交易聚合，用于按日分组卡片。
class HomeTransactionDayGroup {
  const HomeTransactionDayGroup({
    required this.date,
    required this.items,
    required this.incomeMinor,
    required this.expenseMinor,
  });

  final DateTime date;
  final List<TransactionListItem> items;
  final int incomeMinor;
  final int expenseMinor;
}

List<HomeTransactionDayGroup> groupTransactionsByDay(
  List<TransactionListItem> items,
) {
  final groups = <DateTime, List<TransactionListItem>>{};
  for (final item in items) {
    final date = DateTime(
      item.occurredAt.year,
      item.occurredAt.month,
      item.occurredAt.day,
    );
    groups.putIfAbsent(date, () => []).add(item);
  }

  final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final date in dates)
      HomeTransactionDayGroup(
        date: date,
        items: groups[date]!,
        incomeMinor: sumMinor(groups[date]!, isIncomePurpose),
        expenseMinor: sumMinor(groups[date]!, isExpensePurpose),
      ),
  ];
}

int sumMinor(
  Iterable<TransactionListItem> items,
  bool Function(BusinessPurpose purpose) predicate,
) {
  return items
      .where((item) => predicate(item.businessPurpose))
      .fold(0, (sum, item) => sum + item.primaryAmount.minorUnits.abs());
}

/// 主交易级别的"收入"判定。
///
/// 退款 / 报销到账 / 结束报销属于子交易，已在数据层折叠到主交易行的 badge，
/// 因此不再纳入此处的"主级收入"统计。
bool isIncomePurpose(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.dailyIncome || BusinessPurpose.borrowing => true,
    _ => false,
  };
}

bool isExpensePurpose(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.dailyExpense ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose.debtRepayment => true,
    _ => false,
  };
}
