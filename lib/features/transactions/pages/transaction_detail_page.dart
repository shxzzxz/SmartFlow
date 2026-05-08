import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../widgets/business/finance_labels.dart';
import '../../../widgets/business/money_text.dart';
import '../../../widgets/business/transaction_purpose_badge.dart';

class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({
    required this.transactionId,
    super.key,
  });

  final int transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('交易详情')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (detail) {
          if (detail == null) {
            return const Center(child: Text('交易不存在'));
          }

          final transaction = detail.transaction;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.space16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.space8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TransactionPurposeBadge(
                            purpose: transaction.businessPurpose,
                          ),
                          Text(transaction.occurredAt.toLocal().toString()),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      MoneyText(
                        money: transaction.primaryAmount,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (transaction.counterpartyName != null) ...[
                        const SizedBox(height: AppSpacing.space8),
                        Text(transaction.counterpartyName!),
                      ],
                      if (transaction.note != null) ...[
                        const SizedBox(height: AppSpacing.space8),
                        Text(transaction.note!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text('业务分项', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.space8),
              Card(
                child: Column(
                  children: [
                    for (final line in detail.details)
                      ListTile(
                        title: Text(transactionDetailTypeLabel(line.type)),
                        subtitle: Text('行号 ${line.lineNo}'),
                        trailing: MoneyText(money: line.amount),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text('复式分录', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.space8),
              Card(
                child: Column(
                  children: [
                    for (final entry in detail.entries)
                      ListTile(
                        title: Text(entry.accountName),
                        subtitle: Text(
                          '${accountTypeLabel(entry.accountType)} · '
                          '${entryDirectionLabel(entry.direction)}',
                        ),
                        trailing: MoneyText(money: entry.amount),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
