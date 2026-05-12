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
import '../../../widgets/business/business_icon.dart';
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
            CategoryAvatar(iconKey: resolveCategoryIconKey(item)),
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
    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final textStyle = textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
      fontSize: AppTypography.fontSizeXs,
      fontWeight: FontWeight.w400,
    );
    final flow = _resolveAccountFlow(item, accounts);
    final fallbackText = transactionAccountLabel(item);

    if (flow.out != null && flow.in_ != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: _AccountEndpointView(endpoint: flow.out!, style: textStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Text(
              flow.separator,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
          Flexible(
            child: _AccountEndpointView(endpoint: flow.in_!, style: textStyle),
          ),
        ],
      );
    }

    final endpoint =
        flow.out ??
        flow.in_ ??
        _AccountEndpoint(
          label: fallbackText.isEmpty ? '未分配账户' : fallbackText,
          iconKey: null,
        );
    return Align(
      alignment: Alignment.centerRight,
      child: _AccountEndpointView(endpoint: endpoint, style: textStyle),
    );
  }
}

class _AccountFlow {
  const _AccountFlow({this.out, this.in_, this.separator = '→'});

  final _AccountEndpoint? out;
  final _AccountEndpoint? in_;
  final String separator;
}

_AccountFlow _resolveAccountFlow(
  TransactionListItem item,
  List<Account> accounts,
) {
  final flowOut = _resolveAccountEndpoint(
    id: item.flowOutAccountId,
    name: item.flowOutAccountName,
    accounts: accounts,
  );
  final flowIn = _resolveAccountEndpoint(
    id: item.flowInAccountId,
    name: item.flowInAccountName,
    accounts: accounts,
  );

  return switch (item.businessPurpose) {
    BusinessPurpose.dailyExpense => _AccountFlow(out: flowOut),
    BusinessPurpose.reimbursementAdvance => _AccountFlow(
      out: flowIn,
      in_: flowOut,
      separator: '|',
    ),
    BusinessPurpose.dailyIncome => _AccountFlow(in_: flowIn),
    _ => _AccountFlow(out: flowOut, in_: flowIn),
  };
}

class _AccountEndpoint {
  const _AccountEndpoint({required this.label, required this.iconKey});

  final String label;
  final String? iconKey;
}

class _AccountEndpointView extends StatelessWidget {
  const _AccountEndpointView({required this.endpoint, required this.style});

  final _AccountEndpoint endpoint;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BusinessIcon(iconKey: endpoint.iconKey, size: 12),
        const SizedBox(width: AppSpacing.space4),
        Flexible(
          child: Text(
            endpoint.label,
            style: style,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

_AccountEndpoint? _resolveAccountEndpoint({
  required int? id,
  required String? name,
  required List<Account> accounts,
}) {
  final account = _findAccount(id, accounts);
  final label = _cleanText(name) ?? account?.name;
  if (label == null) return null;
  return _AccountEndpoint(label: label, iconKey: account?.iconKey);
}

Account? _findAccount(int? id, List<Account> accounts) {
  if (id == null) return null;
  for (final account in accounts) {
    if (account.id == id) return account;
  }
  return null;
}

String? _cleanText(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
