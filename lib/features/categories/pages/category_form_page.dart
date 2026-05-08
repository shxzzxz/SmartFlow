import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/category_service.dart';
import '../../../widgets/business/finance_labels.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  const CategoryFormPage({super.key});

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  AccountType _type = AccountType.expense;
  int? _parentId;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parentOptions = ref.watch(categoryTreeProvider(_type)).maybeWhen(
          data: (nodes) => nodes.map((node) => node.account).toList(),
          orElse: () => const <Account>[],
        );

    return Scaffold(
      appBar: AppBar(title: const Text('新建分类')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.space16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? '请输入分类名称' : null,
              ),
              const SizedBox(height: AppSpacing.space16),
              DropdownButtonFormField<AccountType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: '分类类型',
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [AccountType.expense, AccountType.income]
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(accountTypeLabel(type)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                      _parentId = null;
                    });
                  }
                },
              ),
              const SizedBox(height: AppSpacing.space16),
              DropdownButtonFormField<int?>(
                key: ValueKey(_type),
                initialValue: _parentId,
                decoration: const InputDecoration(
                  labelText: '父分类',
                  prefixIcon: Icon(Icons.account_tree),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('无'),
                  ),
                  for (final parent in parentOptions)
                    DropdownMenuItem<int?>(
                      value: parent.id,
                      child: Text(parent.name),
                    ),
                ],
                onChanged: (value) => setState(() => _parentId = value),
              ),
              const SizedBox(height: AppSpacing.space16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.space24),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    final result = await ref.read(categoryServiceProvider).createCategory(
          CreateCategoryCommand(
            name: _nameController.text,
            type: _type,
            parentId: _parentId,
            note: _noteController.text,
          ),
        );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);

    switch (result) {
      case Success():
        context.pop();
      case FailureResult(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }
}
