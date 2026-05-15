import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/theme/app_text_styles.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_datetime_picker.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_service.dart';
import '../../../widgets/business/business_icon.dart';
import '../../../widgets/business/finance_labels.dart';

class RepaymentFormPage extends ConsumerStatefulWidget {
  const RepaymentFormPage({required this.liabilityAccountId, super.key});

  final int liabilityAccountId;

  @override
  ConsumerState<RepaymentFormPage> createState() => _RepaymentFormPageState();
}

class _RepaymentFormPageState extends ConsumerState<RepaymentFormPage> {
  final _principalController = TextEditingController();
  final _interestController = TextEditingController();
  final _discountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _occurredAt = DateTime.now();
  int? _paidFromAccountId;
  bool _submitting = false;

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
      appBar: AppBar(title: const Text('还款')),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('加载失败：$error')),
        data: (accounts) {
          final liability = _findAccount(accounts, widget.liabilityAccountId);
          if (liability == null || liability.type != AccountType.liability) {
            return const Center(child: Text('债务账户不存在'));
          }
          final repaymentAccounts =
              accounts
                  .where(
                    (account) =>
                        _isSelectableRepaymentAccount(account) &&
                        account.id != liability.id,
                  )
                  .toList();
          final paidFrom =
              _findAccount(repaymentAccounts, _paidFromAccountId) ??
              (repaymentAccounts.isEmpty ? null : repaymentAccounts.first);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              AppSpacing.space12,
              AppSpacing.space16,
              AppSpacing.space32,
            ),
            children: [
              _DebtAccountCard(account: liability),
              const SizedBox(height: AppSpacing.space16),
              AppSurface(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    children: [
                      _MoneyField(
                        controller: _principalController,
                        label: '金额',
                        autofocus: true,
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      _MoneyField(
                        controller: _interestController,
                        label: '利息',
                        optional: true,
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      _MoneyField(
                        controller: _discountController,
                        label: '优惠',
                        optional: true,
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(labelText: '备注'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      _PlainSelector(
                        icon: RemixIcons.calendar_line,
                        label: '还款日期',
                        value: _formatDateTime(_occurredAt),
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      _PlainSelector(
                        icon: RemixIcons.wallet_3_line,
                        label: '还款账户',
                        value: paidFrom?.name ?? '暂无可选账户',
                        leading:
                            paidFrom == null
                                ? null
                                : BusinessIcon(
                                  iconKey: paidFrom.iconKey,
                                  size: 18,
                                ),
                        onTap:
                            repaymentAccounts.isEmpty
                                ? null
                                : () => _showAccountSheet(repaymentAccounts),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space20),
              FilledButton(
                onPressed:
                    _submitting || repaymentAccounts.isEmpty ? null : _submit,
                child:
                    _submitting
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('完成'),
              ),
            ],
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
    setState(() => _occurredAt = picked);
  }

  void _showAccountSheet(List<Account> accounts) {
    final selectedId = _paidFromAccountId ?? accounts.first.id;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final account in accounts)
                ListTile(
                  leading: Icon(
                    account.id == selectedId
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(account.name),
                  subtitle: Text(accountTypeLabel(account.type)),
                  onTap: () {
                    setState(() => _paidFromAccountId = account.id);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final principal = _parseRequiredMoney(_principalController.text);
    if (principal == null) {
      _showError('请输入有效还款金额');
      return;
    }
    final interest = _parseOptionalMoney(_interestController.text);
    final discount = _parseOptionalMoney(_discountController.text);
    if (interest == null || discount == null) {
      _showError('请输入有效金额');
      return;
    }

    final accounts = ref.read(accountListProvider).value ?? const <Account>[];
    final repaymentAccounts =
        accounts
            .where(
              (account) =>
                  _isSelectableRepaymentAccount(account) &&
                  account.id != widget.liabilityAccountId,
            )
            .toList();
    final paidFromAccountId =
        _paidFromAccountId ??
        (repaymentAccounts.isEmpty ? null : repaymentAccounts.first.id);
    if (paidFromAccountId == null) {
      _showError('请选择还款账户');
      return;
    }

    final note = _blankToNull(_noteController.text);
    final effectiveNote =
        discount.minorUnits > 0 && note == null ? '还款优惠' : note;

    setState(() => _submitting = true);
    final result = await ref
        .read(transactionServiceProvider)
        .createRepayment(
          CreateRepaymentCommand(
            principal: principal,
            interest: interest.minorUnits > 0 ? interest : null,
            discount: discount.minorUnits > 0 ? discount : null,
            liabilityAccountId: widget.liabilityAccountId,
            paidFromAccountId: paidFromAccountId,
            occurredAt: _occurredAt,
            note: effectiveNote,
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

  Money? _parseRequiredMoney(String value) {
    try {
      final money = Money.parse(value);
      return money.minorUnits > 0 ? money : null;
    } on FormatException {
      return null;
    }
  }

  Money? _parseOptionalMoney(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return Money.zero();
    }
    try {
      final money = Money.parse(trimmed);
      return money.minorUnits >= 0 ? money : null;
    } on FormatException {
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _DebtAccountCard extends StatelessWidget {
  const _DebtAccountCard({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;
    final typeText =
        account.subtype == null
            ? accountTypeLabel(account.type)
            : '${accountTypeLabel(account.type)} / '
                '${accountSubtypeLabel(account.subtype!)}';

    return AppSurface(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Row(
          children: [
            BusinessIcon(iconKey: account.iconKey, size: AppSpacing.space32),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: textStyles.subsectionTitleStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    typeText,
                    style: textStyles.listSupporting.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.controller,
    required this.label,
    this.optional = false,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final bool optional;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: optional ? '$label（可选）' : label,
        prefixText: '¥ ',
      ),
    );
  }
}

class _PlainSelector extends StatelessWidget {
  const _PlainSelector({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.leading,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space12,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.onSurfaceVariant),
            const SizedBox(width: AppSpacing.space10),
            Text(label, style: textStyles.formLabel),
            const Spacer(),
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.space6),
            ],
            Flexible(
              child: Text(
                value,
                style: textStyles.formValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Account? _findAccount(List<Account> accounts, int? id) {
  if (id == null) {
    return null;
  }
  for (final account in accounts) {
    if (account.id == id) {
      return account;
    }
  }
  return null;
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
