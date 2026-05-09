import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../design_system/tokens/colors.dart';

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    required this.iconKey,
    super.key,
    this.size = 40,
    this.fallback = CategoryAvatarFallback.generic,
  });

  final String? iconKey;
  final double size;
  final CategoryAvatarFallback fallback;

  @override
  Widget build(BuildContext context) {
    final spec = _resolveSpec(iconKey, fallback);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: spec.background,
        shape: BoxShape.circle,
      ),
      child: Icon(
        spec.icon,
        color: AppColors.neutral99,
        size: size * 0.5,
      ),
    );
  }
}

enum CategoryAvatarFallback { generic, expense, income, transfer }

class _AvatarSpec {
  const _AvatarSpec({required this.icon, required this.background});

  final IconData icon;
  final Color background;
}

const _categoryPalette = <String, _AvatarSpec>{
  'coffee':
      _AvatarSpec(icon: RemixIcons.cup_fill, background: AppColors.categoryFood),
  'meal': _AvatarSpec(
      icon: RemixIcons.restaurant_2_fill,
      background: AppColors.categoryDining),
  'shopping': _AvatarSpec(
      icon: RemixIcons.shopping_bag_3_fill,
      background: AppColors.categoryShopping),
  'metro': _AvatarSpec(
      icon: RemixIcons.train_fill, background: AppColors.categoryTransport),
  'taxi': _AvatarSpec(
      icon: RemixIcons.taxi_fill, background: AppColors.categoryTaxi),
  'book': _AvatarSpec(
      icon: RemixIcons.book_open_fill, background: AppColors.categoryReading),
  'movie': _AvatarSpec(
      icon: RemixIcons.film_fill,
      background: AppColors.categoryEntertainment),
  'salary': _AvatarSpec(
      icon: RemixIcons.briefcase_4_fill, background: AppColors.categorySalary),
  'loan': _AvatarSpec(
      icon: RemixIcons.bank_fill, background: AppColors.categoryLoan),
  'transfer': _AvatarSpec(
      icon: RemixIcons.arrow_left_right_fill,
      background: AppColors.categoryTransfer),
  'expense': _AvatarSpec(
      icon: RemixIcons.price_tag_3_fill,
      background: AppColors.categoryGenericExpense),
  'income': _AvatarSpec(
      icon: RemixIcons.price_tag_3_fill,
      background: AppColors.categoryGenericIncome),
  'category': _AvatarSpec(
      icon: RemixIcons.price_tag_3_fill,
      background: AppColors.categoryGenericNeutral),
};

const _fallbackSpecs = <CategoryAvatarFallback, _AvatarSpec>{
  CategoryAvatarFallback.expense: _AvatarSpec(
      icon: RemixIcons.price_tag_3_fill,
      background: AppColors.categoryGenericExpense),
  CategoryAvatarFallback.income: _AvatarSpec(
      icon: RemixIcons.price_tag_3_fill,
      background: AppColors.categoryGenericIncome),
  CategoryAvatarFallback.transfer: _AvatarSpec(
      icon: RemixIcons.arrow_left_right_fill,
      background: AppColors.categoryTransfer),
  CategoryAvatarFallback.generic: _AvatarSpec(
      icon: RemixIcons.price_tag_3_fill,
      background: AppColors.categoryGenericNeutral),
};

_AvatarSpec _resolveSpec(String? iconKey, CategoryAvatarFallback fallback) {
  if (iconKey != null && _categoryPalette.containsKey(iconKey)) {
    return _categoryPalette[iconKey]!;
  }
  return _fallbackSpecs[fallback]!;
}
