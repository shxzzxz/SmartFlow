import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/category_service.dart';
import '../../../widgets/business/category_icon.dart';
import '../../../widgets/business/icon_choice_grid.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  const CategoryFormPage({
    super.key,
    this.initialType = AccountType.expense,
    this.initialParentId,
  });

  final AccountType initialType;
  final int? initialParentId;

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
  void initState() {
    super.initState();
    _type = widget.initialType;
    _parentId = widget.initialParentId;
    _iconKey = categoryIconChoices.first.iconKey;
  }

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
    final effectiveParent =
        parentOptions.where((parent) => parent.id == _parentId).firstOrNull;
    if (effectiveParent == null && _parentId != null) {
      _parentId = null;
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const _CategoryFormHeader(),
              _TypeTabs(type: _type, onChanged: _switchType),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space28,
                    AppSpacing.space24,
                    AppSpacing.space28,
                    AppSpacing.space24,
                  ),
                  children: [
                    IconChoiceGrid(
                      choices: _categoryIconGridItems,
                      selectedKey: _iconKey,
                      onChanged: (value) => setState(() => _iconKey = value),
                    ),
                    const SizedBox(height: AppSpacing.space20),
                    const Divider(height: 1),
                    _PlainFormRow(
                      label: '分类名称',
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: '请输入分类名称',
                          border: InputBorder.none,
                        ),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? '请输入分类名称'
                                    : null,
                      ),
                    ),
                    const Divider(height: 1),
                    _PlainFormRow(
                      label: '父分类',
                      onTap: () => _showParentSheet(parentOptions),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              effectiveParent?.name ?? '无',
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color:
                                    effectiveParent == null
                                        ? colors.onSurface
                                        : colors.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space6),
                          Icon(
                            RemixIcons.arrow_right_s_line,
                            color: colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    _PlainFormRow(
                      label: '备注',
                      child: TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          hintText: '请输入备注（可选）',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space24,
                    AppSpacing.space10,
                    AppSpacing.space24,
                    AppSpacing.space16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _submitting ? null : () => context.pop(),
                            child: const Text('取消'),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child:
                                _submitting
                                    ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('保存'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _switchType(AccountType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _parentId = null;
      _iconKey =
          type == AccountType.income
              ? 'salary'
              : categoryIconChoices.first.iconKey;
    });
  }

  Future<void> _showParentSheet(List<Account> parents) async {
    final selected = await showModalBottomSheet<int?>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: Icon(
                  _parentId == null
                      ? RemixIcons.checkbox_circle_fill
                      : RemixIcons.checkbox_blank_circle_line,
                ),
                title: const Text('无'),
                onTap: () => Navigator.of(context).pop(null),
              ),
              for (final parent in parents)
                ListTile(
                  leading: Icon(
                    _parentId == parent.id
                        ? RemixIcons.checkbox_circle_fill
                        : RemixIcons.checkbox_blank_circle_line,
                  ),
                  title: Text(parent.name),
                  onTap: () => Navigator.of(context).pop(parent.id),
                ),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    setState(() => _parentId = selected);
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

class _CategoryFormHeader extends StatelessWidget {
  const _CategoryFormHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space12,
        AppSpacing.space12,
        AppSpacing.space12,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(RemixIcons.arrow_left_s_line),
              iconSize: 32,
              tooltip: '返回',
            ),
          ),
          Text(
            '新增分类',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TypeTabs extends StatelessWidget {
  const _TypeTabs({required this.type, required this.onChanged});

  final AccountType type;
  final ValueChanged<AccountType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TypeTab(
          label: '支出',
          selected: type == AccountType.expense,
          onTap: () => onChanged(AccountType.expense),
        ),
        _TypeTab(
          label: '收入',
          selected: type == AccountType.income,
          onTap: () => onChanged(AccountType.income),
        ),
      ],
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space14),
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: selected ? 82 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.radiusSm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlainFormRow extends StatelessWidget {
  const _PlainFormRow({required this.label, required this.child, this.onTap});

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 70),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: AppTypography.fontSizeMd,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

final List<IconChoiceGridItem> _categoryIconGridItems = [
  for (final choice in categoryIconChoices)
    IconChoiceGridItem(
      iconKey: choice.iconKey,
      label: choice.label,
      iconBuilder:
          (context, size) => CategoryIcon(iconKey: choice.iconKey, size: size),
    ),
];
