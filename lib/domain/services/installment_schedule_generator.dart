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

/// 单期金额分配结果（不含日期）。
/// allocate() 的输入已提供 pending dates，仅需金额；输出按 dates 顺序对应。
class InstallmentAmountAllocation {
  const InstallmentAmountAllocation({
    required this.principal,
    required this.interest,
    required this.fee,
  });

  final Money principal;
  final Money interest;
  final Money fee;
}

/// 分期还款计划生成器。
///
/// 拆成两个相对独立的能力：
/// - [generateDates] 根据 (首期, 末期, 期数) 推导每期日期；
/// - [allocate] 根据 (锚点日, dates 列表, 待还本金, method, rate, fee) 计算每期金额。
///
/// 拆开的原因：提前还本后的重算只重新分配 pending 期次的金额，
/// 日期保持不变，此时只需要调用 [allocate]，不应该重新生成日期。
class InstallmentScheduleGenerator {
  const InstallmentScheduleGenerator();

  /// 生成 N 期的还款日期。
  /// - dates[0] = firstRepaymentDate
  /// - dates[i] = firstRepaymentDate + i 个月  (1 <= i <= N-2)
  /// - dates[N-1] = lastRepaymentDate
  ///
  /// 若 totalPeriods == 1，结果为 [lastRepaymentDate]；
  /// 若 totalPeriods == 2，结果为 [first, last]。
  List<DateTime> generateDates({
    required DateTime firstRepaymentDate,
    required DateTime lastRepaymentDate,
    required int totalPeriods,
  }) {
    if (totalPeriods <= 0) {
      throw ArgumentError.value(totalPeriods, 'totalPeriods', 'Must be > 0');
    }
    if (totalPeriods == 1) {
      return [lastRepaymentDate];
    }
    final dates = <DateTime>[firstRepaymentDate];
    for (var i = 1; i < totalPeriods - 1; i++) {
      dates.add(_addMonths(firstRepaymentDate, i));
    }
    dates.add(lastRepaymentDate);
    return dates;
  }

  /// 按给定 dates 分配本金 / 利息 / 手续费。
  ///
  /// - [anchorDate] 第一期的"上一个时点"，决定第一期天数：
  ///   - 创建时 = 借款日期；
  ///   - 重算 pending 时 = 最后一个 paid 期次的还款日（若无 paid 则借款日）。
  /// - [pendingDates] 必须按时间升序，且第一个 date 要晚于 anchorDate。
  /// - [remainingPrincipal] 这些 dates 需要分摊的总本金。
  /// - [remainingFeeMinor] 这些 dates 需要分摊的总手续费（flatFee 用）。
  ///
  /// 利息按天数比例：interest = current_balance × dayRate × periodDays，
  /// 其中 dayRate = 月利率 / 30。等额本息采用"中间期标准月供 +
  /// 首末按实际天数调利息"的简化算法（中间期天数都是 30 ± 1 时近似相等）。
  List<InstallmentAmountAllocation> allocate({
    required Money remainingPrincipal,
    required DateTime anchorDate,
    required List<DateTime> pendingDates,
    required InstallmentRepaymentMethod method,
    InterestRatePeriod? ratePeriod,
    int? ratePpm,
    int remainingFeeMinor = 0,
  }) {
    if (pendingDates.isEmpty) {
      throw ArgumentError.value(pendingDates, 'pendingDates', 'Must not be empty');
    }
    if (remainingPrincipal.minorUnits < 0) {
      throw ArgumentError.value(
        remainingPrincipal.minorUnits,
        'remainingPrincipal',
        'Must be >= 0',
      );
    }
    final dayCounts = _dayCountsForDates(anchorDate, pendingDates);
    switch (method) {
      case InstallmentRepaymentMethod.equalInstallment:
        return _equalInstallment(
          principal: remainingPrincipal,
          dayCounts: dayCounts,
          ratePeriod: ratePeriod,
          ratePpm: ratePpm,
        );
      case InstallmentRepaymentMethod.equalPrincipal:
        return _equalPrincipal(
          principal: remainingPrincipal,
          dayCounts: dayCounts,
          ratePeriod: ratePeriod,
          ratePpm: ratePpm,
        );
      case InstallmentRepaymentMethod.interestFirst:
        return _interestFirst(
          principal: remainingPrincipal,
          dayCounts: dayCounts,
          ratePeriod: ratePeriod,
          ratePpm: ratePpm,
        );
      case InstallmentRepaymentMethod.flatFee:
        return _flatFee(
          principal: remainingPrincipal,
          periods: pendingDates.length,
          remainingFeeMinor: remainingFeeMinor,
        );
      case InstallmentRepaymentMethod.custom:
        return _custom(
          currency: remainingPrincipal.currency,
          periods: pendingDates.length,
        );
    }
  }

