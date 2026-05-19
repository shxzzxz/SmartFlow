import '../../../core/money/money.dart';
import '../../../core/time/month_key.dart';
import '../repositories/financial_metrics_repository.dart';
import 'transaction_query_service.dart';

abstract interface class FinancialMetricsService {
  Stream<CashflowComparison> watchCashflowComparison(
    CashflowComparisonQuery query,
  );

  Stream<List<DailyCashflowSummary>> watchDailyCashflowSummaries(
    DailyCashflowSummaryQuery query,
  );

  Stream<BalanceSheetComparison> watchBalanceSheetComparison(
    BalanceSheetComparisonQuery query,
  );

  Stream<List<NetAssetTrendPoint>> watchNetAssetTrend(NetAssetTrendQuery query);
}

class FinancialMetricsServiceImpl implements FinancialMetricsService {
  const FinancialMetricsServiceImpl(this._repository);

  final FinancialMetricsRepository _repository;

  @override
  Stream<CashflowComparison> watchCashflowComparison(
    CashflowComparisonQuery query,
  ) {
    return _repository.watchCashflowComparison(query);
  }

  @override
  Stream<List<DailyCashflowSummary>> watchDailyCashflowSummaries(
    DailyCashflowSummaryQuery query,
  ) {
    return _repository.watchDailyCashflowSummaries(query);
  }

  @override
  Stream<BalanceSheetComparison> watchBalanceSheetComparison(
    BalanceSheetComparisonQuery query,
  ) {
    return _repository.watchBalanceSheetComparison(query);
  }

  @override
  Stream<List<NetAssetTrendPoint>> watchNetAssetTrend(
    NetAssetTrendQuery query,
  ) {
    return _repository.watchNetAssetTrend(query);
  }
}

class CashflowComparisonQuery {
  const CashflowComparisonQuery({
    required this.month,
    this.asOfDate,
    this.currencyCode = Money.defaultCurrency,
  });

  final MonthKey month;
  final DateTime? asOfDate;
  final String currencyCode;
}

class BalanceSheetComparisonQuery {
  const BalanceSheetComparisonQuery({
    required this.month,
    this.asOfExclusive,
    this.currencyCode = Money.defaultCurrency,
  });

  final MonthKey month;

  /// 不包含上界。当前月页面可传入 DateTime.now()，历史月默认用下月月初。
  final DateTime? asOfExclusive;
  final String currencyCode;
}

class DailyCashflowSummaryQuery {
  const DailyCashflowSummaryQuery({
    required this.month,
    this.currencyCode = Money.defaultCurrency,
  });

  final MonthKey month;
  final String currencyCode;
}

class NetAssetTrendQuery {
  const NetAssetTrendQuery({
    required this.endMonth,
    this.months = 6,
    this.currentAsOfExclusive,
    this.currencyCode = Money.defaultCurrency,
  });

  final MonthKey endMonth;
  final int months;

  /// 用于当前月最后一个点的截止时间；为空时所有月份都按月末点计算。
  final DateTime? currentAsOfExclusive;
  final String currencyCode;
}

class DailyCashflowSummary {
  const DailyCashflowSummary({
    required this.date,
    required this.income,
    required this.expense,
  });

  final DateTime date;
  final Money income;
  final Money expense;

  Money get net => income - expense;
}

class CashflowComparison {
  const CashflowComparison({
    required this.current,
    required this.previousSamePeriod,
    required this.previousFullPeriod,
  });

  final CashflowSummary current;
  final CashflowSummary previousSamePeriod;
  final CashflowSummary previousFullPeriod;

  PeriodChange get incomeChange {
    return PeriodChange(
      current: current.income,
      previous: previousSamePeriod.income,
      previousFullPeriod: previousFullPeriod.income,
    );
  }

  PeriodChange get expenseChange {
    return PeriodChange(
      current: current.expense,
      previous: previousSamePeriod.expense,
      previousFullPeriod: previousFullPeriod.expense,
    );
  }
}

class BalanceSheetSnapshot {
  const BalanceSheetSnapshot({required this.assets, required this.liabilities});

  final Money assets;
  final Money liabilities;

  Money get netAssets => assets - liabilities;
}

class BalanceSheetComparison {
  const BalanceSheetComparison({required this.current, required this.previous});

  final BalanceSheetSnapshot current;
  final BalanceSheetSnapshot previous;

  PeriodChange get netAssetChange {
    return PeriodChange(
      current: current.netAssets,
      previous: previous.netAssets,
    );
  }
}

class NetAssetTrendPoint {
  const NetAssetTrendPoint({required this.month, required this.netAssets});

  final MonthKey month;
  final Money netAssets;
}

class PeriodChange {
  const PeriodChange({
    required this.current,
    required this.previous,
    this.previousFullPeriod,
  });

  final Money current;
  final Money previous;
  final Money? previousFullPeriod;

  Money get delta => current - previous;

  /// 上期为 0 时不提供百分比，避免展示无意义的无穷增长。
  double? get ratio {
    final baseline = previous.minorUnits.abs();
    if (baseline == 0) {
      return null;
    }
    return delta.minorUnits / baseline;
  }

  bool get isFlat => delta.minorUnits == 0;
  bool get isNewValue => previous.minorUnits == 0 && current.minorUnits != 0;

  double? get fullPeriodRatio {
    final fullPeriod = previousFullPeriod;
    if (fullPeriod == null || fullPeriod.minorUnits == 0) {
      return null;
    }
    return current.minorUnits / fullPeriod.minorUnits.abs();
  }
}
