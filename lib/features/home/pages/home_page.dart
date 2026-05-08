import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_query_service.dart';
import '../../../widgets/business/money_text.dart';
import '../../../widgets/business/transaction_purpose_badge.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountListProvider);
    final transactionsAsync = ref.watch(transactionListProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFlow'),
        actions: [
          IconButton(
            onPressed: () => context.push('/transactions/new'),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '记一笔',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/new'),
        icon: const Icon(Icons.add),
        label: const Text('记一笔'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          children: [
            accountsAsync.when(
              loading: () => const _DashboardLoadingCard(),
              error: (error, stackTrace) => _DashboardErrorCard(error: error),
              data: (accounts) => _BalanceOverviewCard(accounts: accounts),
            ),
            const SizedBox(height: AppSpacing.space12),
            transactionsAsync.when(
              loading: () => const _DashboardLoadingCard(),
              error: (error, stackTrace) => _DashboardErrorCard(error: error),
              data: (transactions) =>
                  _MonthSummaryCard(transactions: transactions),
            ),
            const SizedBox(height: AppSpacing.space12),
            const _QuickActions(),
            const SizedBox(height: AppSpacing.space24),
            _SectionHeader(
              title: '最近流水',
              actionLabel: '全部',
              onTap: () => context.go('/transactions'),
            ),
            const SizedBox(height: AppSpacing.space8),
            transactionsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) => Text('$error'),
              data: (transactions) {
                final items = transactions.take(5).toList();
                if (items.isEmpty) {
                  return const Card(
                    child: ListTile(
                      leading: Icon(Icons.receipt_long_outlined),
                      title: Text('暂无流水'),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final item in items)
                      Card(
                        child: ListTile(
                          onTap: () => context.push('/transactions/${item.id}'),
                          title: Text(item.counterpartyName ?? item.note ?? '交易'),
                          subtitle: TransactionPurposeBadge(
                            purpose: item.businessPurpose,
                          ),
                          trailing: MoneyText(money: item.primaryAmount),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.space24),
            _SectionHeader(
              title: '账户',
              actionLabel: '管理',
              onTap: () => context.go('/accounts'),
            ),
            const SizedBox(height: AppSpacing.space8),
            accountsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) => Text('$error'),
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const Card(
                    child: ListTile(
                      leading: Icon(Icons.account_balance_wallet_outlined),
                      title: Text('还没有账户'),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final account in accounts.take(3))
                      Card(
                        child: ListTile(
                          onTap: () => context.push('/accounts/${account.id}'),
                          leading: Icon(
                            account.type == AccountType.asset
                                ? Icons.account_balance_wallet
                                : Icons.credit_card,
                          ),
                          title: Text(account.name),
                          subtitle: Text(
                            account.type == AccountType.asset ? '资产' : '负债',
                          ),
                          trailing: MoneyText(
                            money: account.balance,
                            semantic: account.type == AccountType.asset
                                ? MoneySemantic.asset
                                : MoneySemantic.liability,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceOverviewCard extends StatelessWidget {
  const _BalanceOverviewCard({required this.accounts});

  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final assetMinor = _sumByType(accounts, AccountType.asset);
    final liabilityMinor = _sumByType(accounts, AccountType.liability);
    final netWorth = Money(minorUnits: assetMinor - liabilityMinor);

    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '净资产',
              style: textTheme.labelLarge?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            MoneyText(
              money: netWorth,
              style: textTheme.headlineMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
              semantic: MoneySemantic.asset,
            ),
            const SizedBox(height: AppSpacing.space16),
            Row(
              children: [
                Expanded(
                  child: _MetricBlock(
                    label: '资产',
                    money: Money(minorUnits: assetMinor),
                    semantic: MoneySemantic.asset,
                  ),
                ),
                Expanded(
                  child: _MetricBlock(
                    label: '负债',
                    money: Money(minorUnits: liabilityMinor),
                    semantic: MoneySemantic.liability,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _sumByType(List<Account> accounts, AccountType type) {
    return accounts
        .where((account) => account.type == type)
        .fold(0, (sum, account) => sum + account.balance.minorUnits);
  }
}

class _MonthSummaryCard extends StatelessWidget {
  const _MonthSummaryCard({required this.transactions});

  final List<TransactionListItem> transactions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthItems = transactions.where(
      (item) =>
          item.occurredAt.year == now.year && item.occurredAt.month == now.month,
    );
    final incomeMinor = monthItems
        .where((item) => item.businessPurpose == BusinessPurpose.dailyIncome)
        .fold(0, (sum, item) => sum + item.primaryAmount.minorUnits);
    final expenseMinor = monthItems
        .where((item) => item.businessPurpose == BusinessPurpose.dailyExpense)
        .fold(0, (sum, item) => sum + item.primaryAmount.minorUnits);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Row(
          children: [
            Expanded(
              child: _MetricBlock(
                label: '本月收入',
                money: Money(minorUnits: incomeMinor),
                semantic: MoneySemantic.income,
              ),
            ),
            Expanded(
              child: _MetricBlock(
                label: '本月支出',
                money: Money(minorUnits: expenseMinor),
                semantic: MoneySemantic.expense,
              ),
            ),
            Expanded(
              child: _MetricBlock(
                label: '结余',
                money: Money(minorUnits: incomeMinor - expenseMinor),
                semantic: MoneySemantic.asset,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.money,
    this.semantic,
  });

  final String label;
  final Money money;
  final MoneySemantic? semantic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        MoneyText(
          money: money,
          style: textTheme.titleMedium,
          semantic: semantic,
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space12,
        ),
        child: Row(
          children: [
            _QuickActionButton(
              icon: Icons.edit_note,
              label: '记一笔',
              onTap: () => context.push('/transactions/new'),
            ),
            _QuickActionButton(
              icon: Icons.account_balance_wallet,
              label: '账户',
              onTap: () => context.go('/accounts'),
            ),
            _QuickActionButton(
              icon: Icons.receipt_long,
              label: '流水',
              onTap: () => context.go('/transactions'),
            ),
            _QuickActionButton(
              icon: Icons.category,
              label: '分类',
              onTap: () => context.go('/categories'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
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

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(height: AppSpacing.space4),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _DashboardLoadingCard extends StatelessWidget {
  const _DashboardLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space16),
        child: LinearProgressIndicator(),
      ),
    );
  }
}

class _DashboardErrorCard extends StatelessWidget {
  const _DashboardErrorCard({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline),
        title: const Text('数据加载失败'),
        subtitle: Text('$error'),
      ),
    );
  }
}
