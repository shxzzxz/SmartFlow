import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_form_section.dart';
import '../../../design_system/widgets/app_page_header.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/account_service.dart';
import '../../../widgets/business/finance_labels.dart';

class AccountFormPage extends ConsumerStatefulWidget {
  const AccountFormPage({super.key});

  @override
  ConsumerState<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends ConsumerState<AccountFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _openingBalanceController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  AccountType _type = AccountType.asset;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _openingBalanceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
                title: '新建账户',
                subtitle: '添加资产或负债账户',
                showBackButton: true,
              ),
              const SizedBox(height: AppSpacing.space14),
              AppFormSection(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '账户名称',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    textInputAction: TextInputAction.next,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入账户名称'
                                : null,
                  ),
                  DropdownButtonFormField<AccountType>(
                    initialValue: _type,
                    decoration: const InputDecoration(
                      labelText: '账户类型',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items:
                        const [AccountType.asset, AccountType.liability]
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(accountTypeLabel(type)),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _type = value);
                      }
                    },
                  ),
                  TextFormField(
                    controller: _openingBalanceController,
                    decoration: const InputDecoration(
                      labelText: '期初余额',
                      prefixIcon: Icon(Icons.savings),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: _validateMoney,
                  ),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
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

  String? _validateMoney(String? value) {
    try {
      Money.parse(value ?? '0');
      return null;
    } on FormatException {
      return '请输入有效金额';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    final result = await ref
        .read(accountServiceProvider)
        .createAccount(
          CreateAccountCommand(
            name: _nameController.text,
            type: _type,
            openingBalance: Money.parse(_openingBalanceController.text),
            openingOccurredAt: DateTime.now(),
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
