import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_datetime_picker.dart';
import '../../../design_system/widgets/app_plain_form_row.dart';
import '../../../design_system/widgets/app_submit_button.dart';
import '../../../domain/accounts/account_usage.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/posting_command.dart';
import '../../../domain/services/transaction_query_service.dart';
import '../../../domain/services/transaction_service.dart';
import '../../../widgets/business/plain_transaction_fields.dart';

class RepaymentFormPage extends ConsumerStatefulWidget {
  const RepaymentFormPage({required this.liabilityAccountId, super.key})
    : editTransactionId = null,
      assert(liabilityAccountId != null);

  const RepaymentFormPage.edit({required this.editTransactionId, super.key})
    : liabilityAccountId = null,
      assert(editTransactionId != null);

  final int? liabilityAccountId;
  final int? editTransactionId;

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
  Money? _existingFee;
  int? _existingFeeExpenseAccountId;
  bool _submitting = false;
  bool _editInitialized = false;
  bool _excludeStats = false;
  bool _excludeBudget = false;

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
    final liabilityAccountsAsync = ref.watch(
      accountsForUsageProvider(AccountUsage.repaymentTarget),
    );
    final repaymentAccountsAsync = ref.watch(
      accountsForUsageProvider(AccountUsage.repaymentSource),
    );
    final editTransactionId = widget.editTransactionId;
    final editDetailAsync =
        editTransactionId == null
            ? null
            : ref.watch(transactionDetailProvider(editTransactionId));

