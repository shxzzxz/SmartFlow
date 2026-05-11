import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:remixicon/remixicon.dart';

import '../../design_system/tokens/colors.dart';

enum BusinessIconSource { remixIcon, svgAsset }

enum BusinessIconUsage { expenseCategory, incomeCategory, system, account }

class BusinessIconSpec {
  const BusinessIconSpec.remix({
    required this.iconKey,
    required this.icon,
    required this.color,
    required this.label,
    this.usage = BusinessIconUsage.expenseCategory,
  }) : source = BusinessIconSource.remixIcon,
       assetPath = null;

  const BusinessIconSpec.svg({
    required this.iconKey,
    required this.assetPath,
    required this.color,
    required this.label,
    this.usage = BusinessIconUsage.account,
  }) : source = BusinessIconSource.svgAsset,
       icon = null;

  final String iconKey;
  final BusinessIconSource source;
  final IconData? icon;
  final String? assetPath;
  final Color color;
  final String label;
  final BusinessIconUsage usage;
}

class BusinessIcon extends StatelessWidget {
  const BusinessIcon({
    required this.iconKey,
    super.key,
    this.size = 24,
    this.color,
  });

  final String? iconKey;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final spec = resolveBusinessIconSpec(iconKey);
    return switch (spec.source) {
      BusinessIconSource.remixIcon => Icon(
        spec.icon,
        size: size,
        color:
            color ??
            IconTheme.of(context).color ??
            Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      BusinessIconSource.svgAsset => SvgPicture.asset(
        spec.assetPath!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      ),
    };
  }
}

