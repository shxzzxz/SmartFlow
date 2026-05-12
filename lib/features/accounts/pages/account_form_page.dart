import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/account_service.dart';
import '../../../widgets/business/business_icon.dart';
import '../../../widgets/business/icon_choice_grid.dart';

enum _AccountKind { fund, liability, reimbursement }

class AccountFormPage extends ConsumerStatefulWidget {
  const AccountFormPage({super.key});

  @override
  ConsumerState<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends ConsumerState<AccountFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _openingBalanceController = TextEditingController(text: '0');
  final _creditLimitController = TextEditingController();
  final _noteController = TextEditingController();
  _AccountKind _kind = _AccountKind.fund;
  String _currencyCode = Money.defaultCurrency;
  String _iconKey = _defaultAccountIconKey(_AccountKind.fund);
  int? _billingDay;
  int? _repaymentDay;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _openingBalanceController.dispose();
    _creditLimitController.dispose();
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
          child: Column(
            children: [
              _AccountFormHeader(submitting: _submitting, onSave: _submit),
              _AccountKindTabs(kind: _kind, onChanged: _switchKind),
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
                      choices: _accountIconGridItems,
                      selectedKey: _iconKey,
                      onChanged: (value) => setState(() => _iconKey = value),
                    ),
                    const SizedBox(height: AppSpacing.space20),
                    const Divider(height: 1),
                    _PlainFormRow(
                      label: '账户名称',
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: '请输入账户名称',
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.next,
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? '请输入账户名称'
                                    : null,
                      ),
                    ),
                    const Divider(height: 1),
                    if (_kind != _AccountKind.reimbursement) ...[
                      _PlainFormRow(
                        label:
                            _kind == _AccountKind.liability ? '初始欠款' : '初始额度',
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _openingBalanceController,
                                decoration: InputDecoration(
                                  hintText:
                                      _kind == _AccountKind.liability
                                          ? '请输入初始欠款'
                                          : '请输入初始额度',
                                  border: InputBorder.none,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: _validateMoney,
                              ),
                            ),
                            InkWell(
                              onTap: _showCurrencySheet,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.space8,
                                  vertical: AppSpacing.space12,
                                ),
                                child: Text(
                                  _currencyLabel(_currencyCode),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                    if (_kind == _AccountKind.liability) ...[
                      _PlainFormRow(
                        label: '信用额度',
                        child: TextFormField(
                          controller: _creditLimitController,
                          decoration: const InputDecoration(
                            hintText: '请输入信用额度（可选）',
                            border: InputBorder.none,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validateOptionalMoney,
                        ),
                      ),
                      const Divider(height: 1),
                      _PlainFormRow(
                        label: '出账还款日',
                        child: _BillingRepaymentFields(
                          billingDay: _billingDay,
                          repaymentDay: _repaymentDay,
                          onSelectBillingDay:
                              () => _showDaySheet(
                                title: '选择出账日',
                                selectedDay: _billingDay,
                                onChanged:
                                    (day) => setState(() => _billingDay = day),
                              ),
                          onSelectRepaymentDay:
                              () => _showDaySheet(
                                title: '选择还款日',
                                selectedDay: _repaymentDay,
                                onChanged:
                                    (day) =>
                                        setState(() => _repaymentDay = day),
                              ),
                        ),
                      ),
                      const Divider(height: 1),
                    ],
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
            ],
          ),
        ),
      ),
    );
  }

  void _switchKind(_AccountKind kind) {
    if (kind == _kind) return;
    setState(() {
      _kind = kind;
      _iconKey = _defaultAccountIconKey(kind);
    });
  }

  String? _validateMoney(String? value) {
    try {
      final money = Money.parse(value ?? '0');
      if (money.minorUnits < 0) {
        return '请输入非负金额';
      }
      return null;
    } on FormatException {
      return '请输入有效金额';
    }
  }

  String? _validateOptionalMoney(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return _validateMoney(text);
  }

  Money _openingBalanceForKind() {
    if (_kind == _AccountKind.reimbursement) {
      return const Money(minorUnits: 0);
    }
    return Money.parse(_openingBalanceController.text, currency: _currencyCode);
  }

  Money? _creditLimitForKind() {
    if (_kind != _AccountKind.liability) {
      return null;
    }
    final text = _creditLimitController.text.trim();
    return text.isEmpty ? null : Money.parse(text, currency: _currencyCode);
  }

  Future<void> _showCurrencySheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final option in _currencyOptions)
                ListTile(
                  leading: Icon(
                    _currencyCode == option.code
                        ? RemixIcons.checkbox_circle_fill
                        : RemixIcons.checkbox_blank_circle_line,
                  ),
                  title: Text(option.label),
                  onTap: () => Navigator.of(context).pop(option.code),
                ),
            ],
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    setState(() => _currencyCode = selected);
  }

  Future<void> _showDaySheet({
    required String title,
    required int? selectedDay,
    required ValueChanged<int?> onChanged,
  }) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space20,
                  AppSpacing.space4,
                  AppSpacing.space20,
                  AppSpacing.space8,
                ),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  selectedDay == null
                      ? RemixIcons.checkbox_circle_fill
                      : RemixIcons.checkbox_blank_circle_line,
                ),
                title: const Text('不设置'),
                onTap: () => Navigator.of(context).pop(0),
              ),
              for (var day = 1; day <= 31; day++)
                ListTile(
                  leading: Icon(
                    selectedDay == day
                        ? RemixIcons.checkbox_circle_fill
                        : RemixIcons.checkbox_blank_circle_line,
                  ),
                  title: Text('每月 $day 日'),
                  onTap: () => Navigator.of(context).pop(day),
                ),
            ],
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    onChanged(selected == 0 ? null : selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    final type = _accountTypeForKind(_kind);
    final result = await ref
        .read(accountServiceProvider)
        .createAccount(
          CreateAccountCommand(
            name: _nameController.text,
            type: type,
            currencyCode: _currencyCode,
            subtype: _accountSubtypeForKind(_kind),
            iconKey: _iconKey,
            openingBalance: _openingBalanceForKind(),
            openingOccurredAt: DateTime.now(),
            note: _noteController.text,
            creditLimit: _creditLimitForKind(),
            billingDay: _kind == _AccountKind.liability ? _billingDay : null,
            repaymentDay:
                _kind == _AccountKind.liability ? _repaymentDay : null,
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

class _AccountFormHeader extends StatelessWidget {
  const _AccountFormHeader({required this.submitting, required this.onSave});

  final bool submitting;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space12,
        AppSpacing.space12,
        AppSpacing.space4,
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: submitting ? null : onSave,
              child:
                  submitting
                      ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('保存'),
            ),
          ),
          Text(
            '新建账户',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _AccountKindTabs extends StatelessWidget {
  const _AccountKindTabs({required this.kind, required this.onChanged});

  final _AccountKind kind;
  final ValueChanged<_AccountKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AccountKindTab(
          label: '资金',
          selected: kind == _AccountKind.fund,
          onTap: () => onChanged(_AccountKind.fund),
        ),
        _AccountKindTab(
          label: '负债',
          selected: kind == _AccountKind.liability,
          onTap: () => onChanged(_AccountKind.liability),
        ),
        _AccountKindTab(
          label: '报销',
          selected: kind == _AccountKind.reimbursement,
          onTap: () => onChanged(_AccountKind.reimbursement),
        ),
      ],
    );
  }
}

