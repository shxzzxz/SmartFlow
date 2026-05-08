import '../../core/money/money.dart';
import '../enums/accounting_enums.dart';

class TransactionDetail {
  const TransactionDetail({
    required this.id,
    required this.transactionId,
    required this.lineNo,
    required this.type,
    required this.amount,
  });

  final int id;
  final int transactionId;
  final int lineNo;
  final TransactionDetailType type;
  final Money amount;
}
