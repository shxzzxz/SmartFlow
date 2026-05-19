import '../../../core/money/money.dart';
import '../enums/accounting_enums.dart';

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.currencyCode,
    required this.balance,
    this.subtype,
    this.parentId,
    this.iconKey,
    this.note,
    this.creditLimit,
    this.billingDay,
    this.repaymentDay,
    this.sortOrder = 0,
    this.isHidden = false,
    this.archivedAt,
    this.systemKey,
    this.source = AccountSource.user,
  });

  final int id;
  final String name;
  final AccountType type;
  final AccountSubtype? subtype;
  final int? parentId;
  final String currencyCode;
  final Money balance;
  final String? iconKey;
  final String? note;
  final Money? creditLimit;
  final int? billingDay;
  final int? repaymentDay;
  final int sortOrder;
  final bool isHidden;
  final DateTime? archivedAt;
  final SystemKey? systemKey;
  final AccountSource source;
}
