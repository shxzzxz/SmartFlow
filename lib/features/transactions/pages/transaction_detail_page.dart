import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../domain/services/transaction_query_service.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('交易详情'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
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

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  final TransactionDetailView detail;

  @override
  Widget build(BuildContext context) {
    final transaction = detail.transaction;
    final purpose = transaction.businessPurpose;
    final semantic = _semanticForPurpose(purpose);
    final accountInfo = _resolveAccountInfo(detail);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              AppSpacing.space16,
              AppSpacing.space16,
              AppSpacing.space24,
            ),
            children: [
              _HeroCard(detail: detail, semantic: semantic),
              const SizedBox(height: AppSpacing.space16),
              _MetadataSection(detail: detail, accountInfo: accountInfo),
              if (detail.children.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.space16),
                _ChildrenSection(children: detail.children),
              ],
              const SizedBox(height: AppSpacing.space16),
              _AuditSection(detail: detail),
            ],
          ),
        ),
        _ActionBar(detail: detail),
      ],
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

    return AppSurface(
      border: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.radiusMd),
              ),
              child: Center(
                child: CategoryIcon(
                  iconKey: iconKey,
                  size: 28,
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
                  ),
                  if (transaction.counterpartyName != null &&
                      transaction.counterpartyName!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      transaction.counterpartyName!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
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
              style: textTheme.headlineSmall?.copyWith(
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

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.detail, required this.accountInfo});

  final TransactionDetailView detail;
  final _AccountInfo accountInfo;

  @override
  Widget build(BuildContext context) {
    final transaction = detail.transaction;
    final purpose = transaction.businessPurpose;
    final rows = <_MetaRow>[];

    if (purpose == BusinessPurpose.dailyExpense &&
        detail.refundedTotal != null &&
        detail.refundedTotal!.minorUnits > 0) {
      rows.add(
        _MetaRow(
          label: '退款金额',
          value: detail.refundedTotal!.format(),
        ),
      );
    }
    if (purpose == BusinessPurpose.reimbursementAdvance) {
      final summary = detail.reimbursementSummary;
      rows.add(
        _MetaRow(
          label: '报销详情',
          value: summary == null
              ? '未报销'
              : summary.isClosed
                  ? '已结束 · 实收 ${summary.receivedAmount.format()}'
                  : '已收 ${summary.receivedAmount.format()} / 应收 ${summary.advanceAmount.format()}',
        ),
      );
    }
    rows.add(
      _MetaRow(
        label: '交易时间',
        value: _formatDateTime(transaction.occurredAt),
      ),
    );
    if (accountInfo.label.isNotEmpty) {
      rows.add(_MetaRow(label: accountInfo.label, value: accountInfo.value));
    }
    if (transaction.note != null && transaction.note!.isNotEmpty) {
      rows.add(_MetaRow(label: '备注', value: transaction.note!));
    }
    rows.add(
      _MetaRow(
        label: '不计入收支',
        value: transaction.isExcludedFromStats ? '是' : '否',
      ),
    );
    rows.add(
      _MetaRow(
        label: '不计入预算',
        value: transaction.isExcludedFromBudget ? '是' : '否',
      ),
    );

    return AppSurface(
      border: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space12,
                ),
                child: rows[i],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: AppTypography.fontSizeMd,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChildrenSection extends StatelessWidget {
  const _ChildrenSection({required this.children});

  final List<TransactionListItem> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            0,
            AppSpacing.space4,
            AppSpacing.space8,
          ),
          child: Text('关联记录', style: textTheme.titleSmall),
        ),
        AppSurface(
          border: true,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _ChildItem(item: children[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ChildItem extends StatelessWidget {
  const _ChildItem({required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    final semantic = _semanticForPurpose(item.businessPurpose);
    return ListTile(
      title: Text(transactionPurposeLabel(item.businessPurpose)),
      subtitle: Text(_formatDateTime(item.occurredAt)),
      trailing: MoneyText(
        money: _signedAmount(item.primaryAmount, semantic),
        semantic: semantic,
        showSign: semantic == MoneySemantic.income,
      ),
      onTap: () => context.push('/transactions/${item.id}'),
    );
  }
}

class _AuditSection extends StatelessWidget {
  const _AuditSection({required this.detail});

  final TransactionDetailView detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(
          '业务分项与分录',
          style: textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        children: [
          AppSurface(
            border: true,
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
          const SizedBox(height: AppSpacing.space12),
          AppSurface(
            border: true,
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
        actions.add(_PrimaryAction(label: '编辑', onPressed: null));
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
          actions.add(_PrimaryAction(label: '已结束', onPressed: null));
        }
        break;
      default:
        actions.add(_PrimaryAction(label: '编辑', onPressed: null));
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
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
      '${two(dt.hour)}:${two(dt.minute)}';
}
