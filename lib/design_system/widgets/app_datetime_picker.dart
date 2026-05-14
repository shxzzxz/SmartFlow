import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'app_month_picker.dart';

Future<DateTime?> showAppDateTimePicker({
  required BuildContext context,
  required DateTime initialDateTime,
  int firstYear = 2000,
  int lastYear = 2100,
  String title = '选择时间',
}) {
  return showDialog<DateTime>(
    context: context,
    builder:
        (context) => AppDateTimePickerDialog(
          initialDateTime: initialDateTime,
          firstYear: firstYear,
          lastYear: lastYear,
          title: title,
        ),
  );
}

class AppDateTimePickerDialog extends StatefulWidget {
  const AppDateTimePickerDialog({
    required this.initialDateTime,
    required this.firstYear,
    required this.lastYear,
    required this.title,
    super.key,
  });

  final DateTime initialDateTime;
  final int firstYear;
  final int lastYear;
  final String title;

  @override
  State<AppDateTimePickerDialog> createState() =>
      _AppDateTimePickerDialogState();
}

class _AppDateTimePickerDialogState extends State<AppDateTimePickerDialog> {
  static const _timeItemExtent = 40.0;
  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  late DateTime _selectedDate;
  late DateTime _visibleMonth;
  late int _selectedHour;
  late int _selectedMinute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final initial = _clampDateTime(widget.initialDateTime);
    _selectedDate = DateTime(initial.year, initial.month, initial.day);
    _visibleMonth = DateTime(initial.year, initial.month);
    _selectedHour = initial.hour;
    _selectedMinute = initial.minute;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space24,
        vertical: AppSpacing.space24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space20,
            AppSpacing.space20,
            AppSpacing.space20,
            AppSpacing.space16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: context.appTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.space16),
              _CalendarPanel(
                visibleMonth: _visibleMonth,
                selectedDate: _selectedDate,
                onPreviousMonth: _canPreviousMonth ? _previousMonth : null,
                onNextMonth: _canNextMonth ? _nextMonth : null,
                onMonthPressed: _pickVisibleMonth,
                onDateSelected: (date) => setState(() => _selectedDate = date),
              ),
              const SizedBox(height: AppSpacing.space16),
              _TimeWheelPanel(
                selectedHour: _selectedHour,
                selectedMinute: _selectedMinute,
                hourController: _hourController,
                minuteController: _minuteController,
                itemExtent: _timeItemExtent,
                onHourChanged: (hour) => setState(() => _selectedHour = hour),
                onMinuteChanged:
                    (minute) => setState(() => _selectedMinute = minute),
              ),
              const SizedBox(height: AppSpacing.space16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: AppSpacing.space8),
                  FilledButton(
                    onPressed:
                        () => Navigator.of(context).pop(_selectedDateTime),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime get _selectedDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedHour,
      _selectedMinute,
    );
  }

  bool get _canPreviousMonth {
    return _visibleMonth.year > widget.firstYear || _visibleMonth.month > 1;
  }

  bool get _canNextMonth {
    return _visibleMonth.year < widget.lastYear || _visibleMonth.month < 12;
  }

  void _previousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  Future<void> _pickVisibleMonth() async {
    final picked = await showAppMonthPicker(
      context: context,
      initialMonth: _visibleMonth,
      firstYear: widget.firstYear,
      lastYear: widget.lastYear,
    );
    if (picked == null || !mounted) return;

    final selectedDay = _selectedDate.day.clamp(
      1,
      _daysInMonth(picked.year, picked.month),
    );
    setState(() {
      _visibleMonth = DateTime(picked.year, picked.month);
      _selectedDate = DateTime(picked.year, picked.month, selectedDay);
    });
  }

  DateTime _clampDateTime(DateTime value) {
    final first = DateTime(widget.firstYear);
    final last = DateTime(widget.lastYear, 12, 31, 23, 59);
    if (value.isBefore(first)) return first;
    if (value.isAfter(last)) return last;
    return value;
  }
}