  /// 便利方法：一次性生成完整 schedule 草稿（创建合同时使用）。
  List<InstallmentScheduleDraft> generate({
    required Money principal,
    required DateTime borrowingDate,
    required DateTime firstRepaymentDate,
    required DateTime lastRepaymentDate,
    required int totalPeriods,
    required InstallmentRepaymentMethod method,
    InterestRatePeriod? ratePeriod,
    int? ratePpm,
    int totalFeeMinor = 0,
  }) {
    if (principal.minorUnits <= 0) {
      throw ArgumentError.value(
        principal.minorUnits,
        'principal.minorUnits',
        'Must be > 0',
      );
    }
    final dates = generateDates(
      firstRepaymentDate: firstRepaymentDate,
      lastRepaymentDate: lastRepaymentDate,
      totalPeriods: totalPeriods,
    );
    final allocations = allocate(
      remainingPrincipal: principal,
      anchorDate: borrowingDate,
      pendingDates: dates,
      method: method,
      ratePeriod: ratePeriod,
      ratePpm: ratePpm,
      remainingFeeMinor: totalFeeMinor,
    );
    return [
      for (var i = 0; i < dates.length; i++)
        InstallmentScheduleDraft(
          periodNo: i + 1,
          expectedRepaymentDate: dates[i],
          expectedPrincipal: allocations[i].principal,
          expectedInterest: allocations[i].interest,
          expectedFee: allocations[i].fee,
        ),
    ];
  }

  // ---------- method 实现 ----------

  List<InstallmentAmountAllocation> _equalInstallment({
    required Money principal,
    required List<int> dayCounts,
    InterestRatePeriod? ratePeriod,
    int? ratePpm,
  }) {
    final monthlyRate = _toMonthlyRate(ratePeriod, ratePpm);
    final n = dayCounts.length;
    if (monthlyRate == 0) {
      return _equalPrincipal(
        principal: principal,
        dayCounts: dayCounts,
        ratePeriod: ratePeriod,
        ratePpm: ratePpm,
      );
    }
    if (n == 1) {
      final days = dayCounts[0];
      final interestMinor =
          (principal.minorUnits * monthlyRate * days / 30).round();
      return [
        InstallmentAmountAllocation(
          principal: principal,
          interest: Money(
            minorUnits: interestMinor,
            currency: principal.currency,
          ),
          fee: Money.zero(currency: principal.currency),
        ),
      ];
    }
    // 标准月供：假定每期都是 1 个月，按 p × r × (1+r)^n / ((1+r)^n - 1)。
    final p = principal.minorUnits.toDouble();
    final r = monthlyRate;
    final pow = _pow(1 + r, n);
    final installment = (p * r * pow / (pow - 1)).round();

    final allocations = <InstallmentAmountAllocation>[];
    var remaining = principal.minorUnits;
    var principalAccum = 0;
    for (var i = 0; i < n; i++) {
      final isLast = i == n - 1;
      // 利息按当期天数比例：standard_interest × (days / 30)。
      final scaledInterestMinor =
          (remaining * monthlyRate * dayCounts[i] / 30).round();
      var principalMinor = installment - scaledInterestMinor;
      if (isLast) {
        // 末期吸收取整误差，本金 = 剩余全部，利息按天数调整。
        principalMinor = principal.minorUnits - principalAccum;
      }
      allocations.add(
        InstallmentAmountAllocation(
          principal: Money(
            minorUnits: principalMinor,
            currency: principal.currency,
          ),
          interest: Money(
            minorUnits: scaledInterestMinor,
            currency: principal.currency,
          ),
          fee: Money.zero(currency: principal.currency),
        ),
      );
      remaining -= principalMinor;
      principalAccum += principalMinor;
    }
    return allocations;
  }

