import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/core/money/money.dart';
import 'package:smartflow/domain/services/financial_metrics_service.dart';
import 'package:smartflow/features/home/widgets/monthly_summary_card.dart';

void main() {
  group('formatPeriodChangeCaption', () {
    test('formats normal percentage change', () {
      final caption = formatPeriodChangeCaption(
        const PeriodChange(
          current: Money(minorUnits: 12500),
          previous: Money(minorUnits: 10000),
        ),
      );

      expect(caption, '较上月 +25.0%');
    });

    test('formats zero baseline states', () {
      expect(
        formatPeriodChangeCaption(
          const PeriodChange(
            current: Money(minorUnits: 0),
            previous: Money(minorUnits: 0),
          ),
        ),
        '与上月持平',
      );
      expect(
        formatPeriodChangeCaption(
          const PeriodChange(
            current: Money(minorUnits: 1000),
            previous: Money(minorUnits: 0),
          ),
        ),
        '较上月新增',
      );
    });
  });
}
