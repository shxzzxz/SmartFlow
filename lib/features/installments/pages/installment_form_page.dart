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
import '../../../domain/services/installment_service.dart';
import '../../../widgets/business/plain_transaction_fields.dart';

class InstallmentFormPage extends ConsumerStatefulWidget {
  const InstallmentFormPage({required this.liabilityAccountId, super.key});

  final int liabilityAccountId;

  @override
  ConsumerState<InstallmentFormPage> createState() =>
      _InstallmentFormPageState();
}

class _InstallmentFormPageState extends ConsumerState<InstallmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _totalPeriodsController = TextEditingController();
  final _rateController = TextEditingController();
  final _totalFeeController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _occurredAt = DateTime.now();
  InstallmentRepaymentMethod _method = InstallmentRepaymentMethod.equalInstallment;
  InterestRatePeriod _ratePeriod = InterestRatePeriod.monthly;
  InstallmentSourceType? _sourceType;
  int? _disbursementAccountId;
  bool _submitting = false;

  @override
  void dispose() {
    _principalController.dispose();
    _totalPeriodsController.dispose();
    _rateController.dispose();
    _totalFeeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liabilityAccountsAsync =
        ref.watch(accountsForUsageProvider(AccountUsage.repaymentTarget));
    final fundAccountsAsync =
        ref.watch(accountsForUsageProvider(AccountUsage.fund));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('新建分期')),
      body: switch ((liabilityAccountsAsync, fundAccountsAsync)) {
        (AsyncData(value: final liabilityAccounts), AsyncData(value: final fundAccounts)) =>
          _buildForm(context, liabilityAccounts, fundAccounts),
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) =>
          Center(child: Text('加载失败：$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<Account> liabilityAccounts,
    List<Account> fundAccounts,
  ) {
    final liability = _findAccount(liabilityAccounts, widget.liabilityAccountId);
    if (liability == null) {
      return const Center(child: Text('负债账户不存在'));
    }

    _sourceType ??= _defaultSourceType(liability);
    final isDisbursement = _sourceType == InstallmentSourceType.disbursement;

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
          AppPlainFormSection(
            children: [
              AppPlainFormRow(
                label: '负债账户',
                child: Text(
                  liability.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              _SourceTypeRow(
                value: _sourceType!,
                onChanged: (value) => setState(() => _sourceType = value),
              ),
              if (isDisbursement)
                AccountPlainFormRow(
                  label: '到账账户',
                  account: _findAccount(fundAccounts, _disbursementAccountId),
                  selectedId: _disbursementAccountId,
                  placeholder: '请选择放款入账账户',
                  onTap: fundAccounts.isEmpty
                      ? null
                      : () => _pickAccount(
                            title: '选择到账账户',
                            accounts: fundAccounts,
                            selectedId: _disbursementAccountId,
                            onSelected: (id) => setState(
                                () => _disbursementAccountId = id),
                          ),
                ),
              MoneyPlainFormRow(
                label: '本金',
                controller: _principalController,
                hintText: '请输入分期本金',
                validator: _validatePositiveMoney,
              ),
              _IntegerPlainFormRow(
                label: '期数',
                controller: _totalPeriodsController,
                hintText: '总期数',
                validator: _validatePositiveInt,
              ),
              DateTimePlainFormRow(
                label: '起始日',
                value: _formatDate(_startDate),
                onTap: _pickStartDate,
              ),
              _MethodRow(
                value: _method,
                onChanged: (value) => setState(() => _method = value),
              ),
              if (_method != InstallmentRepaymentMethod.flatFee &&
                  _method != InstallmentRepaymentMethod.custom)
                _RateRow(
                  ratePeriod: _ratePeriod,
                  rateController: _rateController,
                  onPeriodChanged: (period) =>
                      setState(() => _ratePeriod = period),
                ),
              if (_method == InstallmentRepaymentMethod.flatFee)
                MoneyPlainFormRow(
                  label: '总手续费',
                  controller: _totalFeeController,
                  hintText: '所有期次手续费合计（可选）',
                  validator: _validateOptionalMoney,
                ),
              if (isDisbursement)
                DateTimePlainFormRow(
                  label: '放款日期',
                  value: _formatDateTime(_occurredAt),
                  onTap: _pickOccurredAt,
                ),
              NotePlainFormRow(controller: _noteController),
            ],
          ),
          const SizedBox(height: AppSpacing.space24),
          AppSubmitButton(
            label: '创建分期',
            loading: _submitting,
            onPressed: () => _submit(liability),
          ),
        ],
      ),
    );
  }

  InstallmentSourceType _defaultSourceType(Account liability) {
    return liability.subtype == AccountSubtype.loan
        ? InstallmentSourceType.disbursement
        : InstallmentSourceType.billConversion;
  }

  Future<void> _pickStartDate() async {
    final picked = await showAppDateTimePicker(
      context: context,
      initialDateTime: _startDate,
      title: '选择起始日',
    );
    if (picked == null || !mounted) return;
    setState(() => _startDate = picked);
  }

  Future<void> _pickOccurredAt() async {
    final picked = await showAppDateTimePicker(
      context: context,
      initialDateTime: _occurredAt,
      title: '选择放款日期',
    );
    if (picked == null || !mounted) return;
    setState(() => _occurredAt = picked);
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

  Future<void> _submit(Account liability) async {
    if (!_formKey.currentState!.validate()) return;
    final principal = Money.parse(_principalController.text);
    final totalPeriods = int.parse(_totalPeriodsController.text.trim());
    final note = _blankToNull(_noteController.text);
    final isDisbursement = _sourceType == InstallmentSourceType.disbursement;
    if (isDisbursement && _disbursementAccountId == null) {
      _showError('请选择放款入账账户');
      return;
    }

    final ratePpm = _parseRatePpm(_rateController.text);
    final totalFeeMinor = _parseOptionalMoney(_totalFeeController.text).minorUnits;

    setState(() => _submitting = true);
    final service = ref.read(installmentServiceProvider);
    Result<CreateContractResult> result;
    if (isDisbursement) {
      result = await service.createDisbursementContract(
        CreateDisbursementContractCommand(
          liabilityAccountId: liability.id,
          disbursementAccountId: _disbursementAccountId!,
          principal: principal,
          totalPeriods: totalPeriods,
          startDate: _startDate,
          repaymentMethod: _method,
          interestRatePeriod: ratePpm == null ? null : _ratePeriod,
          interestRatePpm: ratePpm,
          totalFeeMinor: totalFeeMinor,
          occurredAt: _occurredAt,
          note: note,
        ),
      );
    } else {
      result = await service.createBillConversionContract(
        CreateBillConversionContractCommand(
          liabilityAccountId: liability.id,
          principal: principal,
          totalPeriods: totalPeriods,
          startDate: _startDate,
          repaymentMethod: _method,
          interestRatePeriod: ratePpm == null ? null : _ratePeriod,
          interestRatePpm: ratePpm,
          totalFeeMinor: totalFeeMinor,
          note: note,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _submitting = false);

    switch (result) {
      case Success(:final value):
        ref.invalidate(installmentContractsByAccountProvider(liability.id));
        context.go('/installments/${value.contractId}');
      case FailureResult(:final failure):
        _showError(failure.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
    if (trimmed.isEmpty) return null;
    try {
      Money.parse(trimmed);
      return null;
    } on FormatException {
      return '请输入有效金额';
    }
  }

  String? _validatePositiveInt(String? value) {
    final n = int.tryParse((value ?? '').trim());
    if (n == null || n <= 0) return '期数必须为正整数';
    return null;
  }

  Money _parseOptionalMoney(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? Money.zero() : Money.parse(trimmed);
  }

  /// 将输入字符串（百分比形式，如 "0.025" 表示 0.025%）转换为 ppm
  int? _parseRatePpm(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final percent = double.tryParse(trimmed);
    if (percent == null || percent <= 0) return null;
    return (percent * 10000).round();
  }
}

class _SourceTypeRow extends StatelessWidget {
  const _SourceTypeRow({required this.value, required this.onChanged});

  final InstallmentSourceType value;
  final ValueChanged<InstallmentSourceType> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppPlainFormRow(
      label: '类型',
      child: Wrap(
        spacing: AppSpacing.space8,
        children: [
          ChoiceChip(
            label: const Text('放款分期'),
            selected: value == InstallmentSourceType.disbursement,
            onSelected: (selected) {
              if (selected) onChanged(InstallmentSourceType.disbursement);
            },
          ),
          ChoiceChip(
            label: const Text('账单分期'),
            selected: value == InstallmentSourceType.billConversion,
            onSelected: (selected) {
              if (selected) onChanged(InstallmentSourceType.billConversion);
            },
          ),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({required this.value, required this.onChanged});

  final InstallmentRepaymentMethod value;
  final ValueChanged<InstallmentRepaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppPlainFormRow(
      label: '分期方式',
      child: DropdownButton<InstallmentRepaymentMethod>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(
            value: InstallmentRepaymentMethod.equalInstallment,
            child: Text('等额本息'),
          ),
          DropdownMenuItem(
            value: InstallmentRepaymentMethod.equalPrincipal,
            child: Text('等额本金'),
          ),
          DropdownMenuItem(
            value: InstallmentRepaymentMethod.interestFirst,
            child: Text('先息后本'),
          ),
          DropdownMenuItem(
            value: InstallmentRepaymentMethod.flatFee,
            child: Text('一次性手续费'),
          ),
          DropdownMenuItem(
            value: InstallmentRepaymentMethod.custom,
            child: Text('自定义'),
          ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.ratePeriod,
    required this.rateController,
    required this.onPeriodChanged,
  });

  final InterestRatePeriod ratePeriod;
  final TextEditingController rateController;
  final ValueChanged<InterestRatePeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return AppPlainFormRow(
      label: '利率(%)',
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: rateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '例：7.2',
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          DropdownButton<InterestRatePeriod>(
            value: ratePeriod,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(
                  value: InterestRatePeriod.annual, child: Text('年')),
              DropdownMenuItem(
                  value: InterestRatePeriod.monthly, child: Text('月')),
              DropdownMenuItem(
                  value: InterestRatePeriod.daily, child: Text('日')),
            ],
            onChanged: (v) {
              if (v != null) onPeriodChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

class _IntegerPlainFormRow extends StatelessWidget {
  const _IntegerPlainFormRow({
    required this.label,
    required this.controller,
    required this.hintText,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return AppPlainFormRow(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }
}

Account? _findAccount(List<Account> accounts, int? id) {
  if (id == null) return null;
  for (final a in accounts) {
    if (a.id == id) return a;
  }
  return null;
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime date) {
  final time = '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
  return '${_formatDate(date)} $time';
}