    final accountsError =
        liabilityAccountsAsync.error ??
        repaymentAccountsAsync.error ??
        editDetailAsync?.error;
    if (accountsError != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(title: Text(_pageTitle)),
        body: Center(child: Text('加载失败：$accountsError')),
      );
    }
    if (!liabilityAccountsAsync.hasValue ||
        !repaymentAccountsAsync.hasValue ||
        (editTransactionId != null && !(editDetailAsync?.hasValue ?? false))) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(title: Text(_pageTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final editDetail = editDetailAsync?.value;
    if (editTransactionId != null && editDetail == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(title: Text(_pageTitle)),
        body: const Center(child: Text('交易不存在')),
      );
    }
    if (editDetail != null &&
        editDetail.transaction.businessPurpose !=
            BusinessPurpose.debtRepayment) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(title: Text(_pageTitle)),
        body: const Center(child: Text('该交易不是还款记录')),
      );
    }
    if (!_editInitialized && editDetail != null) {
      _applyEditData(editDetail);
    }

    final liabilityAccounts = liabilityAccountsAsync.value ?? const <Account>[];
    final allRepaymentAccounts =
        repaymentAccountsAsync.value ?? const <Account>[];
    final liabilityAccountId = _selectedId(
      _liabilityAccountId,
      liabilityAccounts,
    );
    final repaymentAccounts =
        allRepaymentAccounts
            .where((account) => account.id != liabilityAccountId)
            .toList();
    final paidFromAccountId = _selectedId(
      _paidFromAccountId,
      repaymentAccounts,
    );
    final liabilityAccount = _findAccount(
      liabilityAccounts,
      liabilityAccountId,
    );
    final paidFromAccount = _findAccount(repaymentAccounts, paidFromAccountId);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text(_pageTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space28,
            AppSpacing.space18,
            AppSpacing.space28,
            AppSpacing.space24,
          ),
          children: [
            AppPlainFormSection(
              children: [
                AccountPlainFormRow(
                  label: '债务账户',
                  account: liabilityAccount,
                  selectedId: liabilityAccountId,
                  placeholder: '请选择债务账户',
                  onTap:
                      liabilityAccounts.isEmpty
                          ? null
                          : () => _pickAccount(
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
                ),
                MoneyPlainFormRow(
                  label: '金额',
                  controller: _principalController,
                  hintText: '请输入还款金额',
                  validator: _validatePositiveMoney,
                ),
                MoneyPlainFormRow(
                  label: '利息',
                  controller: _interestController,
                  hintText: '请输入利息（可选）',
                  validator: _validateOptionalMoney,
                ),
                MoneyPlainFormRow(
                  label: '优惠',
                  controller: _discountController,
                  hintText: '请输入优惠（可选）',
                  validator: _validateOptionalMoney,
                ),
                DateTimePlainFormRow(
                  label: '还款日期',
                  value: _formatDateTime(_occurredAt),
                  onTap: _pickDate,
                ),
                AccountPlainFormRow(
                  label: '还款账户',
                  account: paidFromAccount,
                  selectedId: paidFromAccountId,
                  placeholder: '请选择还款账户',
                  onTap:
                      repaymentAccounts.isEmpty
                          ? null
                          : () => _pickAccount(
                            title: '选择还款账户',
                            accounts: repaymentAccounts,
                            selectedId: paidFromAccountId,
                            onSelected:
                                (value) =>
                                    setState(() => _paidFromAccountId = value),
                          ),
                ),
                NotePlainFormRow(controller: _noteController),
              ],
            ),
            const SizedBox(height: AppSpacing.space24),
            AppSubmitButton(
              label: '保存',
              loading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
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

  Future<void> _pickAccount({
    required String title,
    required List<Account> accounts,
    required int? selectedId,
    required ValueChanged<int> onSelected,
  }) async {
    final selected = await showAccountPickerSheet(
      context: context,
      title: title,
      accounts: accounts,
      selectedId: selectedId,
    );
    if (!mounted || selected == null) return;
    onSelected(selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final liabilityAccounts =
        ref
            .read(accountsForUsageProvider(AccountUsage.repaymentTarget))
            .value ??
        const <Account>[];
    final liabilityAccountId = _selectedId(
      _liabilityAccountId,
      liabilityAccounts,
    );
    final allRepaymentAccounts =
        ref
            .read(accountsForUsageProvider(AccountUsage.repaymentSource))
            .value ??
        const <Account>[];
    final repaymentAccounts =
        allRepaymentAccounts
            .where((account) => account.id != liabilityAccountId)
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
    final service = ref.read(transactionServiceProvider);
    final editTransactionId = widget.editTransactionId;
    final Result<PostTransactionResult> result;
    if (editTransactionId == null) {
      result = await service.createRepayment(
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
    } else {
      result = await service.correctTransaction(
        CorrectTransactionCommand(
          transactionId: editTransactionId,
          businessPurpose: BusinessPurpose.debtRepayment,
          amount: principal,
          repaymentInterest: interest.minorUnits > 0 ? interest : null,
          repaymentFee: _existingFee,
          repaymentDiscount: discount.minorUnits > 0 ? discount : null,
          feeExpenseAccountId: _existingFeeExpenseAccountId,
          liabilityAccountId: liabilityAccountId,
          paidFromAccountId: paidFromAccountId,
          occurredAt: _occurredAt,
          note: note,
          isExcludedFromStats: _excludeStats,
          isExcludedFromBudget: _excludeBudget,
        ),
      );
    }
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);

    switch (result) {
      case Success(:final value):
        if (editTransactionId == null) {
          context.pop();
        } else {
          if (context.canPop()) {
            context.pop(value.transactionId);
          } else {
            context.go('/transactions/${value.transactionId}');
          }
        }
      case FailureResult(:final failure):
        _showError(failure.message);
    }
  }

  void _applyEditData(TransactionDetailView detail) {
    final transaction = detail.transaction;
    _principalController.text =
        _detailAmount(
          detail,
          TransactionDetailType.repaymentPrincipal,
        ).format();
    _interestController.text =
        _optionalDetailAmount(
          detail,
          TransactionDetailType.repaymentInterest,
        )?.format() ??
        '';
    _discountController.text =
        _optionalDetailAmount(
          detail,
          TransactionDetailType.repaymentDiscount,
        )?.format() ??
        '';
    _noteController.text = transaction.note ?? '';
    _occurredAt = transaction.occurredAt;
    _excludeStats = transaction.isExcludedFromStats;
    _excludeBudget = transaction.isExcludedFromBudget;
    _existingFee = _optionalDetailAmount(
      detail,
      TransactionDetailType.repaymentFee,
    );
    _existingFeeExpenseAccountId = _expenseEntryAccountIdByAmount(
      detail,
      _existingFee,
    );
    _liabilityAccountId = _firstEntryAccountId(
      detail,
      accountType: AccountType.liability,
      direction: EntryDirection.debit,
    );
    _paidFromAccountId = _firstRepaymentSourceAccountId(detail);
    _editInitialized = true;
  }

  String get _pageTitle => widget.editTransactionId == null ? '还款' : '编辑还款';

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

Money _detailAmount(TransactionDetailView detail, TransactionDetailType type) {
  return _optionalDetailAmount(detail, type) ?? Money.zero();
}

Money? _optionalDetailAmount(
  TransactionDetailView detail,
  TransactionDetailType type,
) {
  for (final line in detail.details) {
    if (line.type == type) {
      return line.amount;
    }
  }
  return null;
}

int? _firstEntryAccountId(
  TransactionDetailView detail, {
  required AccountType accountType,
  required EntryDirection direction,
}) {
  for (final entry in detail.entries) {
    if (entry.accountType == accountType && entry.direction == direction) {
      return entry.accountId;
    }
  }
  return null;
}

int? _firstRepaymentSourceAccountId(TransactionDetailView detail) {
  for (final entry in detail.entries) {
    if (entry.direction != EntryDirection.credit) {
      continue;
    }
    if (entry.accountType == AccountType.asset ||
        entry.accountType == AccountType.liability) {
      return entry.accountId;
    }
  }
  return null;
}

int? _expenseEntryAccountIdByAmount(
  TransactionDetailView detail,
  Money? amount,
) {
  if (amount == null || amount.minorUnits <= 0) {
    return null;
  }
  for (final entry in detail.entries) {
    if (entry.accountType == AccountType.expense &&
        entry.direction == EntryDirection.debit &&
        entry.amount == amount) {
      return entry.accountId;
    }
  }
  return null;
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
