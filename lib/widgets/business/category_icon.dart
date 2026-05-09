import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    required this.iconKey,
    super.key,
    this.size = 24,
    this.fallback = CategoryIconFallback.generic,
  });

  final String? iconKey;
  final double size;
  final CategoryIconFallback fallback;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        _resolveAsset(iconKey, fallback),
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

enum CategoryIconFallback { generic, expense, income }

String _resolveAsset(String? iconKey, CategoryIconFallback fallback) {
  if (iconKey != null && categoryIconAssets.containsKey(iconKey)) {
    return categoryIconAssets[iconKey]!;
  }
  return switch (fallback) {
    CategoryIconFallback.expense => 'assets/icons/category/expense.svg',
    CategoryIconFallback.income => 'assets/icons/category/income.svg',
    CategoryIconFallback.generic => 'assets/icons/category/category.svg',
  };
}

const Map<String, String> categoryIconAssets = {
  'coffee': 'assets/icons/category/coffee.svg',
  'meal': 'assets/icons/category/meal.svg',
  'shopping': 'assets/icons/category/shopping.svg',
  'metro': 'assets/icons/category/metro.svg',
  'taxi': 'assets/icons/category/taxi.svg',
  'book': 'assets/icons/category/book.svg',
  'movie': 'assets/icons/category/movie.svg',
  'salary': 'assets/icons/category/salary.svg',
  'loan': 'assets/icons/category/loan.svg',
  'transfer': 'assets/icons/category/transfer.svg',
  'expense': 'assets/icons/category/expense.svg',
  'income': 'assets/icons/category/income.svg',
  'category': 'assets/icons/category/category.svg',
};

const List<CategoryIconChoice> categoryIconChoices = [
  CategoryIconChoice(iconKey: 'coffee', label: '咖啡'),
  CategoryIconChoice(iconKey: 'meal', label: '餐饮'),
  CategoryIconChoice(iconKey: 'shopping', label: '购物'),
  CategoryIconChoice(iconKey: 'metro', label: '通勤'),
  CategoryIconChoice(iconKey: 'taxi', label: '打车'),
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
