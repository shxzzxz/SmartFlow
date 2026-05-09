import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountIcon extends StatelessWidget {
  const AccountIcon({
    required this.iconKey,
    super.key,
    this.size = 16,
    this.fallback = AccountIconFallback.bankCard,
  });

  final String? iconKey;
  final double size;
  final AccountIconFallback fallback;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _resolveAsset(iconKey, fallback),
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

enum AccountIconFallback { bankCard, cash, generic }

const Map<String, String> accountIconAssets = {
  'alipay': 'assets/icons/account/alipay.svg',
  'wechat_pay': 'assets/icons/account/wechat_pay.svg',
  'cmb_credit_card': 'assets/icons/account/cmb_credit_card.svg',
  'boc_debit_card': 'assets/icons/account/boc_debit_card.svg',
};

const List<AccountIconChoice> accountIconChoices = [
  AccountIconChoice(iconKey: 'alipay', label: '支付宝'),
  AccountIconChoice(iconKey: 'wechat_pay', label: '微信支付'),
  AccountIconChoice(iconKey: 'cmb_credit_card', label: '招商银行'),
  AccountIconChoice(iconKey: 'boc_debit_card', label: '中国银行'),
];

class AccountIconChoice {
  const AccountIconChoice({required this.iconKey, required this.label});

  final String iconKey;
  final String label;
}

const Map<AccountIconFallback, String> _fallbackAssets = {
  AccountIconFallback.bankCard: 'assets/icons/account/boc_debit_card.svg',
  AccountIconFallback.cash: 'assets/icons/account/boc_debit_card.svg',
  AccountIconFallback.generic: 'assets/icons/account/boc_debit_card.svg',
};

String _resolveAsset(String? iconKey, AccountIconFallback fallback) {
  if (iconKey != null && accountIconAssets.containsKey(iconKey)) {
    return accountIconAssets[iconKey]!;
  }
  return _fallbackAssets[fallback]!;
}
