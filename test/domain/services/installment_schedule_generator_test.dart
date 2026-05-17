import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/core/money/money.dart';
import 'package:smartflow/domain/enums/accounting_enums.dart';
import 'package:smartflow/domain/services/installment_schedule_generator.dart';

void main() {
  const generator = InstallmentScheduleGenerator();
  const cny = 'CNY';

  group('InstallmentScheduleGenerator', () {
    group('equalInstallment', () {
      test('全部期次本金累计等于合同本金（吸收取整误差）', () {
        final drafts = generator.generate(
          principal: const Money(minorUnits: 1200000, currency: cny),
          totalPeriods: 12,
          startDate: DateTime(2026, 6, 10),
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
        for (final d in drafts) {
          expect(d.expectedFee.minorUnits, 0);
          expect(d.expectedPrincipal.minorUnits, greaterThanOrEqualTo(0));
          expect(d.expectedInterest.minorUnits, greaterThanOrEqualTo(0));
        }
      });

      test('零利率退化为等额本金（无利息）', () {
        final drafts = generator.generate(
          principal: const Money(minorUnits: 1000, currency: cny),
          totalPeriods: 4,
          startDate: DateTime(2026, 1, 31),
          method: InstallmentRepaymentMethod.equalInstallment,
          ratePeriod: null,
          ratePpm: null,
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

      test('利息逐期递减', () {
        final drafts = generator.generate(
          principal: const Money(minorUnits: 100000, currency: cny),
          totalPeriods: 6,
          startDate: DateTime(2026, 1, 1),
          method: InstallmentRepaymentMethod.equalInstallment,
          ratePeriod: InterestRatePeriod.monthly,
          ratePpm: 5000, // 0.5%/月
        );
        for (var i = 1; i < drafts.length; i++) {
          expect(
            drafts[i].expectedInterest.minorUnits,
            lessThanOrEqualTo(drafts[i - 1].expectedInterest.minorUnits),
          );
        }
      });
    });

    group('equalPrincipal', () {
      test('每期本金相等（除末期吸收误差）', () {
        final drafts = generator.generate(
          principal: const Money(minorUnits: 1000, currency: cny),
          totalPeriods: 3,
          startDate: DateTime(2026, 1, 1),
          method: InstallmentRepaymentMethod.equalPrincipal,
          ratePeriod: InterestRatePeriod.monthly,
          ratePpm: 10000,
        );
        // 1000 / 3 = 333, 末期 = 334
        expect(drafts[0].expectedPrincipal.minorUnits, 333);
        expect(drafts[1].expectedPrincipal.minorUnits, 333);
        expect(drafts[2].expectedPrincipal.minorUnits, 334);
      });
    });

    group('interestFirst', () {
      test('前 N-1 期只付息，末期付全部本金', () {
        final drafts = generator.generate(
          principal: const Money(minorUnits: 100000, currency: cny),
          totalPeriods: 4,
          startDate: DateTime(2026, 1, 1),
          method: InstallmentRepaymentMethod.interestFirst,
          ratePeriod: InterestRatePeriod.monthly,
          ratePpm: 10000, // 1%/月
        );
        expect(drafts[0].expectedPrincipal.minorUnits, 0);
        expect(drafts[1].expectedPrincipal.minorUnits, 0);
        expect(drafts[2].expectedPrincipal.minorUnits, 0);
        expect(drafts[3].expectedPrincipal.minorUnits, 100000);
        // 每期利息一致 = 100000 * 0.01 = 1000
        for (final d in drafts) {
          expect(d.expectedInterest.minorUnits, 1000);
        }
      });
    });

    group('flatFee', () {
      test('每期本金均分，手续费分摊到各期', () {
        final drafts = generator.generate(
          principal: const Money(minorUnits: 500000, currency: cny),
          totalPeriods: 12,
          startDate: DateTime(2026, 6, 9),
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
        for (final d in drafts) {
          expect(d.expectedInterest.minorUnits, 0);
        }
      });
    });

    group('custom', () {
      test('返回 N 个全零草稿，仅日期不同', () {
        final drafts = generator.generate(
          principal: const Money(minorUnits: 9999, currency: cny),
          totalPeriods: 5,
          startDate: DateTime(2026, 1, 15),
          method: InstallmentRepaymentMethod.custom,
        );
        expect(drafts, hasLength(5));
        for (final d in drafts) {
          expect(d.expectedPrincipal.minorUnits, 0);
          expect(d.expectedInterest.minorUnits, 0);
          expect(d.expectedFee.minorUnits, 0);
        }
        expect(drafts.first.periodNo, 1);
        expect(drafts.last.periodNo, 5);
      });
    });

    group('日期推进', () {
      test('每期递增一个月', () {
        final drafts = generator.generate(
          principal: const Money(minorUnits: 1000, currency: cny),
          totalPeriods: 3,
          startDate: DateTime(2026, 1, 10),
          method: InstallmentRepaymentMethod.equalPrincipal,
        );
        expect(drafts[0].expectedRepaymentDate, DateTime(2026, 2, 10));
        expect(drafts[1].expectedRepaymentDate, DateTime(2026, 3, 10));
        expect(drafts[2].expectedRepaymentDate, DateTime(2026, 4, 10));
      });

      test('起始日为月底时由 Dart DateTime 自动规整', () {
        // 1/31 + 1 月 = 2/31，Dart 自动溢出到 3/3
        final drafts = generator.generate(
          principal: const Money(minorUnits: 1000, currency: cny),
          totalPeriods: 1,
          startDate: DateTime(2026, 1, 31),
          method: InstallmentRepaymentMethod.equalPrincipal,
        );
        expect(drafts[0].expectedRepaymentDate, DateTime(2026, 3, 3));
      });
    });

    group('校验', () {
      test('期数 <= 0 抛错', () {
        expect(
          () => generator.generate(
            principal: const Money(minorUnits: 100, currency: cny),
            totalPeriods: 0,
            startDate: DateTime(2026, 1, 1),
            method: InstallmentRepaymentMethod.equalPrincipal,
          ),
          throwsArgumentError,
        );
      });

      test('本金 <= 0 抛错', () {
        expect(
          () => generator.generate(
            principal: const Money(minorUnits: 0, currency: cny),
            totalPeriods: 3,
            startDate: DateTime(2026, 1, 1),
            method: InstallmentRepaymentMethod.equalPrincipal,
          ),
          throwsArgumentError,
        );
      });
    });
  });
}
