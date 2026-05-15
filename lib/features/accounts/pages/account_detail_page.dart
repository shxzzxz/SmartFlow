import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../design_system/theme/app_text_styles.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_query_service.dart';
import '../../../features/home/view_models/transaction_row_presentation.dart';
import '../../../features/home/widgets/transaction_row.dart';
import '../../../widgets/business/business_icon.dart';
import '../../../widgets/business/business_icon_bubble.dart';
import '../../../widgets/business/finance_labels.dart';
import '../../../widgets/business/money_text.dart';

class AccountDetailPage extends ConsumerWidget {
  const AccountDetailPage({required this.accountId, super.key});

  final int accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountListProvider);
    final transactionsAsync = ref.watch(
      transactionListProvider(accountId: accountId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('账户详情')),
      body: switch ((accountsAsync, transactionsAsync)) {
        (AsyncData(value: final accounts), AsyncData(value: final items)) =>
          _AccountDetailContent(
            account: _findAccount(accounts, accountId),
            transactions: items,
          ),
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) => Center(child: Text('加载失败：$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _AccountDetailContent extends StatelessWidget {
  const _AccountDetailContent({
    required this.account,
    required this.transactions,
  });

  final Account? account;
  final List<TransactionListItem> transactions;

  @override
  Widget build(BuildContext context) {
    final account = this.account;
    if (account == null) {
      return const Center(child: Text('账户不存在'));
    }

    final groups = _groupTransactionsByDay(transactions);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space12,
        AppSpacing.space16,
        AppSpacing.space32,
      ),
      children: [
        _AccountInfoSection(account: account),
        const SizedBox(height: AppSpacing.space16),
        _AccountActionBar(account: account),
        const SizedBox(height: AppSpacing.space20),
        Text('账户流水', style: context.appTextStyles.sectionTitleStrong),
        const SizedBox(height: AppSpacing.space12),
        if (groups.isEmpty)
          const _EmptyAccountTransactions()
        else
          for (final group in groups) ...[
            _AccountTransactionDaySection(group: group),
            const SizedBox(height: AppSpacing.space10),
          ],
      ],
    );
  }
}

class _AccountInfoSection extends StatelessWidget {
  const _AccountInfoSection({required this.account});

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
    final note = account.note?.trim();

    return AppSurface(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BusinessIconBubble(
                  size: AppSpacing.space48,
                  child: BusinessIcon(
                    iconKey: account.iconKey,
                    size: AppSpacing.space32,
                  ),
                ),
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
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space12),
              Text(
                note,
                style: textStyles.listSupporting.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.space16),
            Wrap(
              spacing: AppSpacing.space10,
              runSpacing: AppSpacing.space10,
              children: _metricItems(context, account),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _metricItems(BuildContext context, Account account) {
  final items = <Widget>[];
  final isLiability = account.type == AccountType.liability;
  final balanceLabel =
      isLiability
          ? '欠款'
          : account.subtype == AccountSubtype.reimbursement
          ? '应收'
          : '余额';
  items.add(
    _AccountMetricTile(
      label: balanceLabel,
      money: account.balance,
      semantic: isLiability ? MoneySemantic.liability : MoneySemantic.asset,
    ),
  );

  if (isLiability && account.creditLimit != null) {
    final remaining = account.creditLimit! - account.balance;
    items.add(
      _AccountMetricTile(
        label: '信用额度',
        money: account.creditLimit!,
        semantic: MoneySemantic.neutral,
      ),
    );
    items.add(
      _AccountMetricTile(
        label: '剩余额度',
        money: remaining,
        semantic: MoneySemantic.asset,
      ),
    );
  }
  if (isLiability && account.billingDay != null) {
    items.add(
      _AccountMetricTile(label: '出账日', value: '${account.billingDay}日'),
    );
  }
  if (isLiability && account.repaymentDay != null) {
    items.add(
      _AccountMetricTile(label: '还款日', value: '${account.repaymentDay}日'),
    );
  }
  return items;
}

class _AccountMetricTile extends StatelessWidget {
  const _AccountMetricTile({
    required this.label,
    this.money,
    this.value,
    this.semantic = MoneySemantic.neutral,
  });

  final String label;
  final Money? money;
  final String? value;
  final MoneySemantic semantic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textStyles.detailLabel.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          if (money != null)
            MoneyText(
              money: money!,
              semantic: semantic,
              style: textStyles.amountList,
            )
          else
            Text(value ?? '-', style: textStyles.formValue),
        ],
      ),
    );
  }
}

