import '../../../core/money/money.dart';

abstract interface class SystemAccountResolver {
  Future<int> resolveOpeningBalance({
    String currencyCode = Money.defaultCurrency,
  });

  Future<int> resolveReimbursementGapIncome({
    String currencyCode = Money.defaultCurrency,
  });

  Future<int> resolveDebtInterestExpense({
    String currencyCode = Money.defaultCurrency,
  });

  Future<int> resolveDiscountIncome({
    String currencyCode = Money.defaultCurrency,
  });
}
