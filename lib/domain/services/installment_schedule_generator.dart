import '../../core/money/money.dart';
import '../enums/accounting_enums.dart';

class InstallmentScheduleDraft {
  const InstallmentScheduleDraft({
    required this.periodNo,
    required this.expectedRepaymentDate,
    required this.expectedPrincipal,
    required this.expectedInterest,
    required this.expectedFee,
  });

  final int periodNo;
  final DateTime expectedRepaymentDate;
  final Money expectedPrincipal;
  final Money expectedInterest;
  final Money expectedFee;
}

/// 分期还款计划生成器。
///
/// 输入合同基础参数（本金、期数、利率、还款方式），输出 N 期的预期金额与日期。
/// 仅作为合同创建时的初始模板：生成后业务规则允许用户编辑任意行，
/// 计算精度差异由后续编辑兜底。
class InstallmentScheduleGenerator {
  const InstallmentScheduleGenerator();

  List<InstallmentScheduleDraft> generate({
    required Money principal,
    required int totalPeriods,
    required DateTime startDate,
    required InstallmentRepaymentMethod method,
    InterestRatePeriod? ratePeriod,
    int? ratePpm,
    int totalFeeMinor = 0,
  }) {
    if (totalPeriods <= 0) {
      throw ArgumentError.value(
        totalPeriods,
        'totalPeriods',
        'Must be > 0',
      );
    }
    if (principal.minorUnits <= 0) {
      throw ArgumentError.value(
        principal.minorUnits,
        'principal.minorUnits',
        'Must be > 0',
      );
    }

    switch (method) {
      case InstallmentRepaymentMethod.equalInstallment:
        return _equalInstallment(
          principal: principal,
          totalPeriods: totalPeriods,
          startDate: startDate,
          ratePeriod: ratePeriod,
          ratePpm: ratePpm,
        );
      case InstallmentRepaymentMethod.equalPrincipal:
        return _equalPrincipal(
          principal: principal,
          totalPeriods: totalPeriods,
          startDate: startDate,
          ratePeriod: ratePeriod,
          ratePpm: ratePpm,
        );
      case InstallmentRepaymentMethod.interestFirst:
        return _interestFirst(
          principal: principal,
          totalPeriods: totalPeriods,
          startDate: startDate,
          ratePeriod: ratePeriod,
          ratePpm: ratePpm,
        );
      case InstallmentRepaymentMethod.flatFee:
        return _flatFee(
          principal: principal,
          totalPeriods: totalPeriods,
          startDate: startDate,
          totalFeeMinor: totalFeeMinor,
        );
      case InstallmentRepaymentMethod.custom:
        return _custom(
          principal: principal,
          totalPeriods: totalPeriods,
          startDate: startDate,
        );
    }
  }

  List<InstallmentScheduleDraft> _equalInstallment({
    required Money principal,
    required int totalPeriods,
    required DateTime startDate,
    InterestRatePeriod? ratePeriod,
    int? ratePpm,
  }) {
    final monthlyRate = _toMonthlyRate(ratePeriod, ratePpm);
    if (monthlyRate == 0) {
      // 零利率退化为等额本金（无利息）
      return _equalPrincipal(
        principal: principal,
        totalPeriods: totalPeriods,
        startDate: startDate,
        ratePeriod: ratePeriod,
        ratePpm: ratePpm,
      );
    }

    // 月供 = P * r * (1+r)^n / ((1+r)^n - 1)，按 minorUnits 计算
    final p = principal.minorUnits.toDouble();
    final r = monthlyRate;
    final n = totalPeriods;
    final pow = _pow(1 + r, n);
    final installment = (p * r * pow / (pow - 1)).round();

    final drafts = <InstallmentScheduleDraft>[];
    var remaining = principal.minorUnits;
    var principalAccum = 0;

    for (var i = 1; i <= totalPeriods; i++) {
      final interestMinor = (remaining * r).round();
      var principalMinor = installment - interestMinor;
      if (i == totalPeriods) {
        // 末期吸收取整误差
        principalMinor = principal.minorUnits - principalAccum;
      }
      drafts.add(
        InstallmentScheduleDraft(
          periodNo: i,
          expectedRepaymentDate: _addMonths(startDate, i),
          expectedPrincipal: Money(
            minorUnits: principalMinor,
            currency: principal.currency,
          ),
          expectedInterest: Money(
            minorUnits: interestMinor,
            currency: principal.currency,
          ),
          expectedFee: Money.zero(currency: principal.currency),
        ),
      );
      remaining -= principalMinor;
      principalAccum += principalMinor;
    }
    return drafts;
  }