class _AccountActionBar extends StatelessWidget {
  const _AccountActionBar({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space10,
          vertical: AppSpacing.space8,
        ),
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: RemixIcons.add_circle_line,
                label: '记账',
                onTap: () => _openTransactionForm(context, account),
              ),
            ),
            if (account.type == AccountType.liability) ...[
              const SizedBox(width: AppSpacing.space8),
              Expanded(
                child: _ActionButton(
                  icon: RemixIcons.bank_card_line,
                  label: '还款',
                  onTap:
                      () => context.push('/accounts/${account.id}/repayment'),
                ),
              ),
            ],
            const SizedBox(width: AppSpacing.space8),
            Expanded(
              child: _ActionButton(
                icon: RemixIcons.arrow_left_right_line,
                label: '转账',
                onTap:
                    () => context.push(
                      '/transactions/new?mode=transfer&fromAccountId=${account.id}',
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: AppSpacing.space4),
            Text(label, style: textStyles.formLabel),
          ],
        ),
      ),
    );
  }
}

class _AccountTransactionDaySection extends StatelessWidget {
  const _AccountTransactionDaySection({required this.group});

  final _AccountTransactionDayGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dividerColor = colors.outlineVariant.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            0,
            AppSpacing.space4,
            AppSpacing.space8,
          ),
          child: Row(
            children: [
              Text(
                '${group.date.month}月${group.date.day}日',
                style: context.appTextStyles.dateSectionTitle,
              ),
              const SizedBox(width: AppSpacing.space8),
              Text(
                weekdayLabel(group.date),
                style: context.appTextStyles.listSupporting,
              ),
            ],
          ),
        ),
        AppSurface(
          child: Column(
            children: [
              for (var i = 0; i < group.items.length; i++) ...[
                TransactionRow(item: group.items[i]),
                if (i < group.items.length - 1)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                    ),
                    height: 1,
                    color: dividerColor,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyAccountTransactions extends StatelessWidget {
  const _EmptyAccountTransactions();

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Row(
          children: [
            Icon(
              RemixIcons.file_list_3_line,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.space10),
            const Expanded(child: Text('暂无账户流水')),
          ],
        ),
      ),
    );
  }
}

class _AccountTransactionDayGroup {
  const _AccountTransactionDayGroup({required this.date, required this.items});

  final DateTime date;
  final List<TransactionListItem> items;
}

List<_AccountTransactionDayGroup> _groupTransactionsByDay(
  List<TransactionListItem> items,
) {
  final groups = <DateTime, List<TransactionListItem>>{};
  for (final item in items) {
    final date = DateTime(
      item.occurredAt.year,
      item.occurredAt.month,
      item.occurredAt.day,
    );
    groups.putIfAbsent(date, () => []).add(item);
  }
  final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final date in dates)
      _AccountTransactionDayGroup(date: date, items: groups[date]!),
  ];
}

Account? _findAccount(List<Account> accounts, int id) {
  for (final account in accounts) {
    if (account.id == id) {
      return account;
    }
  }
  return null;
}

void _openTransactionForm(BuildContext context, Account account) {
  final query =
      Uri(
        path: '/transactions/new',
        queryParameters: {
          'fromAccountId': account.id.toString(),
          'toAccountId': account.id.toString(),
        },
      ).toString();
  context.push(query);
}