  List<InstallmentAmountAllocation> _equalPrincipal({
    required Money principal,
    required List<int> dayCounts,
    InterestRatePeriod? ratePeriod,
    int? ratePpm,
  }) {
    final monthlyRate = _toMonthlyRate(ratePeriod, ratePpm);
    final n = dayCounts.length;
    final perPrincipal = principal.minorUnits ~/ n;
    final allocations = <InstallmentAmountAllocation>[];
    var remaining = principal.minorUnits;
    var principalAccum = 0;
    for (var i = 0; i < n; i++) {
      var principalMinor = perPrincipal;
      if (i == n - 1) {
        principalMinor = principal.minorUnits - principalAccum;
      }
      final interestMinor =
          (remaining * monthlyRate * dayCounts[i] / 30).round();
      allocations.add(
        InstallmentAmountAllocation(
          principal: Money(
            minorUnits: principalMinor,
            currency: principal.currency,
          ),
          interest: Money(
            minorUnits: interestMinor,
            currency: principal.currency,
          ),
          fee: Money.zero(currency: principal.currency),
        ),
      );
      remaining -= principalMinor;
      principalAccum += principalMinor;
    }
    return allocations;
  }

  List<InstallmentAmountAllocation> _interestFirst({
    required Money principal,
    required List<int> dayCounts,
    InterestRatePeriod? ratePeriod,
    int? ratePpm,
  }) {
    final monthlyRate = _toMonthlyRate(ratePeriod, ratePpm);
    final n = dayCounts.length;
    final allocations = <InstallmentAmountAllocation>[];
    for (var i = 0; i < n; i++) {
      final isLast = i == n - 1;
      final interestMinor =
          (principal.minorUnits * monthlyRate * dayCounts[i] / 30).round();
      allocations.add(
        InstallmentAmountAllocation(
          principal: Money(
            minorUnits: isLast ? principal.minorUnits : 0,
            currency: principal.currency,
          ),
          interest: Money(
            minorUnits: interestMinor,
            currency: principal.currency,
          ),
          fee: Money.zero(currency: principal.currency),
        ),
      );
    }
    return allocations;
  }

  List<InstallmentAmountAllocation> _flatFee({
    required Money principal,
    required int periods,
    required int remainingFeeMinor,
  }) {
    final perPrincipal = principal.minorUnits ~/ periods;
    final perFee = remainingFeeMinor ~/ periods;
    final allocations = <InstallmentAmountAllocation>[];
    var principalAccum = 0;
    var feeAccum = 0;
    for (var i = 0; i < periods; i++) {
      var principalMinor = perPrincipal;
      var feeMinor = perFee;
      if (i == periods - 1) {
        principalMinor = principal.minorUnits - principalAccum;
        feeMinor = remainingFeeMinor - feeAccum;
      }
      allocations.add(
        InstallmentAmountAllocation(
          principal: Money(
            minorUnits: principalMinor,
            currency: principal.currency,
          ),
          interest: Money.zero(currency: principal.currency),
          fee: Money(
            minorUnits: feeMinor,
            currency: principal.currency,
          ),
        ),
      );
      principalAccum += principalMinor;
      feeAccum += feeMinor;
    }
    return allocations;
  }

  List<InstallmentAmountAllocation> _custom({
    required String currency,
    required int periods,
  }) {
    final zero = Money.zero(currency: currency);
    return [
      for (var i = 0; i < periods; i++)
        InstallmentAmountAllocation(principal: zero, interest: zero, fee: zero),
    ];
  }

  // ---------- 工具 ----------

  /// 计算每期的"占用天数"：第 i 期天数 = dates[i] - prevDate (若 i==0 则 anchorDate)。
  /// 至少为 1 天，避免零利息退化。
  List<int> _dayCountsForDates(DateTime anchorDate, List<DateTime> dates) {
    final result = <int>[];
    var prev = anchorDate;
    for (final d in dates) {
      final days = d.difference(prev).inDays;
      result.add(days < 1 ? 1 : days);
      prev = d;
    }
    return result;
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
