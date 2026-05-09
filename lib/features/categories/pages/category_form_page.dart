import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_form_section.dart';
import '../../../design_system/widgets/app_page_header.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/category_service.dart';
import '../../../widgets/business/category_icon.dart';
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
  String? _iconKey;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final parentOptions = ref
        .watch(categoryTreeProvider(_type))
        .maybeWhen(
          data: (nodes) => nodes.map((node) => node.account).toList(),
          orElse: () => const <Account>[],
        );

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              AppSpacing.space14,
              AppSpacing.space16,
              AppSpacing.space16,
            ),
            children: [
              const AppPageHeader(
                title: '新建分类',
                subtitle: '添加收入或支出分类',
                showBackButton: true,
              ),
              const SizedBox(height: AppSpacing.space14),
              AppFormSection(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '分类名称',
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入分类名称'
                                : null,
                  ),
                  DropdownButtonFormField<AccountType>(
                    initialValue: _type,
                    decoration: const InputDecoration(
                      labelText: '分类类型',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items:
                        const [AccountType.expense, AccountType.income]
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
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                  _IconPickerField(
                    selected: _iconKey,
                    onChanged: (value) => setState(() => _iconKey = value),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space24),
              SizedBox(
                height: AppSpacing.space48,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon:
                      _submitting
                          ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.check),
                  label: const Text('保存'),
                ),
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
    final result = await ref
        .read(categoryServiceProvider)
        .createCategory(
          CreateCategoryCommand(
            name: _nameController.text,
            type: _type,
            parentId: _parentId,
            iconKey: _iconKey,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
}

class _IconPickerField extends StatelessWidget {
  const _IconPickerField({required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '图标',
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: AppTypography.fontSizeSm,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        Wrap(
          spacing: AppSpacing.space8,
          runSpacing: AppSpacing.space8,
          children: [
            for (final choice in categoryIconChoices)
              _IconChoiceTile(
                choice: choice,
                selected: choice.iconKey == selected,
                onTap: () => onChanged(
                  choice.iconKey == selected ? null : choice.iconKey,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _IconChoiceTile extends StatelessWidget {
  const _IconChoiceTile({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final CategoryIconChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      child: Container(
        width: AppSpacing.space48,
        height: AppSpacing.space48,
        decoration: BoxDecoration(
          color:
              selected
                  ? colors.primary.withValues(alpha: 0.10)
                  : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: CategoryIcon(iconKey: choice.iconKey, size: 24),
        ),
      ),
    );
  }
}
