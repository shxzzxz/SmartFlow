import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../design_system/tokens/colors.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    required this.iconKey,
    super.key,
    this.size = 24,
    this.fallback = CategoryIconFallback.generic,
    this.color,
  });

  final String? iconKey;
  final double size;
  final CategoryIconFallback fallback;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final spec = resolveCategoryIconSpec(iconKey, fallback);
    return Icon(spec.icon, size: size, color: color ?? spec.color);
  }
}

enum CategoryIconFallback { generic, expense, income }

class CategoryIconSpec {
  const CategoryIconSpec({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

const _categoryIconSpecs = <String, CategoryIconSpec>{
  'coffee': CategoryIconSpec(
    icon: RemixIcons.cup_fill,
    color: AppColors.categoryFood,
  ),
  'meal': CategoryIconSpec(
    icon: RemixIcons.restaurant_2_fill,
    color: AppColors.categoryDining,
  ),
  'shopping': CategoryIconSpec(
    icon: RemixIcons.shopping_bag_3_fill,
    color: AppColors.categoryShopping,
  ),
  'metro': CategoryIconSpec(
    icon: RemixIcons.train_fill,
    color: AppColors.categoryTransport,
  ),
  'taxi': CategoryIconSpec(
    icon: RemixIcons.taxi_fill,
    color: AppColors.categoryTaxi,
  ),
  'book': CategoryIconSpec(
    icon: RemixIcons.book_open_fill,
    color: AppColors.categoryReading,
  ),
  'movie': CategoryIconSpec(
    icon: RemixIcons.film_fill,
    color: AppColors.categoryEntertainment,
  ),
  'salary': CategoryIconSpec(
    icon: RemixIcons.briefcase_4_fill,
    color: AppColors.categorySalary,
  ),
  'loan': CategoryIconSpec(
    icon: RemixIcons.bank_fill,
    color: AppColors.categoryLoan,
  ),
  'transfer': CategoryIconSpec(
    icon: RemixIcons.arrow_left_right_fill,
    color: AppColors.categoryTransfer,
  ),
  'expense': CategoryIconSpec(
    icon: RemixIcons.price_tag_3_fill,
    color: AppColors.categoryGenericExpense,
  ),
  'income': CategoryIconSpec(
    icon: RemixIcons.price_tag_3_fill,
    color: AppColors.categoryGenericIncome,
  ),
  'category': CategoryIconSpec(
    icon: RemixIcons.price_tag_3_fill,
    color: AppColors.categoryGenericNeutral,
  ),
  'home': CategoryIconSpec(
    icon: RemixIcons.home_5_fill,
    color: AppColors.categoryGenericNeutral,
  ),
  'gift': CategoryIconSpec(
    icon: RemixIcons.gift_fill,
    color: AppColors.categoryDining,
  ),
  'health': CategoryIconSpec(
    icon: RemixIcons.heart_pulse_fill,
    color: AppColors.categoryGenericExpense,
  ),
  'phone': CategoryIconSpec(
    icon: RemixIcons.smartphone_fill,
    color: AppColors.categoryGenericNeutral,
  ),
};

const _legacyLucideIconKeyAliases = <String, String>{
  'lucide:coffee': 'coffee',
  'lucide:cup-soda': 'coffee',
  'lucide:utensils': 'meal',
  'lucide:utensils-crossed': 'meal',
  'lucide:shopping-bag': 'shopping',
  'lucide:car': 'taxi',
  'lucide:train': 'metro',
  'lucide:bus': 'metro',
  'lucide:gamepad-2': 'movie',
  'lucide:film': 'movie',
  'lucide:house': 'home',
  'lucide:home': 'home',
  'lucide:smartphone': 'phone',
  'lucide:heart': 'health',
  'lucide:graduation-cap': 'book',
  'lucide:briefcase': 'salary',
  'lucide:coins': 'income',
  'lucide:banknote': 'income',
};

const _fallbackSpecs = <CategoryIconFallback, CategoryIconSpec>{
  CategoryIconFallback.expense: CategoryIconSpec(
    icon: RemixIcons.price_tag_3_fill,
    color: AppColors.categoryGenericExpense,
  ),
  CategoryIconFallback.income: CategoryIconSpec(
    icon: RemixIcons.price_tag_3_fill,
    color: AppColors.categoryGenericIncome,
  ),
  CategoryIconFallback.generic: CategoryIconSpec(
    icon: RemixIcons.price_tag_3_fill,
    color: AppColors.categoryGenericNeutral,
  ),
};

CategoryIconSpec resolveCategoryIconSpec(
  String? iconKey,
  CategoryIconFallback fallback,
) {
  final normalized = _normalizeIconKey(iconKey);
  if (normalized != null && _categoryIconSpecs.containsKey(normalized)) {
    return _categoryIconSpecs[normalized]!;
  }
  return _fallbackSpecs[fallback]!;
}

String? _normalizeIconKey(String? iconKey) {
  final trimmed = iconKey?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return _legacyLucideIconKeyAliases[trimmed] ?? trimmed;
}

const List<CategoryIconChoice> categoryIconChoices = [
  CategoryIconChoice(iconKey: 'coffee', label: '咖啡'),
  CategoryIconChoice(iconKey: 'meal', label: '餐饮'),
  CategoryIconChoice(iconKey: 'shopping', label: '购物'),
  CategoryIconChoice(iconKey: 'metro', label: '通勤'),
  CategoryIconChoice(iconKey: 'taxi', label: '打车'),
  CategoryIconChoice(iconKey: 'home', label: '居家'),
  CategoryIconChoice(iconKey: 'gift', label: '礼物'),
  CategoryIconChoice(iconKey: 'health', label: '医疗'),
  CategoryIconChoice(iconKey: 'phone', label: '通讯'),
  CategoryIconChoice(iconKey: 'book', label: '书籍'),
  CategoryIconChoice(iconKey: 'movie', label: '娱乐'),
  CategoryIconChoice(iconKey: 'salary', label: '工资'),
  CategoryIconChoice(iconKey: 'loan', label: '借贷'),
  CategoryIconChoice(iconKey: 'transfer', label: '转账'),
  CategoryIconChoice(iconKey: 'expense', label: '通用支出'),
  CategoryIconChoice(iconKey: 'income', label: '通用收入'),
  CategoryIconChoice(iconKey: 'category', label: '其他'),
];

class CategoryIconChoice {
  const CategoryIconChoice({required this.iconKey, required this.label});

  final String iconKey;
  final String label;
}
