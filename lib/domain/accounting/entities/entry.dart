import '../../../core/money/money.dart';
import '../enums/accounting_enums.dart';

class Entry {
  const Entry({
    required this.id,
    required this.transactionId,
    required this.accountId,
    required this.direction,
    required this.amount,
  });

  final int id;
  final int transactionId;
  final int accountId;
  final EntryDirection direction;
  final Money amount;
}
