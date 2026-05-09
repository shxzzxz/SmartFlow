import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_query_service.dart';
import '../../../domain/services/transaction_service.dart';
import '../../../widgets/business/category_icon.dart';
import '../../../widgets/business/finance_labels.dart';
import '../../../widgets/business/money_text.dart';

class TransactionDetailPage extends ConsumerWidget {
  const TransactionDetailPage({required this.transactionId, super.key});

  final int transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('交易详情'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(RemixIcons.more_2_fill),
            tooltip: '更多',
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (detail) {
          if (detail == null) {
            return const Center(child: Text('交易不存在'));
          }
          return _DetailBody(detail: detail);
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.detail});

  final TransactionDetailView detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = detail.transaction;
    final purpose = transaction.businessPurpose;
    final semantic = _semanticForPurpose(purpose);
    final accountInfo = _resolveAccountInfo(detail);

    final showRefund = purpose == BusinessPurpose.dailyExpense;
    final showReimbursement = purpose == BusinessPurpose.reimbursementAdvance;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              AppSpacing.space12,
              AppSpacing.space16,
              AppSpacing.space24,
            ),
            children: [
              _HeroCard(detail: detail, semantic: semantic),
              if (showRefund || showReimbursement) ...[
                const SizedBox(height: AppSpacing.space12),
                _RefundReimbursementCard(
                  detail: detail,
                  showRefund: showRefund,
                  showReimbursement: showReimbursement,
                ),
              ],
              const SizedBox(height: AppSpacing.space12),
              _PrimaryMetaCard(
                detail: detail,
                accountInfo: accountInfo,
                onAccountTap: () => _showAccountChangeUnsupported(context),
                onNoteTap: () => _editNote(context, ref),
              ),
              const SizedBox(height: AppSpacing.space12),
              _ExclusionCard(detail: detail),
            ],
          ),
        ),
        _ActionBar(detail: detail),
      ],
    );
  }

  Future<void> _editNote(BuildContext context, WidgetRef ref) async {
    final current = detail.transaction.note ?? '';
    final controller = TextEditingController(text: current);
    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('编辑备注'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '为这笔交易写点备注',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (updated == null) return;
    if (updated == current) return;

    final result = await ref
        .read(transactionServiceProvider)
        .updateTransactionMetadata(
          UpdateTransactionMetadataCommand(
            transactionId: detail.transaction.id,
            note: updated,
          ),
        );
    if (!context.mounted) return;
    _showResultSnackBar(context, result, success: '备注已更新');
  }

  void _showAccountChangeUnsupported(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('账户切换暂未支持，敬请期待下个版本'),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.detail, required this.semantic});

  final TransactionDetailView detail;
  final MoneySemantic semantic;

  @override
  Widget build(BuildContext context) {
    final transaction = detail.transaction;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categoryName = _resolveCategoryName(detail);
    final iconKey = _resolveCategoryIconKey(detail);
    final fallback = transaction.businessPurpose == BusinessPurpose.dailyIncome
        ? CategoryIconFallback.income
        : CategoryIconFallback.expense;
    final subtitle = _resolveHeroSubtitle(detail);

    return AppSurface(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.radiusMd),
              ),
              child: Center(
                child: CategoryIcon(
                  iconKey: iconKey,
                  size: 26,
                  fallback: fallback,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName ??
                        transactionPurposeLabel(transaction.businessPurpose),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            MoneyText(
              money: _signedAmount(transaction.primaryAmount, semantic),
              showSign: semantic == MoneySemantic.income,
              semantic: semantic,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefundReimbursementCard extends StatelessWidget {
  const _RefundReimbursementCard({
    required this.detail,
    required this.showRefund,
    required this.showReimbursement,
  });

  final TransactionDetailView detail;
  final bool showRefund;
  final bool showReimbursement;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    if (showRefund) {
      final refunded = detail.refundedTotal;
      final hasRefund = refunded != null && refunded.minorUnits > 0;
      rows.add(
        _ChevronRow(
          label: '退款金额',
          value: hasRefund ? refunded.format() : '无退款',
          valueSemantic: hasRefund ? MoneySemantic.income : null,
          enabled: hasRefund,
          onTap: hasRefund
              ? () => _showRefundList(context, detail.children)
              : null,
        ),
      );
    }
    if (showReimbursement) {
      final summary = detail.reimbursementSummary;
      final hasActivity =
          summary != null && summary.receivedAmount.minorUnits > 0;
      final value = summary == null
          ? '未报销'
          : summary.isClosed
              ? '已结束 · 实收 ${summary.receivedAmount.format()}'
              : hasActivity
                  ? '已收 ${summary.receivedAmount.format()} / 应收 ${summary.advanceAmount.format()}'
                  : '未报销';
      rows.add(
        _ChevronRow(
          label: '报销详情',
          value: value,
          enabled: hasActivity,
          onTap: hasActivity
              ? () => _showReimbursementList(context, detail.children)
              : null,
        ),
      );
    }

    return _RowCard(rows: rows);
  }

  void _showRefundList(
    BuildContext context,
    List<TransactionListItem> children,
  ) {
    final refunds = children
        .where((c) => c.businessPurpose == BusinessPurpose.refund)
        .toList();
    _showChildrenSheet(context, title: '退款记录', items: refunds);
  }

  void _showReimbursementList(
    BuildContext context,
    List<TransactionListItem> children,
  ) {
    final receipts = children
        .where(
          (c) =>
              c.businessPurpose == BusinessPurpose.reimbursementReceipt ||
              c.businessPurpose == BusinessPurpose.reimbursementClose,
        )
        .toList();
    _showChildrenSheet(context, title: '报销记录', items: receipts);
  }
}

class _PrimaryMetaCard extends StatelessWidget {
  const _PrimaryMetaCard({
    required this.detail,
    required this.accountInfo,
    required this.onAccountTap,
    required this.onNoteTap,
  });

  final TransactionDetailView detail;
  final _AccountInfo accountInfo;
  final VoidCallback onAccountTap;
  final VoidCallback onNoteTap;

  @override
  Widget build(BuildContext context) {
    final transaction = detail.transaction;
    final note = transaction.note;
    final hasNote = note != null && note.isNotEmpty;
    final colors = Theme.of(context).colorScheme;

    final rows = <Widget>[
      _ChevronRow(
        label: '交易时间',
        value: _formatDateTime(transaction.occurredAt),
        showChevron: false,
      ),
      _ChevronRow(
        label: '创建时间',
        value: _formatDateTime(transaction.createdAt),
        showChevron: false,
      ),
      if (accountInfo.label.isNotEmpty)
        _ChevronRow(
          label: accountInfo.label,
          value: accountInfo.value,
          onTap: onAccountTap,
        ),
      _ChevronRow(
        label: '备注',
        value: hasNote ? note : '点击添加备注',
        valueColor: hasNote ? null : colors.onSurfaceVariant,
        onTap: onNoteTap,
      ),
    ];

    return _RowCard(rows: rows);
  }
}

class _ExclusionCard extends ConsumerWidget {
  const _ExclusionCard({required this.detail});

  final TransactionDetailView detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = detail.transaction;
    return _RowCard(
      rows: [
        _SwitchRow(
          label: '不计入收支',
          value: transaction.isExcludedFromStats,
          onChanged: (next) => _toggleExcludeStats(context, ref, next),
        ),
        _SwitchRow(
          label: '不计入预算',
          value: transaction.isExcludedFromBudget,
          onChanged: (next) => _toggleExcludeBudget(context, ref, next),
        ),
      ],
    );
  }

  Future<void> _toggleExcludeStats(
    BuildContext context,
    WidgetRef ref,
    bool next,
  ) async {
    final result = await ref
        .read(transactionServiceProvider)
        .updateTransactionMetadata(
          UpdateTransactionMetadataCommand(
            transactionId: detail.transaction.id,
            isExcludedFromStats: next,
          ),
        );
    if (!context.mounted) return;
    _showResultSnackBar(context, result, success: null);
  }

  Future<void> _toggleExcludeBudget(
    BuildContext context,
    WidgetRef ref,
    bool next,
  ) async {
    final result = await ref
        .read(transactionServiceProvider)
        .updateTransactionMetadata(
          UpdateTransactionMetadataCommand(
            transactionId: detail.transaction.id,
            isExcludedFromBudget: next,
          ),
        );
    if (!context.mounted) return;
    _showResultSnackBar(context, result, success: null);
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return AppSurface(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                child: Divider(height: 1),
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _ChevronRow extends StatelessWidget {
  const _ChevronRow({
    required this.label,
    required this.value,
    this.onTap,
    this.showChevron = true,
    this.enabled = true,
    this.valueSemantic,
    this.valueColor,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool enabled;
  final MoneySemantic? valueSemantic;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tappable = onTap != null && enabled;
    final resolvedValueColor = valueColor ?? colors.onSurface;

    return InkWell(
      onTap: tappable ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space14,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: AppTypography.fontSizeMd,
                  color: resolvedValueColor,
                ),
              ),
            ),
            if (tappable && showChevron) ...[
              const SizedBox(width: AppSpacing.space4),
              Icon(
                RemixIcons.arrow_right_s_line,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space4,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.detail});

  final TransactionDetailView detail;

  @override
  Widget build(BuildContext context) {
    final transaction = detail.transaction;
    final purpose = transaction.businessPurpose;
    final closed = detail.reimbursementSummary?.isClosed ?? false;

    final actions = <Widget>[];
    switch (purpose) {
      case BusinessPurpose.dailyExpense:
        actions.add(
          _SecondaryAction(
            label: '退款',
            onPressed: () => context.push(
              '/transactions/${transaction.id}/refund',
            ),
          ),
        );
        actions.add(
          _PrimaryAction(
            label: '编辑',
            onPressed: () => _showEditUnsupported(context),
          ),
        );
        break;
      case BusinessPurpose.reimbursementAdvance:
        if (!closed) {
          actions.add(
            _SecondaryAction(
              label: '记一笔到账',
              onPressed: () => context.push(
                '/transactions/${transaction.id}/reimburse-receipt',
              ),
            ),
          );
          actions.add(
            _PrimaryAction(
              label: '结束报销',
              onPressed: () => context.push(
                '/transactions/${transaction.id}/reimburse-close',
              ),
            ),
          );
        } else {
          actions.add(
            _PrimaryAction(
              label: '编辑',
              onPressed: () => _showEditUnsupported(context),
            ),
          );
        }
        break;
      default:
        actions.add(
          _PrimaryAction(
            label: '编辑',
            onPressed: () => _showEditUnsupported(context),
          ),
        );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16,
          AppSpacing.space12,
          AppSpacing.space16,
          AppSpacing.space12,
        ),
        child: Row(
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.space12),
              Expanded(child: actions[i]),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditUnsupported(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('整笔编辑暂未支持，敬请期待下个版本'),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.space48,
      child: FilledButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.space48,
      child: OutlinedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

class _AccountInfo {
  const _AccountInfo({required this.label, required this.value});

  final String label;
  final String value;
}

_AccountInfo _resolveAccountInfo(TransactionDetailView detail) {
  final purpose = detail.transaction.businessPurpose;
  final entries = detail.entries;
  final asset = entries
      .where(
        (e) =>
            e.accountType == AccountType.asset ||
            e.accountType == AccountType.liability,
      )
      .toList();
  switch (purpose) {
    case BusinessPurpose.transfer:
      final from = asset.firstWhere(
        (e) => e.direction == EntryDirection.credit,
        orElse: () => asset.first,
      );
      final to = asset.firstWhere(
        (e) => e.direction == EntryDirection.debit,
        orElse: () => asset.first,
      );
      return _AccountInfo(
        label: '账户',
        value: '${from.accountName} → ${to.accountName}',
      );
    case BusinessPurpose.dailyIncome:
    case BusinessPurpose.refund:
    case BusinessPurpose.reimbursementReceipt:
    case BusinessPurpose.reimbursementClose:
    case BusinessPurpose.borrowing:
      final inAccount = asset.firstWhere(
        (e) => e.direction == EntryDirection.debit,
        orElse: () => asset.isEmpty ? _placeholder() : asset.first,
      );
      return _AccountInfo(label: '收支账户', value: inAccount.accountName);
    case BusinessPurpose.dailyExpense:
    case BusinessPurpose.reimbursementAdvance:
    case BusinessPurpose.debtRepayment:
      final outAccount = asset.firstWhere(
        (e) => e.direction == EntryDirection.credit,
        orElse: () => asset.isEmpty ? _placeholder() : asset.first,
      );
      return _AccountInfo(label: '收支账户', value: outAccount.accountName);
    case BusinessPurpose.openingBalance:
    case BusinessPurpose.balanceAdjustment:
      final acct = asset.firstWhere(
        (_) => true,
        orElse: () => _placeholder(),
      );
      return _AccountInfo(label: '账户', value: acct.accountName);
  }
}

EntryLineView _placeholder() {
  return EntryLineView(
    accountId: 0,
    accountName: '—',
    accountType: AccountType.asset,
    direction: EntryDirection.debit,
    amount: Money.zero(),
  );
}

String? _resolveCategoryName(TransactionDetailView detail) {
  final purpose = detail.transaction.businessPurpose;
  if (purpose == BusinessPurpose.dailyExpense ||
      purpose == BusinessPurpose.refund) {
    return detail.entries
        .firstWhere(
          (e) => e.accountType == AccountType.expense,
          orElse: _placeholder,
        )
        .accountName;
  }
  if (purpose == BusinessPurpose.dailyIncome) {
    return detail.entries
        .firstWhere(
          (e) => e.accountType == AccountType.income,
          orElse: _placeholder,
        )
        .accountName;
  }
  return null;
}

String? _resolveCategoryIconKey(TransactionDetailView detail) {
  return null;
}

String? _resolveHeroSubtitle(TransactionDetailView detail) {
  final transaction = detail.transaction;
  final counterparty = transaction.counterpartyName;
  if (counterparty != null && counterparty.isNotEmpty) {
    return counterparty;
  }
  return null;
}

MoneySemantic _semanticForPurpose(BusinessPurpose purpose) {
  return switch (purpose) {
    BusinessPurpose.dailyExpense ||
    BusinessPurpose.reimbursementAdvance ||
    BusinessPurpose.debtRepayment =>
      MoneySemantic.expense,
    BusinessPurpose.dailyIncome ||
    BusinessPurpose.refund ||
    BusinessPurpose.reimbursementReceipt ||
    BusinessPurpose.reimbursementClose ||
    BusinessPurpose.borrowing =>
      MoneySemantic.income,
    BusinessPurpose.transfer => MoneySemantic.neutral,
    BusinessPurpose.openingBalance ||
    BusinessPurpose.balanceAdjustment =>
      MoneySemantic.neutral,
  };
}

Money _signedAmount(Money money, MoneySemantic semantic) {
  if (semantic == MoneySemantic.expense) {
    return Money(minorUnits: -money.minorUnits, currency: money.currency);
  }
  return money;
}

String _formatDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}年${two(dt.month)}月${two(dt.day)}日 '
      '${two(dt.hour)}:${two(dt.minute)}';
}

void _showChildrenSheet(
  BuildContext context, {
  required String title,
  required List<TransactionListItem> items,
}) {
  if (items.isEmpty) return;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final textTheme = Theme.of(ctx).textTheme;
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space16,
            0,
            AppSpacing.space16,
            AppSpacing.space12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space8,
                ),
                child: Text(title, style: textTheme.titleMedium),
              ),
              for (final item in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(transactionPurposeLabel(item.businessPurpose)),
                  subtitle: Text(_formatDateTime(item.occurredAt)),
                  trailing: MoneyText(
                    money: _signedAmount(
                      item.primaryAmount,
                      _semanticForPurpose(item.businessPurpose),
                    ),
                    semantic: _semanticForPurpose(item.businessPurpose),
                    showSign:
                        _semanticForPurpose(item.businessPurpose) ==
                            MoneySemantic.income,
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    context.push('/transactions/${item.id}');
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

void _showResultSnackBar<T>(
  BuildContext context,
  Result<T> result, {
  String? success,
}) {
  final messenger = ScaffoldMessenger.of(context);
  result.when(
    success: (_) {
      if (success != null) {
        messenger.showSnackBar(SnackBar(content: Text(success)));
      }
    },
    failure: (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text('操作失败：${failure.message}')),
      );
    },
  );
}
