import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../design_system/theme/app_theme_extension.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_query_service.dart';
import '../../../widgets/business/account_icon.dart';
import '../../../widgets/business/category_avatar.dart';
import '../view_models/transaction_row_presentation.dart';
import 'transaction_progress_badges.dart';

class TransactionRow extends StatelessWidget {
  const TransactionRow({required this.item, super.key});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final color = amountColor(colors, financeColors, item.businessPurpose);
    final title = transactionPrimaryLabel(item);
    final note = item.note?.trim();
    final hasNote = note != null && note.isNotEmpty;
    final subtitle =
        hasNote
            ? '${formatTime(item.occurredAt)}  $note'
            : formatTime(item.occurredAt);
    final hasBadges = _hasBadges(item);

    return InkWell(
      onTap: () => context.push('/transactions/${item.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CategoryAvatar(
              iconKey: resolveCategoryIconKey(item),
              fallback: categoryAvatarFallback(item.businessPurpose),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          title,
                          style: textTheme.titleSmall?.copyWith(
                            fontSize: AppTypography.fontSizeMd,
                            fontWeight: FontWeight.w400,
                            color: colors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (hasBadges) ...[
                        const SizedBox(width: AppSpacing.space8),
                        Flexible(child: TransactionProgressBadges(item: item)),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: AppTypography.fontSizeXs,
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatTransactionAmount(item),
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: AppTypography.fontSizeMd,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  _AccountLine(item: item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _hasBadges(TransactionListItem item) {
  return item.isExcludedFromStats ||
      item.isExcludedFromBudget ||
      item.refundedTotal != null ||
      item.reimbursementReceivedTotal != null ||
      item.repaymentInterest != null ||
      item.repaymentFee != null ||
      item.reimbursementGapIncome != null ||
      item.reimbursementGapExpense != null;
}

class _AccountLine extends ConsumerWidget {
  const _AccountLine({required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accountText = transactionAccountLabel(item);
    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final iconKey = _resolveIconKey(item, accounts);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AccountIcon(iconKey: iconKey, size: 12),
        const SizedBox(width: AppSpacing.space4),
        Flexible(
          child: Text(
            accountText.isEmpty ? '未分配账户' : accountText,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: AppTypography.fontSizeXs,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

String? _resolveIconKey(TransactionListItem item, List<Account> accounts) {
  final accountId = switch (item.businessPurpose) {
    BusinessPurpose.dailyExpense ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose
        .debtRepayment => item.flowOutAccountId ?? item.flowInAccountId,
    _ => item.flowInAccountId ?? item.flowOutAccountId,
  };
  if (accountId == null) return null;
  for (final account in accounts) {
    if (account.id == accountId) return account.iconKey;
  }
  return null;
}