class _CalendarPanel extends StatelessWidget {
  const _CalendarPanel({
    required this.visibleMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthPressed,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback onMonthPressed;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final days = _calendarDays(visibleMonth);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _MonthArrowButton(
              icon: Icons.chevron_left,
              tooltip: '上个月',
              onPressed: onPreviousMonth,
            ),
            Expanded(
              child: InkWell(
                onTap: onMonthPressed,
                borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space6,
                    vertical: AppSpacing.space6,
                  ),
                  child: Text(
                    '${visibleMonth.year}年${visibleMonth.month}月',
                    textAlign: TextAlign.center,
                    style: context.appTextStyles.subsectionTitle,
                  ),
                ),
              ),
            ),
            _MonthArrowButton(
              icon: Icons.chevron_right,
              tooltip: '下个月',
              onPressed: onNextMonth,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
        Row(
          children: [
            for (final weekday in _AppDateTimePickerDialogState._weekdays)
              Expanded(
                child: Text(
                  weekday,
                  textAlign: TextAlign.center,
                  style: context.appTextStyles.formLabel,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.space6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: AppSpacing.space4,
            crossAxisSpacing: AppSpacing.space4,
          ),
          itemBuilder: (context, index) {
            final date = days[index];
            if (date == null) {
              return const SizedBox.shrink();
            }
            return _CalendarDayButton(
              date: date,
              selected: _isSameDate(date, selectedDate),
              onTap: () => onDateSelected(date),
            );
          },
        ),
      ],
    );
  }
}

class _CalendarDayButton extends StatelessWidget {
  const _CalendarDayButton({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        child: Center(
          child: Text(
            '${date.day}',
            style: context.appTextStyles.detailValue.copyWith(
              color: selected ? colors.onPrimary : colors.onSurface,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeWheelPanel extends StatelessWidget {
  const _TimeWheelPanel({
    required this.selectedHour,
    required this.selectedMinute,
    required this.hourController,
    required this.minuteController,
    required this.itemExtent,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  final int selectedHour;
  final int selectedMinute;
  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final double itemExtent;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text('时间', style: context.appTextStyles.subsectionTitle),
            const Spacer(),
            Text(
              '${_two(selectedHour)}:${_two(selectedMinute)}',
              style: context.appTextStyles.detailValue,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
        SizedBox(
          height: 128,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: itemExtent,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.26),
                  borderRadius: BorderRadius.circular(AppRadius.radiusMd),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _TimeWheel(
                      controller: hourController,
                      itemCount: 24,
                      selectedIndex: selectedHour,
                      itemExtent: itemExtent,
                      labelBuilder: (index) => '${_two(index)} 时',
                      onSelectedItemChanged: onHourChanged,
                    ),
                  ),
                  Expanded(
                    child: _TimeWheel(
                      controller: minuteController,
                      itemCount: 60,
                      selectedIndex: selectedMinute,
                      itemExtent: itemExtent,
                      labelBuilder: (index) => '${_two(index)} 分',
                      onSelectedItemChanged: onMinuteChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeWheel extends StatelessWidget {
  const _TimeWheel({
    required this.controller,
    required this.itemCount,
    required this.selectedIndex,
    required this.itemExtent,
    required this.labelBuilder,
    required this.onSelectedItemChanged,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final int selectedIndex;
  final double itemExtent;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: itemExtent,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 1.25,
      perspective: 0.003,
      overAndUnderCenterOpacity: 0.42,
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final selected = index == selectedIndex;
          return Center(
            child: Text(
              labelBuilder(index),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.appTextStyles
                  .segmentedControlLabel(selected: selected)
                  .copyWith(
                    color:
                        selected ? colors.onSurface : colors.onSurfaceVariant,
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _MonthArrowButton extends StatelessWidget {
  const _MonthArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: colors.onSurfaceVariant),
      iconSize: AppSpacing.space20,
      padding: const EdgeInsets.all(AppSpacing.space4),
      constraints: const BoxConstraints.tightFor(
        width: AppSpacing.space32,
        height: AppSpacing.space32,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

List<DateTime?> _calendarDays(DateTime visibleMonth) {
  final firstDay = DateTime(visibleMonth.year, visibleMonth.month);
  final dayCount = _daysInMonth(visibleMonth.year, visibleMonth.month);
  final leadingEmptyCount = firstDay.weekday - 1;
  final totalCount = _roundUpToWeek(leadingEmptyCount + dayCount);

  return List<DateTime?>.generate(totalCount, (index) {
    final day = index - leadingEmptyCount + 1;
    if (day < 1 || day > dayCount) {
      return null;
    }
    return DateTime(visibleMonth.year, visibleMonth.month, day);
  });
}

int _roundUpToWeek(int value) {
  final remainder = value % 7;
  return remainder == 0 ? value : value + 7 - remainder;
}

int _daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _two(int value) => value.toString().padLeft(2, '0');
