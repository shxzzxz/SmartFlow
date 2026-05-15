import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_datetime_picker.dart';
import '../../../design_system/widgets/app_form_field.dart';
import '../../../design_system/widgets/app_plain_form_row.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_service.dart';
import '../../../widgets/business/business_icon.dart';

class RepaymentFormPage extends ConsumerStatefulWidget {
  const RepaymentFormPage({required this.liabilityAccountId, super.key});

  final int liabilityAccountId;

  @override
  ConsumerState<RepaymentFormPage> createState() => _RepaymentFormPageState();
}

class _RepaymentFormPageState extends ConsumerState<RepaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _interestController = TextEditingController();
  final _discountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _occurredAt = DateTime.now();
  late int? _liabilityAccountId;
  int? _paidFromAccountId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _liabilityAccountId = widget.liabilityAccountId;
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestController.dispose();
    _discountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('还款')),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('加载失败：$error')),
        data: (accounts) {
          final liabilityAccounts =
              accounts.where(_isSelectableLiabilityAccount).toList();
          final liabilityAccountId = _selectedId(
            _liabilityAccountId,
            liabilityAccounts,
          );
          final repaymentAccounts =
              accounts
                  .where(
                    (account) =>
                        _isSelectableRepaymentAccount(account) &&
                        account.id != liabilityAccountId,
                  )
                  .toList();
          final paidFromAccountId = _selectedId(
            _paidFromAccountId,
            repaymentAccounts,
          );
          final liabilityAccount = _findAccount(
            liabilityAccounts,
            liabilityAccountId,
          );
          final paidFromAccount = _findAccount(
            repaymentAccounts,
            paidFromAccountId,
          );

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space28,
                AppSpacing.space18,
                AppSpacing.space28,
                AppSpacing.space24,
              ),
              children: [
                const Divider(height: 1),
                AppPlainFormRow(
                  label: '债务账户',
                  onTap:
                      liabilityAccounts.isEmpty
                          ? null
                          : () => _showAccountSheet(
                            title: '选择债务账户',
                            accounts: liabilityAccounts,
                            selectedId: liabilityAccountId,
                            onSelected:
                                (value) => setState(() {
                                  _liabilityAccountId = value;
                                  if (_paidFromAccountId == value) {
                                    _paidFromAccountId = null;
                                  }
                                }),
                          ),
                  child: _AccountValue(
                    account: liabilityAccount,
                    placeholder: '请选择债务账户',
                  ),
                ),
                const Divider(height: 1),
                AppPlainFormRow(
                  label: '金额',
                  child: AppPlainTextFormField(
                    controller: _principalController,
                    hintText: '请输入还款金额',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [_moneyInputFormatter],
                    validator: _validatePositiveMoney,
                  ),
                ),
                const Divider(height: 1),
                AppPlainFormRow(
                  label: '利息',
                  child: AppPlainTextFormField(
                    controller: _interestController,
                    hintText: '请输入利息（可选）',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [_moneyInputFormatter],
                    validator: _validateOptionalMoney,
                  ),
                ),
                const Divider(height: 1),
                AppPlainFormRow(
                  label: '优惠',
                  child: AppPlainTextFormField(
                    controller: _discountController,
                    hintText: '请输入优惠（可选）',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [_moneyInputFormatter],
                    validator: _validateOptionalMoney,
                  ),
                ),
                const Divider(height: 1),
                AppPlainFormRow(
                  label: '还款日期',
                  onTap: _pickDate,
                  child: AppPlainValueText(text: _formatDateTime(_occurredAt)),
                ),
                const Divider(height: 1),
                AppPlainFormRow(
                  label: '还款账户',
                  onTap:
                      repaymentAccounts.isEmpty
                          ? null
                          : () => _showAccountSheet(
                            title: '选择还款账户',
                            accounts: repaymentAccounts,
                            selectedId: paidFromAccountId,
                            onSelected:
                                (value) =>
                                    setState(() => _paidFromAccountId = value),
                          ),
                  child: _AccountValue(
                    account: paidFromAccount,
                    placeholder: '请选择还款账户',
                  ),
                ),
                const Divider(height: 1),
                AppPlainFormRow(
                  label: '备注',
                  minHeight: 88,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  child: AppPlainTextFormField(
                    controller: _noteController,
                    hintText: '请输入备注（可选）',
                    maxLines: 2,
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.space24),
                SizedBox(
                  height: AppSpacing.space48,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child:
                        _submitting
                            ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('保存'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showAppDateTimePicker(
      context: context,
      initialDateTime: _occurredAt,
      title: '选择还款日期',
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _occurredAt = picked;
    });
  }

  Future<void> _showAccountSheet({
    required String title,
    required List<Account> accounts,
    required int? selectedId,
    required ValueChanged<int> onSelected,
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
                  AppSpacing.space16,
                  0,
                  AppSpacing.space16,
                  AppSpacing.space8,
                ),
                child: Text(title),
              ),
              for (final account in accounts)
                ListTile(
                  leading: BusinessIcon(iconKey: account.iconKey),
                  title: Text(account.name),
                  trailing:
                      account.id == selectedId
                          ? const Icon(Icons.check_rounded)
                          : null,
                  onTap: () => Navigator.of(context).pop(account.id),
                ),
            ],
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    onSelected(selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final accounts = ref.read(accountListProvider).value ?? const <Account>[];
    final liabilityAccounts =
        accounts.where(_isSelectableLiabilityAccount).toList();
    final liabilityAccountId = _selectedId(
      _liabilityAccountId,
      liabilityAccounts,
    );
    final repaymentAccounts =
        accounts
            .where(
              (account) =>
                  _isSelectableRepaymentAccount(account) &&
                  account.id != liabilityAccountId,
            )
            .toList();
    final paidFromAccountId = _selectedId(
      _paidFromAccountId,
      repaymentAccounts,
    );
    if (liabilityAccountId == null) {
      _showError('请选择债务账户');
      return;
    }
    if (paidFromAccountId == null) {
      _showError('请选择还款账户');
      return;
    }
    final principal = Money.parse(_principalController.text);
    final interest = _parseOptionalMoney(_interestController.text);
    final discount = _parseOptionalMoney(_discountController.text);

    final note = _blankToNull(_noteController.text);

    setState(() => _submitting = true);
    final result = await ref
        .read(transactionServiceProvider)
        .createRepayment(
          CreateRepaymentCommand(
            principal: principal,
            interest: interest.minorUnits > 0 ? interest : null,
            discount: discount.minorUnits > 0 ? discount : null,
            liabilityAccountId: liabilityAccountId,
            paidFromAccountId: paidFromAccountId,
            occurredAt: _occurredAt,
            note: note,
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
        _showError(failure.message);
    }
  }

  String? _validatePositiveMoney(String? value) {
    try {
      final money = Money.parse(value ?? '');
      return money.minorUnits > 0 ? null : '金额必须大于 0';
    } on FormatException {
      return '请输入有效金额';
    }
  }

  String? _validateOptionalMoney(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    try {
      final money = Money.parse(trimmed);
      return money.minorUnits >= 0 ? null : '金额不能小于 0';
    } on FormatException {
      return '请输入有效金额';
    }
  }

  Money _parseOptionalMoney(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? Money.zero() : Money.parse(trimmed);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _AccountValue extends StatelessWidget {
  const _AccountValue({required this.account, required this.placeholder});

  final Account? account;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final account = this.account;
    if (account == null) {
      return AppPlainValueText(text: placeholder);
    }

    return Row(
      children: [
        BusinessIcon(iconKey: account.iconKey, size: AppSpacing.space20),
        const SizedBox(width: AppSpacing.space8),
        Expanded(child: AppPlainValueText(text: account.name)),
      ],
    );
  }
}

Account? _findAccount(List<Account> accounts, int? id) {
  if (id == null) return null;
  for (final account in accounts) {
    if (account.id == id) return account;
  }
  return null;
}

int? _selectedId(int? id, List<Account> accounts) {
  if (id == null) {
    return null;
  }
  for (final account in accounts) {
    if (account.id == id) {
      return id;
    }
  }
  return null;
}

bool _isSelectableLiabilityAccount(Account account) {
  return account.archivedAt == null && account.type == AccountType.liability;
}

bool _isSelectableRepaymentAccount(Account account) {
  return account.archivedAt == null &&
      account.subtype != AccountSubtype.reimbursement &&
      (account.type == AccountType.asset ||
          account.type == AccountType.liability);
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _formatDateTime(DateTime date) {
  final time =
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')} $time';
}

final _moneyInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'^\d*\.?\d{0,2}'),
);
