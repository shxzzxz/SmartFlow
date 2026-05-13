import '../../../domain/services/transaction_query_service.dart';
import '../../home/view_models/home_transaction_group.dart';
import '../../home/view_models/transaction_row_presentation.dart';
import 'lunar_label_resolver.dart';

class CalendarDayPresentation {
  const CalendarDayPresentation({
    required this.date,
    required this.isInVisibleMonth,
    required this.isSelected,
    required this.isToday,
    required this.incomeMinor,
    required this.expenseMinor,
    required this.lunarLabel,
    required this.markerLabel,
  });

  final DateTime date;
  final bool isInVisibleMonth;
  final bool isSelected;
  final bool isToday;
  final int incomeMinor;
  final int expenseMinor;
  final String lunarLabel;
  final String? markerLabel;

  bool get hasCashflow => incomeMinor > 0 || expenseMinor > 0;

  String get incomeText => '+${formatMinorAmount(incomeMinor)}';

  String get expenseText => '-${formatMinorAmount(expenseMinor)}';
}

List<CalendarDayPresentation> buildCalendarMonthPresentation({
  required DateTime visibleMonth,
  required DateTime selectedDate,
  required List<TransactionListItem> transactions,
  DateTime? today,
  CalendarLunarLabelResolver lunarLabelResolver =
      const DefaultCalendarLunarLabelResolver(),
}) {
  final month = DateTime(visibleMonth.year, visibleMonth.month);
  final normalizedSelected = normalizeDate(selectedDate);
  final normalizedToday = normalizeDate(today ?? DateTime.now());
  final totalsByDate = _totalsByDate(transactions);

  return [
    for (final date in calendarGridDates(month)) ...[
      _buildCalendarDay(
        date: date,
        month: month,
        normalizedSelected: normalizedSelected,
        normalizedToday: normalizedToday,
        totals: totalsByDate[date],
        lunarLabel: lunarLabelResolver.labelFor(date),
      ),
    ],
  ];
}

CalendarDayPresentation _buildCalendarDay({
  required DateTime date,
  required DateTime month,
  required DateTime normalizedSelected,
  required DateTime normalizedToday,
  required _DayTotals? totals,
  required CalendarLunarLabel lunarLabel,
}) {
  return CalendarDayPresentation(
    date: date,
    isInVisibleMonth: date.year == month.year && date.month == month.month,
    isSelected: isSameDate(date, normalizedSelected),
    isToday: isSameDate(date, normalizedToday),
    incomeMinor: totals?.incomeMinor ?? 0,
    expenseMinor: totals?.expenseMinor ?? 0,
    lunarLabel: lunarLabel.text,
    markerLabel: lunarLabel.marker,
  );
}

List<DateTime> calendarGridDates(DateTime visibleMonth) {
  final month = DateTime(visibleMonth.year, visibleMonth.month);
  final firstDayWeekdayIndex = month.weekday % DateTime.daysPerWeek;
  final startDate = month.subtract(Duration(days: firstDayWeekdayIndex));
  final lastDay = DateTime(month.year, month.month + 1, 0);
  final trailingDays =
      DateTime.daysPerWeek - 1 - (lastDay.weekday % DateTime.daysPerWeek);
  final totalDays = firstDayWeekdayIndex + lastDay.day + trailingDays;
  return [
    for (var index = 0; index < totalDays; index++)
      normalizeDate(startDate.add(Duration(days: index))),
  ];
}

DateTime clampSelectedDateToMonth(DateTime selectedDate, DateTime month) {
  final targetMonth = DateTime(month.year, month.month);
  final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
  final day = selectedDate.day > lastDay ? lastDay : selectedDate.day;
  return DateTime(targetMonth.year, targetMonth.month, day);
}

List<TransactionListItem> transactionsForDate(
  List<TransactionListItem> transactions,
  DateTime date,
) {
  final normalized = normalizeDate(date);
  return [
    for (final item in transactions)
      if (isSameDate(item.occurredAt, normalized)) item,
  ];
}

HomeTransactionDayGroup transactionGroupForDate({
  required DateTime date,
  required List<TransactionListItem> transactions,
}) {
  final items = transactionsForDate(transactions, date);
  return HomeTransactionDayGroup(
    date: normalizeDate(date),
    items: items,
    incomeMinor: sumIncomeMinor(items),
    expenseMinor: sumExpenseMinor(items),
  );
}

DateTime normalizeDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

Map<DateTime, _DayTotals> _totalsByDate(List<TransactionListItem> items) {
  final result = <DateTime, List<TransactionListItem>>{};
  for (final item in items) {
    final date = normalizeDate(item.occurredAt);
    result.putIfAbsent(date, () => []).add(item);
  }
  return {
    for (final entry in result.entries)
      entry.key: _DayTotals(
        incomeMinor: sumIncomeMinor(entry.value),
        expenseMinor: sumExpenseMinor(entry.value),
      ),
  };
}

class _DayTotals {
  const _DayTotals({required this.incomeMinor, required this.expenseMinor});

  final int incomeMinor;
  final int expenseMinor;
}
