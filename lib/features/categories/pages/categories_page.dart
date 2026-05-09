import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_page_header.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/category_service.dart';
import '../../../widgets/business/account_type_tag.dart';
import '../../../widgets/business/category_icon.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(categoryTreeProvider(AccountType.income));
    final expenseAsync = ref.watch(categoryTreeProvider(AccountType.expense));
    final colors = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space16,
                  AppSpacing.space14,
                  AppSpacing.space16,
                  AppSpacing.space10,
                ),
                child: AppPageHeader(
                  title: '分类',
                  subtitle: '维护收入与支出分类',
                  actions: [
                    AppHeaderIconButton(
                      icon: Icons.add_rounded,
                      tooltip: '新建分类',
                      onPressed: () => context.push('/categories/new'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space16,
                ),
                child: AppSurface(
                  border: true,
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [Tab(text: '支出'), Tab(text: '收入')],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Expanded(
                child: TabBarView(
                  children: [
                    _CategoryTreeList(
                      asyncValue: expenseAsync,
                      emptyLabel: '暂无支出分类',
                    ),
                    _CategoryTreeList(
                      asyncValue: incomeAsync,
                      emptyLabel: '暂无收入分类',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTreeList extends StatelessWidget {
  const _CategoryTreeList({required this.asyncValue, required this.emptyLabel});

  final AsyncValue<List<CategoryNode>> asyncValue;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const _CategoryLoadingView(),
      error: (error, stackTrace) => _CategoryErrorView(error: error),
      data: (nodes) {
        if (nodes.isEmpty) {
          return _EmptyCategories(label: emptyLabel);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space16,
            AppSpacing.space8,
            AppSpacing.space16,
            AppSpacing.space16,
          ),
          children: [
            for (final node in nodes) ...[
              AppSurface(
                border: true,
                child: ExpansionTile(
                  initiallyExpanded: node.children.isNotEmpty,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radiusXl),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radiusXl),
                  ),
                  leading: CategoryIcon(
                    iconKey: node.account.iconKey,
                    size: AppSpacing.space28,
                    fallback:
                        node.account.type == AccountType.income
                            ? CategoryIconFallback.income
                            : CategoryIconFallback.expense,
                  ),
                  title: Text(
                    node.account.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  subtitle: Wrap(
                    spacing: AppSpacing.space8,
                    children: [AccountTypeTag(type: node.account.type)],
                  ),
                  children: [
                    for (final child in node.children)
                      ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: AppSpacing.space48,
                          right: AppSpacing.space16,
                        ),
                        leading: Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          child.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: AppTypography.fontSizeSm),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
            ],
          ],
        );
      },
    );
  }
}

class _CategoryLoadingView extends StatelessWidget {
  const _CategoryLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space8,
        AppSpacing.space16,
        AppSpacing.space16,
      ),
      children: [
        AppSurface(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.space24),
            child: LinearProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

class _CategoryErrorView extends StatelessWidget {
  const _CategoryErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space8,
        AppSpacing.space16,
        AppSpacing.space16,
      ),
      children: [
        AppSurface(
          border: true,
          child: ListTile(
            leading: const Icon(Icons.error_outline_rounded),
            title: const Text('分类加载失败'),
            subtitle: Text('$error'),
          ),
        ),
      ],
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space8,
        AppSpacing.space16,
        AppSpacing.space16,
      ),
      children: [
        AppSurface(
          border: true,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Row(
              children: [
                Icon(Icons.category_outlined, color: colors.onSurfaceVariant),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/categories/new'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('新建'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
