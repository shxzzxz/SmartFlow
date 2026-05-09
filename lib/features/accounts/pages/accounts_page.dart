import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../design_system/theme/app_theme_extension.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_page_header.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../widgets/business/account_type_tag.dart';
import '../../../widgets/business/money_text.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountListProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: accountsAsync.when(
          loading: () => const _AccountsLoadingView(),
          error: (error, stackTrace) => _AccountsErrorView(error: error),
          data: (accounts) => _AccountsContent(accounts: accounts),
        ),
      ),
    );
  }
}

class _AccountsContent extends StatelessWidget {
  const _AccountsContent({required this.accounts});

  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space14,
        AppSpacing.space16,
        AppSpacing.space16,
      ),
      children: [
        AppPageHeader(
          title: '账户',
          subtitle: '管理资产与负债账户',
          actions: [
            AppHeaderIconButton(
              icon: Icons.add_rounded,
              tooltip: '新建账户',
              onPressed: () => context.push('/accounts/new'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space14),
        if (accounts.isEmpty)
          const _EmptyAccounts()
        else ...[
          _AccountsSummaryCard(accounts: accounts),
          const SizedBox(height: AppSpacing.space16),
          const _AccountsSectionHeader(),
          const SizedBox(height: AppSpacing.space8),
          for (final account in accounts) ...[
            _AccountTile(account: account),
            const SizedBox(height: AppSpacing.space8),
          ],
        ],
      ],
    );
  }
}

class _AccountsSummaryCard extends StatelessWidget {
  const _AccountsSummaryCard({required this.accounts});

  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    final assetMinor = accounts
        .where((account) => account.type == AccountType.asset)
        .fold(0, (sum, account) => sum + account.balance.minorUnits);
    final liabilityMinor = accounts
        .where((account) => account.type == AccountType.liability)
        .fold(0, (sum, account) => sum + account.balance.minorUnits);

    return AppSurface(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16,
          AppSpacing.space18,
          AppSpacing.space16,
          AppSpacing.space18,
        ),
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: AppTypography.fontSizeSm,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.space10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: MoneyText(
            money: money,
            style: textTheme.titleMedium?.copyWith(
              fontSize: AppTypography.fontSizeLg,
              fontWeight: FontWeight.w500,
            ),
            semantic: semantic,
          ),
        ),
      ],
    );
  }
}

class _AccountsSectionHeader extends StatelessWidget {
  const _AccountsSectionHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          '账户列表',
          style: textTheme.titleSmall?.copyWith(
            fontSize: AppTypography.fontSizeSm,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '点击查看流水',
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: AppTypography.fontSizeXs,
          ),
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financeColors = Theme.of(context).extension<AppThemeExtension>()!;
    final semantic =
        account.type == AccountType.asset
            ? MoneySemantic.asset
            : MoneySemantic.liability;
    final accent =
        account.type == AccountType.asset
            ? financeColors.asset
            : financeColors.liability;

    return AppSurface(
      border: true,
      child: InkWell(
        onTap: () => context.push('/accounts/${account.id}'),
        borderRadius: BorderRadius.circular(AppRadius.radiusXl),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space14,
            AppSpacing.space10,
            AppSpacing.space14,
            AppSpacing.space10,
          ),
          child: Row(
            children: [
              _AccountIcon(type: account.type, color: accent),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Wrap(
                      spacing: AppSpacing.space8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AccountTypeTag(type: account.type),
                        if (account.note?.trim().isNotEmpty == true)
                          Text(
                            account.note!.trim(),
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: AppTypography.fontSizeXs,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 128),
                child: MoneyText(
                  money: account.balance,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: AppTypography.fontSizeMd,
                    fontWeight: FontWeight.w500,
                  ),
                  semantic: semantic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountIcon extends StatelessWidget {
  const _AccountIcon({required this.type, required this.color});

  final AccountType type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.space32,
      height: AppSpacing.space32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.radiusMd),
      ),
      child: Icon(
        type == AccountType.asset
            ? Icons.account_balance_wallet_outlined
            : Icons.credit_card_rounded,
        color: color,
        size: AppSpacing.space20,
      ),
    );
  }
}

class _AccountsLoadingView extends StatelessWidget {
  const _AccountsLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space14,
        AppSpacing.space16,
        AppSpacing.space16,
      ),
      children: const [
        AppPageHeader(title: '账户', subtitle: '管理资产与负债账户'),
        SizedBox(height: AppSpacing.space14),
        AppSurface(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.space24),
            child: LinearProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

class _AccountsErrorView extends StatelessWidget {
  const _AccountsErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space14,
        AppSpacing.space16,
        AppSpacing.space16,
      ),
      children: [
        const AppPageHeader(title: '账户', subtitle: '管理资产与负债账户'),
        const SizedBox(height: AppSpacing.space14),
        AppSurface(
          border: true,
          child: ListTile(
            leading: const Icon(Icons.error_outline_rounded),
            title: const Text('账户加载失败'),
            subtitle: Text('$error'),
          ),
        ),
      ],
    );
  }
}

class _EmptyAccounts extends StatelessWidget {
  const _EmptyAccounts();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurface(
      border: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Text(
                '还没有账户',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/accounts/new'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('新建'),
            ),
          ],
        ),
      ),
    );
  }
}