class _AccountKindTab extends StatelessWidget {
  const _AccountKindTab({
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
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
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
  const _PlainFormRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
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
  }
}

class _PlainValueText extends StatelessWidget {
  const _PlainValueText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _BillingRepaymentFields extends StatelessWidget {
  const _BillingRepaymentFields({
    required this.billingDay,
    required this.repaymentDay,
    required this.onSelectBillingDay,
    required this.onSelectRepaymentDay,
  });

  final int? billingDay;
  final int? repaymentDay;
  final VoidCallback onSelectBillingDay;
  final VoidCallback onSelectRepaymentDay;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onSelectBillingDay,
            child: _PlainValueText(
              text: billingDay == null ? '出账日' : '$billingDay 日',
            ),
          ),
        ),
        Text('/', style: textStyle),
        Expanded(
          child: InkWell(
            onTap: onSelectRepaymentDay,
            child: _PlainValueText(
              text: repaymentDay == null ? '还款日' : '$repaymentDay 日',
            ),
          ),
        ),
      ],
    );
  }
}

AccountType _accountTypeForKind(_AccountKind kind) {
  return switch (kind) {
    _AccountKind.fund || _AccountKind.reimbursement => AccountType.asset,
    _AccountKind.liability => AccountType.liability,
  };
}

AccountSubtype? _accountSubtypeForKind(_AccountKind kind) {
  return switch (kind) {
    _AccountKind.reimbursement => AccountSubtype.reimbursement,
    _ => null,
  };
}

String _defaultAccountIconKey(_AccountKind kind) {
  return switch (kind) {
    _AccountKind.fund => 'alipay',
    _AccountKind.reimbursement => 'reimburse',
    _AccountKind.liability => 'cmb_credit_card',
  };
}

final List<IconChoiceGridItem> _accountIconGridItems = [
  for (final spec in businessIconSpecsForUsage(BusinessIconUsage.account))
    IconChoiceGridItem(
      iconKey: spec.iconKey,
      label: spec.label,
      iconBuilder:
          (context, size) => BusinessIcon(iconKey: spec.iconKey, size: size),
    ),
];

const List<_CurrencyOption> _currencyOptions = [
  _CurrencyOption(code: Money.defaultCurrency, label: 'CNY-人民币'),
];

String _currencyLabel(String code) {
  return _currencyOptions
      .firstWhere(
        (option) => option.code == code,
        orElse: () => _CurrencyOption(code: code, label: code),
      )
      .label;
}

class _CurrencyOption {
  const _CurrencyOption({required this.code, required this.label});

  final String code;
  final String label;
}
