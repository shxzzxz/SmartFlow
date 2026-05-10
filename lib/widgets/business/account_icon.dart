import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountIcon extends StatelessWidget {
  const AccountIcon({
    required this.iconKey,
    super.key,
    this.size = 16,
    this.fallback = AccountIconFallback.bankCard,
    this.color,
  });

  final String? iconKey;
  final double size;
  final AccountIconFallback fallback;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _resolveAsset(iconKey, fallback),
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

enum AccountIconFallback { bankCard, cash, generic }

const Map<String, String> accountIconAssets = {
  'alipay': 'assets/icons/account/alipay.svg',
  'wechat_pay': 'assets/icons/account/wechat_pay.svg',
  'cmb_credit_card': 'assets/icons/account/cmb_credit_card.svg',
  'boc_debit_card': 'assets/icons/account/boc_debit_card.svg',
  'cash': 'assets/icons/account/cash.svg',
  'huabei': 'assets/icons/account/huabei.svg',
  'loan_in': 'assets/icons/account/loan_in.svg',
  'loan_out': 'assets/icons/account/loan_out.svg',
  'reimburse': 'assets/icons/account/reimburse.svg',
};

const List<AccountIconChoice> accountIconChoices = [
  AccountIconChoice(iconKey: 'alipay', label: '支付宝'),
  AccountIconChoice(iconKey: 'wechat_pay', label: '微信支付'),
  AccountIconChoice(iconKey: 'cmb_credit_card', label: '招商银行'),
  AccountIconChoice(iconKey: 'boc_debit_card', label: '中国银行'),
  AccountIconChoice(iconKey: 'cash', label: '现金'),
  AccountIconChoice(iconKey: 'huabei', label: '花呗'),
  AccountIconChoice(iconKey: 'loan_in', label: '借入'),
  AccountIconChoice(iconKey: 'loan_out', label: '借出'),
  AccountIconChoice(iconKey: 'reimburse', label: '报销'),
];

class AccountIconChoice {
  const AccountIconChoice({required this.iconKey, required this.label});

  final String iconKey;
  final String label;
}

const Map<AccountIconFallback, String> _fallbackAssets = {
  AccountIconFallback.bankCard: 'assets/icons/account/boc_debit_card.svg',
  AccountIconFallback.cash: 'assets/icons/account/cash.svg',
  AccountIconFallback.generic: 'assets/icons/account/boc_debit_card.svg',
};

String _resolveAsset(String? iconKey, AccountIconFallback fallback) {
  final trimmed = iconKey?.trim();
  if (trimmed != null && accountIconAssets.containsKey(trimmed)) {
    return accountIconAssets[trimmed]!;
  }
  return _fallbackAssets[fallback]!;
}
