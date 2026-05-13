import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../design_system/theme/app_text_styles.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../widgets/business/money_text.dart';
import '../../../widgets/business/transaction_purpose_badge.dart';

class AccountTransactionsPage extends ConsumerWidget {
  const AccountTransactionsPage({required this.accountId, super.key});

  final int accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(
      transactionListProvider(accountId: accountId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('账户流水')),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('暂无账户流水'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.space16),
            itemCount: items.length,
            separatorBuilder:
                (_, _) => const SizedBox(height: AppSpacing.space8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  onTap: () => context.push('/transactions/${item.id}'),
                  title: Text(item.counterpartyName ?? item.note ?? '交易'),
                  subtitle: Wrap(
                    spacing: AppSpacing.space8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TransactionPurposeBadge(purpose: item.businessPurpose),
                      Text(item.accountNames),
                    ],
                  ),
                  trailing: MoneyText(
                    money: item.primaryAmount,
                    style: context.appTextStyles.amountList,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
