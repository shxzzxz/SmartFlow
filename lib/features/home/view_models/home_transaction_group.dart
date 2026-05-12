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
        incomeMinor: sumIncomeMinor(groups[date]!),
        expenseMinor: sumExpenseMinor(groups[date]!),
      ),
  ];
}

int sumIncomeMinor(Iterable<TransactionListItem> items) {
  return items.fold(0, (sum, item) => sum + incomeMinorForDayTotal(item));
}

int sumExpenseMinor(Iterable<TransactionListItem> items) {
  return items.fold(0, (sum, item) => sum + expenseMinorForDayTotal(item));
}

int incomeMinorForDayTotal(TransactionListItem item) {
  if (!isIncomePurpose(item.businessPurpose)) {
    return 0;
  }
  return item.primaryAmount.minorUnits.abs();
}

int expenseMinorForDayTotal(TransactionListItem item) {
  if (!isExpensePurpose(item.businessPurpose)) {
    return 0;
  }
  final refundedMinor = item.refundedTotal?.minorUnits.abs() ?? 0;
  final netExpense = item.primaryAmount.minorUnits.abs() - refundedMinor;
  return netExpense < 0 ? 0 : netExpense;
}

/// 主交易级别的"收入"判定。
///
/// 退款 / 报销到账 / 结束报销属于子交易，已在数据层折叠到主交易行的 badge，
/// 因此不再纳入此处的"主级收入"统计。
bool isIncomePurpose(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.dailyIncome => true,
    _ => false,
  };
}

bool isExpensePurpose(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.dailyExpense => true,
    _ => false,
  };
}
