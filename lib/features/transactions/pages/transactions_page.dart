import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_query_service.dart';
import '../../../widgets/business/money_text.dart';
import '../../../widgets/business/transaction_purpose_badge.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider());

    return Scaffold(
      appBar: AppBar(title: const Text('流水')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/new'),
        icon: const Icon(Icons.add),
        label: const Text('记一笔'),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('暂无流水'));
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.space16),
            children: [
              _TransactionSummaryCard(items: items),
              const SizedBox(height: AppSpacing.space16),
              Text('全部流水', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.space8),
              for (final item in items) ...[
                _TransactionTile(item: item),
                const SizedBox(height: AppSpacing.space8),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TransactionSummaryCard extends StatelessWidget {
  const _TransactionSummaryCard({required this.items});

  final List<TransactionListItem> items;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthItems = items.where(
      (item) =>
          item.occurredAt.year == now.year &&
          item.occurredAt.month == now.month,
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
              child: _SummaryMetric(
                label: '本月收入',
                money: Money(minorUnits: incomeMinor),
                semantic: MoneySemantic.income,
              ),
            ),
            Expanded(
              child: _SummaryMetric(
                label: '本月支出',
                money: Money(minorUnits: expenseMinor),
                semantic: MoneySemantic.expense,
              ),
            ),
            Expanded(
              child: _SummaryMetric(
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
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    final semantic = _moneySemanticForPurpose(item.businessPurpose);

    return Card(
      child: ListTile(
        onTap: () => context.push('/transactions/${item.id}'),
        title: Text(item.counterpartyName ?? item.note ?? '交易'),
        subtitle: Wrap(
          spacing: AppSpacing.space8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TransactionPurposeBadge(purpose: item.businessPurpose),
            if (item.accountNames.isNotEmpty) Text(item.accountNames),
          ],
        ),
        trailing: MoneyText(
          money: item.primaryAmount,
          style: Theme.of(context).textTheme.titleMedium,
          semantic: semantic,
        ),
      ),
    );
  }
}

MoneySemantic _moneySemanticForPurpose(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.dailyIncome ||
    BusinessPurpose.refund ||
    BusinessPurpose.reimbursementReceipt ||
    BusinessPurpose.borrowing => MoneySemantic.income,
    BusinessPurpose.dailyExpense ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose.debtRepayment => MoneySemantic.expense,
    BusinessPurpose.transfer ||
    BusinessPurpose.openingBalance ||
    BusinessPurpose.balanceAdjustment ||
    BusinessPurpose.reimbursementClose => MoneySemantic.neutral,
  };
}
