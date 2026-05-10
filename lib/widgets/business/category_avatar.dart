import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

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
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Icon(
          spec.icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: size * 0.75,
        ),
      ),
    );
  }
}

enum CategoryAvatarFallback { generic, expense, income, transfer }

class _AvatarSpec {
  const _AvatarSpec({required this.icon});

  final IconData icon;
}

const _categoryPalette = <String, _AvatarSpec>{
  'coffee': _AvatarSpec(icon: RemixIcons.cup_fill),
  'meal': _AvatarSpec(icon: RemixIcons.restaurant_2_fill),
  'breakfast': _AvatarSpec(icon: RemixIcons.bowl_fill),
  'lunch': _AvatarSpec(icon: RemixIcons.briefcase_4_fill),
  'dinner': _AvatarSpec(icon: RemixIcons.restaurant_fill),
  'drink': _AvatarSpec(icon: RemixIcons.goblet_fill),
  'shopping': _AvatarSpec(icon: RemixIcons.shopping_bag_3_fill),
  'metro': _AvatarSpec(icon: RemixIcons.train_fill),
  'taxi': _AvatarSpec(icon: RemixIcons.taxi_fill),
  'book': _AvatarSpec(icon: RemixIcons.book_open_fill),
  'movie': _AvatarSpec(icon: RemixIcons.film_fill),
  'salary': _AvatarSpec(icon: RemixIcons.briefcase_4_fill),
  'loan': _AvatarSpec(icon: RemixIcons.bank_fill),
  'transfer': _AvatarSpec(icon: RemixIcons.arrow_left_right_fill),
  'home': _AvatarSpec(icon: RemixIcons.home_5_fill),
  'social': _AvatarSpec(icon: RemixIcons.user_3_fill),
  'gift': _AvatarSpec(icon: RemixIcons.gift_fill),
  'health': _AvatarSpec(icon: RemixIcons.heart_pulse_fill),
  'phone': _AvatarSpec(icon: RemixIcons.smartphone_fill),
  'snack': _AvatarSpec(icon: RemixIcons.cake_3_fill),
  'seafood': _AvatarSpec(icon: RemixIcons.gitlab_fill),
  'seasoning': _AvatarSpec(icon: RemixIcons.archive_fill),
  'expense': _AvatarSpec(icon: RemixIcons.price_tag_3_fill),
  'income': _AvatarSpec(icon: RemixIcons.price_tag_3_fill),
  'category': _AvatarSpec(icon: RemixIcons.price_tag_3_fill),
};

const _fallbackSpecs = <CategoryAvatarFallback, _AvatarSpec>{
  CategoryAvatarFallback.expense: _AvatarSpec(
    icon: RemixIcons.price_tag_3_fill,
  ),
  CategoryAvatarFallback.income: _AvatarSpec(icon: RemixIcons.price_tag_3_fill),
  CategoryAvatarFallback.transfer: _AvatarSpec(
    icon: RemixIcons.arrow_left_right_fill,
  ),
  CategoryAvatarFallback.generic: _AvatarSpec(
    icon: RemixIcons.price_tag_3_fill,
  ),
};

_AvatarSpec _resolveSpec(String? iconKey, CategoryAvatarFallback fallback) {
  if (iconKey != null && _categoryPalette.containsKey(iconKey)) {
    return _categoryPalette[iconKey]!;
  }
  return _fallbackSpecs[fallback]!;
}
