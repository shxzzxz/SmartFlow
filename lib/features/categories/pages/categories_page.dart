import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/category_service.dart';
import '../../../widgets/business/account_type_tag.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(categoryTreeProvider(AccountType.income));
    final expenseAsync = ref.watch(categoryTreeProvider(AccountType.expense));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('分类'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '支出'),
              Tab(text: '收入'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/categories/new'),
          icon: const Icon(Icons.add),
          label: const Text('新建分类'),
        ),
        body: TabBarView(
          children: [
            _CategoryTreeList(asyncValue: expenseAsync),
            _CategoryTreeList(asyncValue: incomeAsync),
          ],
        ),
      ),
    );
  }
}

class _CategoryTreeList extends StatelessWidget {
  const _CategoryTreeList({required this.asyncValue});

  final AsyncValue<List<CategoryNode>> asyncValue;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('$error')),
      data: (nodes) {
        if (nodes.isEmpty) {
          return const Center(child: Text('暂无分类'));
        }

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          children: [
            for (final node in nodes) ...[
              Card(
                child: ExpansionTile(
                  initiallyExpanded: node.children.isNotEmpty,
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(node.account.name),
                  subtitle: Wrap(
                    spacing: AppSpacing.space8,
                    children: [AccountTypeTag(type: node.account.type)],
                  ),
                  children: [
                    for (final child in node.children)
                      ListTile(
                        leading: const Icon(Icons.subdirectory_arrow_right),
                        title: Text(child.name),
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
