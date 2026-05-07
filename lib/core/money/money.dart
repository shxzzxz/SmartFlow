import 'package:decimal/decimal.dart';

class Money implements Comparable<Money> {
  const Money({
    required this.minorUnits,
    this.currency = defaultCurrency,
  });

  factory Money.zero({String currency = defaultCurrency}) {
    return Money(minorUnits: 0, currency: currency);
  }

  factory Money.fromMajor(
    Decimal amount, {
    String currency = defaultCurrency,
  }) {
    final minor = amount.shift(2);
    if (!minor.isInteger) {
      throw FormatException('Money only supports cent precision: $amount');
    }

    return Money(
      minorUnits: minor.toBigInt().toInt(),
      currency: currency,
    );
  }

  factory Money.parse(
    String amount, {
    String currency = defaultCurrency,
  }) {
    return Money.fromMajor(
      Decimal.parse(amount.trim()),
      currency: currency,
    );
  }

  static const defaultCurrency = 'CNY';

  final int minorUnits;
  final String currency;

  Decimal get major => Decimal.fromInt(minorUnits).shift(-2);

  Money operator +(Money other) {
    _checkSameCurrency(other);
    return Money(
      minorUnits: minorUnits + other.minorUnits,
      currency: currency,
    );
  }

  Money operator -(Money other) {
    _checkSameCurrency(other);
    return Money(
      minorUnits: minorUnits - other.minorUnits,
      currency: currency,
    );
  }

  Money operator -() {
    return Money(minorUnits: -minorUnits, currency: currency);
  }

  Money abs() {
    return Money(minorUnits: minorUnits.abs(), currency: currency);
  }

  String format({bool withCurrency = false}) {
    final value = major.toStringAsFixed(2);
    return withCurrency ? '$currency $value' : value;
  }

  @override
  int compareTo(Money other) {
    _checkSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  void _checkSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError.value(
        other.currency,
        'other.currency',
        'Currency mismatch: $currency != ${other.currency}',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is Money &&
        other.minorUnits == minorUnits &&
        other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => format(withCurrency: true);
}