const businessIconSpecs = <BusinessIconSpec>[
  BusinessIconSpec.remix(
    iconKey: 'social',
    icon: RemixIcons.user_3_line,
    color: AppColors.categorySocial,
    label: '人情社交',
  ),
  BusinessIconSpec.remix(
    iconKey: 'home',
    icon: RemixIcons.home_5_line,
    color: AppColors.categoryHome,
    label: '家里',
  ),
  BusinessIconSpec.remix(
    iconKey: 'meal',
    icon: RemixIcons.restaurant_2_line,
    color: AppColors.categoryDining,
    label: '食品餐饮',
  ),
  BusinessIconSpec.remix(
    iconKey: 'shopping',
    icon: RemixIcons.shopping_bag_3_line,
    color: AppColors.categoryShopping,
    label: '购物消费',
  ),
  BusinessIconSpec.remix(
    iconKey: 'coffee',
    icon: RemixIcons.cup_line,
    color: AppColors.categoryFood,
    label: '咖啡',
  ),
  BusinessIconSpec.remix(
    iconKey: 'breakfast',
    icon: RemixIcons.bowl_line,
    color: AppColors.categoryGift,
    label: '早餐',
  ),
  BusinessIconSpec.remix(
    iconKey: 'lunch',
    icon: RemixIcons.briefcase_4_line,
    color: AppColors.categoryGift,
    label: '午餐',
  ),
  BusinessIconSpec.remix(
    iconKey: 'dinner',
    icon: RemixIcons.restaurant_line,
    color: AppColors.categoryGift,
    label: '晚餐',
  ),
  BusinessIconSpec.remix(
    iconKey: 'drink',
    icon: RemixIcons.goblet_line,
    color: AppColors.categoryTransfer,
    label: '饮料酒水',
  ),
  BusinessIconSpec.remix(
    iconKey: 'snack',
    icon: RemixIcons.cake_3_line,
    color: AppColors.categorySnack,
    label: '休闲零食',
  ),
  BusinessIconSpec.remix(
    iconKey: 'seafood',
    icon: RemixIcons.gitlab_line,
    color: AppColors.categorySeafood,
    label: '生鲜食品',
  ),
  BusinessIconSpec.remix(
    iconKey: 'seasoning',
    icon: RemixIcons.archive_line,
    color: AppColors.categoryHome,
    label: '粮油调味',
  ),
  BusinessIconSpec.remix(
    iconKey: 'metro',
    icon: RemixIcons.train_line,
    color: AppColors.categoryTransport,
    label: '通勤',
  ),
  BusinessIconSpec.remix(
    iconKey: 'taxi',
    icon: RemixIcons.taxi_line,
    color: AppColors.categoryTaxi,
    label: '打车',
  ),
  BusinessIconSpec.remix(
    iconKey: 'gift',
    icon: RemixIcons.gift_line,
    color: AppColors.categoryGift,
    label: '礼物',
  ),
  BusinessIconSpec.remix(
    iconKey: 'health',
    icon: RemixIcons.heart_pulse_line,
    color: AppColors.categoryMedical,
    label: '医疗',
  ),
  BusinessIconSpec.remix(
    iconKey: 'phone',
    icon: RemixIcons.smartphone_line,
    color: AppColors.categoryGenericNeutral,
    label: '通讯',
  ),
  BusinessIconSpec.remix(
    iconKey: 'book',
    icon: RemixIcons.book_open_line,
    color: AppColors.categoryReading,
    label: '书籍',
  ),
  BusinessIconSpec.remix(
    iconKey: 'movie',
    icon: RemixIcons.film_line,
    color: AppColors.categoryEntertainment,
    label: '娱乐',
  ),
  BusinessIconSpec.remix(
    iconKey: 'salary',
    icon: RemixIcons.briefcase_4_line,
    color: AppColors.categorySalary,
    label: '工资',
    usage: BusinessIconUsage.incomeCategory,
  ),
  BusinessIconSpec.remix(
    iconKey: 'loan',
    icon: RemixIcons.bank_line,
    color: AppColors.categoryLoan,
    label: '借贷',
    usage: BusinessIconUsage.system,
  ),
  BusinessIconSpec.remix(
    iconKey: 'transfer',
    icon: RemixIcons.arrow_left_right_line,
    color: AppColors.categoryTransfer,
    label: '转账',
    usage: BusinessIconUsage.system,
  ),
  BusinessIconSpec.remix(
    iconKey: 'expense',
    icon: RemixIcons.price_tag_3_line,
    color: AppColors.categoryGenericExpense,
    label: '通用支出',
  ),
  BusinessIconSpec.remix(
    iconKey: 'income',
    icon: RemixIcons.price_tag_3_line,
    color: AppColors.categoryGenericIncome,
    label: '通用收入',
    usage: BusinessIconUsage.incomeCategory,
  ),
  BusinessIconSpec.remix(
    iconKey: 'category',
    icon: RemixIcons.price_tag_3_line,
    color: AppColors.categoryGenericNeutral,
    label: '其他',
  ),
  BusinessIconSpec.svg(
    iconKey: 'alipay',
    assetPath: 'assets/icons/account/alipay.svg',
    color: AppColors.categoryGenericNeutral,
    label: '支付宝',
  ),
  BusinessIconSpec.svg(
    iconKey: 'wechat_pay',
    assetPath: 'assets/icons/account/wechat_pay.svg',
    color: AppColors.categoryGenericNeutral,
    label: '微信支付',
  ),
  BusinessIconSpec.svg(
    iconKey: 'cmb_credit_card',
    assetPath: 'assets/icons/account/cmb_credit_card.svg',
    color: AppColors.categoryGenericNeutral,
    label: '招商银行',
  ),
  BusinessIconSpec.svg(
    iconKey: 'boc_debit_card',
    assetPath: 'assets/icons/account/boc_debit_card.svg',
    color: AppColors.categoryGenericNeutral,
    label: '中国银行',
  ),
  BusinessIconSpec.svg(
    iconKey: 'cash',
    assetPath: 'assets/icons/account/cash.svg',
    color: AppColors.categoryGenericNeutral,
    label: '现金',
  ),
  BusinessIconSpec.svg(
    iconKey: 'huabei',
    assetPath: 'assets/icons/account/huabei.svg',
    color: AppColors.categoryGenericNeutral,
    label: '花呗',
  ),
  BusinessIconSpec.svg(
    iconKey: 'loan_in',
    assetPath: 'assets/icons/account/loan_in.svg',
    color: AppColors.categoryGenericNeutral,
    label: '借入',
  ),
  BusinessIconSpec.svg(
    iconKey: 'loan_out',
    assetPath: 'assets/icons/account/loan_out.svg',
    color: AppColors.categoryGenericNeutral,
    label: '借出',
  ),
  BusinessIconSpec.svg(
    iconKey: 'reimburse',
    assetPath: 'assets/icons/account/reimburse.svg',
    color: AppColors.categoryGenericNeutral,
    label: '报销',
  ),
];

final Map<String, BusinessIconSpec> businessIconSpecsByKey = Map.unmodifiable({
  for (final spec in businessIconSpecs) spec.iconKey: spec,
});

List<BusinessIconSpec> businessIconSpecsForUsage(BusinessIconUsage usage) {
  return List.unmodifiable(
    businessIconSpecs.where((spec) => spec.usage == usage),
  );
}

const _fallbackIconSpec = BusinessIconSpec.remix(
  iconKey: 'fallback',
  icon: RemixIcons.remixicon_line,
  color: AppColors.categoryGenericNeutral,
  label: '图标',
  usage: BusinessIconUsage.system,
);

BusinessIconSpec resolveBusinessIconSpec(String? iconKey) {
  final normalized = normalizeBusinessIconKey(iconKey);
  if (normalized != null && businessIconSpecsByKey.containsKey(normalized)) {
    return businessIconSpecsByKey[normalized]!;
  }
  return _fallbackIconSpec;
}

String? normalizeBusinessIconKey(String? iconKey) {
  final trimmed = iconKey?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
