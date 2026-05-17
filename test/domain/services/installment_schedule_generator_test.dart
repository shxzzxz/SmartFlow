import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/core/money/money.dart';
import 'package:smartflow/domain/enums/accounting_enums.dart';
import 'package:smartflow/domain/services/installment_schedule_generator.dart';

void main() {
  const generator = InstallmentScheduleGenerator();
  const cny = 'CNY';

  group('InstallmentScheduleGenerator.generateDates', () {
    test('totalPeriods=1 时返回末期日', () {
      final dates = generator.generateDates(
        firstRepaymentDate: DateTime(2026, 2, 10),
        lastRepaymentDate: DateTime(2026, 12, 10),
        totalPeriods: 1,
      );
      expect(dates, [DateTime(2026, 12, 10)]);
    });

    test('中间期 = 首期 + (i-1) 月，末期为末期还款日', () {
      final dates = generator.generateDates(
        firstRepaymentDate: DateTime(2026, 1, 15),
        lastRepaymentDate: DateTime(2026, 12, 20),
        totalPeriods: 12,
      );
      expect(dates.first, DateTime(2026, 1, 15));
      expect(dates.last, DateTime(2026, 12, 20));
      // 中间期日期都是 15 号
      for (var i = 1; i < dates.length - 1; i++) {
        expect(dates[i].day, 15);
      }
      expect(dates, hasLength(12));
    });

    test('期数 <= 0 抛错', () {
      expect(
        () => generator.generateDates(
          firstRepaymentDate: DateTime(2026, 1, 1),
          lastRepaymentDate: DateTime(2026, 6, 1),
          totalPeriods: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('InstallmentScheduleGenerator.generate (整体)', () {
    test('equalInstallment：本金累计等于合同本金', () {
      final drafts = generator.generate(
        principal: const Money(minorUnits: 1200000, currency: cny),
        borrowingDate: DateTime(2026, 5, 10),
        firstRepaymentDate: DateTime(2026, 6, 10),
        lastRepaymentDate: DateTime(2027, 5, 10),
        totalPeriods: 12,
        method: InstallmentRepaymentMethod.equalInstallment,
        ratePeriod: InterestRatePeriod.annual,
        ratePpm: 72000,
      );
      final principalSum = drafts.fold<int>(
        0,
        (acc, d) => acc + d.expectedPrincipal.minorUnits,
      );
      expect(principalSum, 1200000);
      expect(drafts, hasLength(12));
    });

    test('equalInstallment 零利率退化为等额本金', () {
      final drafts = generator.generate(
        principal: const Money(minorUnits: 1000, currency: cny),
        borrowingDate: DateTime(2026, 1, 1),
        firstRepaymentDate: DateTime(2026, 2, 1),
        lastRepaymentDate: DateTime(2026, 5, 1),
        totalPeriods: 4,
        method: InstallmentRepaymentMethod.equalInstallment,
      );
      for (final d in drafts) {
        expect(d.expectedInterest.minorUnits, 0);
      }
      final sum = drafts.fold<int>(
        0,
        (acc, d) => acc + d.expectedPrincipal.minorUnits,
      );
      expect(sum, 1000);
    });

    test('equalPrincipal 本金均分，末期吸收误差', () {
      final drafts = generator.generate(
        principal: const Money(minorUnits: 1000, currency: cny),
        borrowingDate: DateTime(2026, 1, 1),
        firstRepaymentDate: DateTime(2026, 2, 1),
        lastRepaymentDate: DateTime(2026, 4, 1),
        totalPeriods: 3,
        method: InstallmentRepaymentMethod.equalPrincipal,
        ratePeriod: InterestRatePeriod.monthly,
        ratePpm: 10000,
      );
      expect(drafts[0].expectedPrincipal.minorUnits, 333);
      expect(drafts[1].expectedPrincipal.minorUnits, 333);
      expect(drafts[2].expectedPrincipal.minorUnits, 334);
    });

    test('interestFirst 前 N-1 期只付息，末期付本金', () {
      final drafts = generator.generate(
        principal: const Money(minorUnits: 100000, currency: cny),
        borrowingDate: DateTime(2026, 1, 1),
        firstRepaymentDate: DateTime(2026, 2, 1),
        lastRepaymentDate: DateTime(2026, 5, 1),
        totalPeriods: 4,
        method: InstallmentRepaymentMethod.interestFirst,
        ratePeriod: InterestRatePeriod.monthly,
        ratePpm: 10000,
      );
      expect(drafts[0].expectedPrincipal.minorUnits, 0);
      expect(drafts[1].expectedPrincipal.minorUnits, 0);
      expect(drafts[2].expectedPrincipal.minorUnits, 0);
      expect(drafts[3].expectedPrincipal.minorUnits, 100000);
    });

    test('flatFee 本金 + 手续费均分', () {
      final drafts = generator.generate(
        principal: const Money(minorUnits: 500000, currency: cny),
        borrowingDate: DateTime(2026, 5, 9),
        firstRepaymentDate: DateTime(2026, 6, 9),
        lastRepaymentDate: DateTime(2027, 5, 9),
        totalPeriods: 12,
        method: InstallmentRepaymentMethod.flatFee,
        totalFeeMinor: 36000,
      );
      final principalSum = drafts.fold<int>(
        0,
        (acc, d) => acc + d.expectedPrincipal.minorUnits,
      );
      final feeSum = drafts.fold<int>(
        0,
        (acc, d) => acc + d.expectedFee.minorUnits,
      );
      expect(principalSum, 500000);
      expect(feeSum, 36000);
    });

    test('custom 返回 N 个全零草稿，日期由 generateDates 决定', () {
      final drafts = generator.generate(
        principal: const Money(minorUnits: 9999, currency: cny),
        borrowingDate: DateTime(2025, 12, 15),
        firstRepaymentDate: DateTime(2026, 1, 15),
        lastRepaymentDate: DateTime(2026, 5, 15),
        totalPeriods: 5,
        method: InstallmentRepaymentMethod.custom,
      );
      expect(drafts, hasLength(5));
      expect(drafts.first.periodNo, 1);
      expect(drafts.last.periodNo, 5);
      for (final d in drafts) {
        expect(d.expectedPrincipal.minorUnits, 0);
      }
    });

    test('不规则首期：首期跨 45 天，利息按天数比例放大', () {
      // 借款 2026-01-01，首期 2026-02-15（45 天），末期 2026-05-15
      // 首期天数比 30 天多 15 天，利息应明显大于标准月供利息
      final drafts = generator.generate(
        principal: const Money(minorUnits: 1000000, currency: cny),
        borrowingDate: DateTime(2026, 1, 1),
        firstRepaymentDate: DateTime(2026, 2, 15),
        lastRepaymentDate: DateTime(2026, 5, 15),
        totalPeriods: 4,
        method: InstallmentRepaymentMethod.equalPrincipal,
        ratePeriod: InterestRatePeriod.monthly,
        ratePpm: 10000, // 1%/月
      );
      // 首期天数 = 45
      // 等额本金 4 期：每期本金 250000，第 1 期占用本金 = 1000000
      // 标准利息 = 1000000 * 0.01 = 10000
      // 实际首期利息 ≈ 10000 * 45/30 = 15000
      expect(drafts[0].expectedInterest.minorUnits, closeTo(15000, 100));
    });

    test('不规则末期：末期天数缩短，利息按比例缩小', () {
      // 借款 2026-01-01，首期 2026-02-01，末期 2026-04-15（仅 14 天 vs 30 天）
      final drafts = generator.generate(
        principal: const Money(minorUnits: 1000000, currency: cny),
        borrowingDate: DateTime(2026, 1, 1),
        firstRepaymentDate: DateTime(2026, 2, 1),
        lastRepaymentDate: DateTime(2026, 4, 15),
        totalPeriods: 3,
        method: InstallmentRepaymentMethod.interestFirst,
        ratePeriod: InterestRatePeriod.monthly,
        ratePpm: 10000,
      );
      // 末期天数 = 31（3/15 → 4/15）
      // 第 1 期 = 31 天 (2/1 - 1/1)
      // 第 2 期 = 28 天 (3/1 - 2/1)
      // 第 3 期 = 45 天 (4/15 - 3/1)
      // 利息 = 1000000 * 0.01 * (days/30)
      expect(drafts[0].expectedInterest.minorUnits, closeTo(10333, 50));
      expect(drafts[1].expectedInterest.minorUnits, closeTo(9333, 50));
      expect(drafts[2].expectedInterest.minorUnits, closeTo(15000, 50));
    });
  });

  group('InstallmentScheduleGenerator.allocate (按 dates 重算)', () {
    test('给定 anchor + dates 分配等额本金', () {
      final allocs = generator.allocate(
        remainingPrincipal: const Money(minorUnits: 600000, currency: cny),
        anchorDate: DateTime(2026, 3, 10),
        pendingDates: [
          DateTime(2026, 4, 10),
          DateTime(2026, 5, 10),
          DateTime(2026, 6, 10),
        ],
        method: InstallmentRepaymentMethod.equalPrincipal,
        ratePeriod: InterestRatePeriod.monthly,
        ratePpm: 5000,
      );
      final sum =
          allocs.fold<int>(0, (acc, a) => acc + a.principal.minorUnits);
      expect(sum, 600000);
      expect(allocs, hasLength(3));
    });

    test('pendingDates 为空抛错', () {
      expect(
        () => generator.allocate(
          remainingPrincipal: const Money(minorUnits: 1000, currency: cny),
          anchorDate: DateTime(2026, 1, 1),
          pendingDates: const [],
          method: InstallmentRepaymentMethod.equalPrincipal,
        ),
        throwsArgumentError,
      );
    });
  });
}