  List<InstallmentScheduleDraft> _equalPrincipal({
    required Money principal,
    required int totalPeriods,
    required DateTime startDate,
    InterestRatePeriod? ratePeriod,
    int? ratePpm,
  }) {
    final monthlyRate = _toMonthlyRate(ratePeriod, ratePpm);
    final perPeriodPrincipal = principal.minorUnits ~/ totalPeriods;
    final drafts = <InstallmentScheduleDraft>[];
    var remaining = principal.minorUnits;
    var principalAccum = 0;

    for (var i = 1; i <= totalPeriods; i++) {
      var principalMinor = perPeriodPrincipal;
      if (i == totalPeriods) {
        principalMinor = principal.minorUnits - principalAccum;
      }
      final interestMinor = (remaining * monthlyRate).round();
      drafts.add(
        InstallmentScheduleDraft(
          periodNo: i,
          expectedRepaymentDate: _addMonths(startDate, i),
          expectedPrincipal: Money(
            minorUnits: principalMinor,
            currency: principal.currency,
          ),
          expectedInterest: Money(
            minorUnits: interestMinor,
            currency: principal.currency,
          ),
          expectedFee: Money.zero(currency: principal.currency),
        ),
      );
      remaining -= principalMinor;
      principalAccum += principalMinor;
    }
    return drafts;
  }

  List<InstallmentScheduleDraft> _interestFirst({
    required Money principal,
    required int totalPeriods,
    required DateTime startDate,
    InterestRatePeriod? ratePeriod,
    int? ratePpm,
  }) {
    final monthlyRate = _toMonthlyRate(ratePeriod, ratePpm);
    final interestPerPeriod = (principal.minorUnits * monthlyRate).round();
    final drafts = <InstallmentScheduleDraft>[];

    for (var i = 1; i <= totalPeriods; i++) {
      final isLast = i == totalPeriods;
      drafts.add(
        InstallmentScheduleDraft(
          periodNo: i,
          expectedRepaymentDate: _addMonths(startDate, i),
          expectedPrincipal: Money(
            minorUnits: isLast ? principal.minorUnits : 0,
            currency: principal.currency,
          ),
          expectedInterest: Money(
            minorUnits: interestPerPeriod,
            currency: principal.currency,
          ),
          expectedFee: Money.zero(currency: principal.currency),
        ),
      );
    }
    return drafts;
  }

  List<InstallmentScheduleDraft> _flatFee({
    required Money principal,
    required int totalPeriods,
    required DateTime startDate,
    required int totalFeeMinor,
  }) {
    final perPeriodPrincipal = principal.minorUnits ~/ totalPeriods;
    final perPeriodFee = totalFeeMinor ~/ totalPeriods;
    final drafts = <InstallmentScheduleDraft>[];
    var principalAccum = 0;
    var feeAccum = 0;

    for (var i = 1; i <= totalPeriods; i++) {
      var principalMinor = perPeriodPrincipal;
      var feeMinor = perPeriodFee;
      if (i == totalPeriods) {
        principalMinor = principal.minorUnits - principalAccum;
        feeMinor = totalFeeMinor - feeAccum;
      }
      drafts.add(
        InstallmentScheduleDraft(
          periodNo: i,
          expectedRepaymentDate: _addMonths(startDate, i),
          expectedPrincipal: Money(
            minorUnits: principalMinor,
            currency: principal.currency,
          ),
          expectedInterest: Money.zero(currency: principal.currency),
          expectedFee: Money(
            minorUnits: feeMinor,
            currency: principal.currency,
          ),
        ),
      );
      principalAccum += principalMinor;
      feeAccum += feeMinor;
    }
    return drafts;
  }

  List<InstallmentScheduleDraft> _custom({
    required Money principal,
    required int totalPeriods,
    required DateTime startDate,
  }) {
    final zero = Money.zero(currency: principal.currency);
    return [
      for (var i = 1; i <= totalPeriods; i++)
        InstallmentScheduleDraft(
          periodNo: i,
          expectedRepaymentDate: _addMonths(startDate, i),
          expectedPrincipal: zero,
          expectedInterest: zero,
          expectedFee: zero,
        ),
    ];
  }

  /// 将 (ratePeriod + ratePpm) 换算为月利率小数。
  /// ratePeriod / ratePpm 为空时返回 0。
  double _toMonthlyRate(InterestRatePeriod? period, int? ppm) {
    if (period == null || ppm == null || ppm == 0) {
      return 0;
    }
    final rate = ppm / 1000000.0;
    switch (period) {
      case InterestRatePeriod.annual:
        return rate / 12.0;
      case InterestRatePeriod.monthly:
        return rate;
      case InterestRatePeriod.daily:
        return rate * 30.0;
    }
  }

  double _pow(double base, int exp) {
    var result = 1.0;
    for (var i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  DateTime _addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }
}
