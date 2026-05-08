import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../widgets/business/account_type_tag.dart';
import '../../../widgets/business/money_text.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('账户')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/accounts/new'),
        icon: const Icon(Icons.add),
        label: const Text('新建账户'),
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const _EmptyAccounts();
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.space16),
            children: [
              _AccountsSummaryCard(accounts: accounts),
              const SizedBox(height: AppSpacing.space16),
              Text('账户列表', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.space8),
              for (final account in accounts) ...[
                _AccountTile(account: account),
                const SizedBox(height: AppSpacing.space8),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AccountsSummaryCard extends StatelessWidget {
  const _AccountsSummaryCard({required this.accounts});

  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final assetMinor = accounts
        .where((account) => account.type == AccountType.asset)
        .fold(0, (sum, account) => sum + account.balance.minorUnits);
    final liabilityMinor = accounts
        .where((account) => account.type == AccountType.liability)
        .fold(0, (sum, account) => sum + account.balance.minorUnits);

    return Card(
      color: colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryMetric(
                label: '资产',
                money: Money(minorUnits: assetMinor),
                semantic: MoneySemantic.asset,
              ),
            ),
            Expanded(
              child: _SummaryMetric(
                label: '负债',
                money: Money(minorUnits: liabilityMinor),
                semantic: MoneySemantic.liability,
              ),
            ),
            Expanded(
              child: _SummaryMetric(
                label: '净资产',
                money: Money(minorUnits: assetMinor - liabilityMinor),
                semantic: MoneySemantic.asset,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.money,
    required this.semantic,
  });

  final String label;
  final Money money;
  final MoneySemantic semantic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onSecondaryContainer,
              ),
        ),
        const SizedBox(height: AppSpacing.space4),
        MoneyText(
          money: money,
          style: Theme.of(context).textTheme.titleMedium,
          semantic: semantic,
        ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        onTap: () => context.push('/accounts/${account.id}'),
        leading: Icon(
          account.type == AccountType.asset
              ? Icons.account_balance_wallet
              : Icons.credit_card,
        ),
        title: Text(account.name),
        subtitle: Wrap(
          spacing: AppSpacing.space8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AccountTypeTag(type: account.type),
            if (account.note != null) Text(account.note!),
          ],
        ),
        trailing: MoneyText(
          money: account.balance,
          style: textTheme.titleMedium,
          semantic: account.type == AccountType.asset
              ? MoneySemantic.asset
              : MoneySemantic.liability,
        ),
      ),
    );
  }
}

class _EmptyAccounts extends StatelessWidget {
  const _EmptyAccounts();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              '还没有账户',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
