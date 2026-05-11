import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/widgets/app_surface.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/enums/accounting_enums.dart';
import '../../../widgets/business/business_icon.dart';
import '../../../widgets/business/business_icon_bubble.dart';
import '../../../widgets/business/finance_labels.dart';
import '../../../widgets/business/money_text.dart';

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});

  @override
  ConsumerState<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  bool _hideBalances = false;

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountListProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: accountsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _AccountsErrorView(error: error),
          data:
              (accounts) => _AccountsContent(
                accounts: accounts,
                hideBalances: _hideBalances,
                onToggleHide:
                    () => setState(() => _hideBalances = !_hideBalances),
              ),
        ),
      ),
    );
  }
}

class _AccountsContent extends StatelessWidget {
  const _AccountsContent({
    required this.accounts,
    required this.hideBalances,
    required this.onToggleHide,
  });

  final List<Account> accounts;
  final bool hideBalances;
  final VoidCallback onToggleHide;

  @override
  Widget build(BuildContext context) {
    final assets =
        accounts.where((account) => account.type == AccountType.asset).toList();
    final liabilities =
        accounts
            .where((account) => account.type == AccountType.liability)
            .toList();
    final assetMinor = assets.fold(0, (sum, account) {
      return sum + account.balance.minorUnits;
    });
    final liabilityMinor = liabilities.fold(0, (sum, account) {
      return sum + account.balance.minorUnits;
    });

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space20,
        AppSpacing.space24,
        AppSpacing.space20,
        AppSpacing.space48 + AppSpacing.space48,
      ),
      children: [
        _AssetsHeader(hideBalances: hideBalances, onToggleHide: onToggleHide),
        const SizedBox(height: AppSpacing.space18),
        _NetAssetCard(
          assetMinor: assetMinor,
          liabilityMinor: liabilityMinor,
          hideBalances: hideBalances,
        ),
        const SizedBox(height: AppSpacing.space24),
        _AccountSection(
          title: '资产账户',
          totalLabel: '总资产',
          total: Money(minorUnits: assetMinor),
          totalSemantic: MoneySemantic.asset,
          accounts: assets,
          hideBalances: hideBalances,
        ),
        const SizedBox(height: AppSpacing.space24),
        _AccountSection(
          title: '负债账户',
          totalLabel: '总负债',
          total: Money(minorUnits: liabilityMinor),
          totalSemantic: MoneySemantic.liability,
          accounts: liabilities,
          hideBalances: hideBalances,
        ),
        const SizedBox(height: AppSpacing.space24),
        _TrendSection(
          netAsset: Money(minorUnits: assetMinor - liabilityMinor),
          hideBalances: hideBalances,
        ),
      ],
    );
  }
}

class _AssetsHeader extends StatelessWidget {
  const _AssetsHeader({required this.hideBalances, required this.onToggleHide});

  final bool hideBalances;
  final VoidCallback onToggleHide;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          '资产',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => context.push('/accounts/new'),
          icon: Icon(RemixIcons.add_line, color: colors.onSurface),
          tooltip: '新建账户',
        ),
        IconButton(
          onPressed: onToggleHide,
          icon: Icon(
            hideBalances ? RemixIcons.eye_off_line : RemixIcons.eye_line,
            color: colors.onSurfaceVariant,
          ),
          tooltip: hideBalances ? '显示余额' : '隐藏余额',
        ),
      ],
    );
  }
}

class _NetAssetCard extends StatelessWidget {
  const _NetAssetCard({
    required this.assetMinor,
    required this.liabilityMinor,
    required this.hideBalances,
  });

  final int assetMinor;
  final int liabilityMinor;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final netMinor = assetMinor - liabilityMinor;
    final totalForRatio = (assetMinor.abs() + liabilityMinor.abs()).clamp(
      1,
      1 << 62,
    );
    final assetRatio = assetMinor.abs() / totalForRatio;
    final liabilityRatio = liabilityMinor.abs() / totalForRatio;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.radiusXl),
        gradient: LinearGradient(
          colors: [colors.primary.withValues(alpha: 0.92), colors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Row(
          children: [
            Expanded(
              child: DefaultTextStyle(
                style: TextStyle(color: colors.onPrimary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '净资产（元）',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onPrimary),
                        ),
                        const SizedBox(width: AppSpacing.space6),
                        Icon(
                          RemixIcons.eye_line,
                          size: 16,
                          color: colors.onPrimary.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space14),
                    Text(
                      hideBalances ? '¥ **,***.**' : _formatMoney(netMinor),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    Text(
                      hideBalances ? '较上月 ****' : '较上月 +1,250.60 (+5.32%)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.86),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 142,
              child: Column(
                children: [
                  SizedBox(
                    width: 78,
                    height: 78,
                    child: CustomPaint(
                      painter: _AssetDonutPainter(
                        assetRatio: assetRatio,
                        liabilityRatio: liabilityRatio,
                        baseColor: colors.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space10),
                  _LegendRow(
                    label: '资产占比',
                    value: '${(assetRatio * 100).round()}%',
                    color: colors.onPrimary.withValues(alpha: 0.72),
                  ),
                  const SizedBox(height: AppSpacing.space6),
                  _LegendRow(
                    label: '负债占比',
                    value: '${(liabilityRatio * 100).round()}%',
                    color: colors.onPrimary.withValues(alpha: 0.42),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetDonutPainter extends CustomPainter {
  const _AssetDonutPainter({
    required this.assetRatio,
    required this.liabilityRatio,
    required this.baseColor,
  });

  final double assetRatio;
  final double liabilityRatio;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeWidth = size.width * 0.22;
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt;
    paint.color = baseColor.withValues(alpha: 0.22);
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, 6.283, false, paint);
    paint.color = baseColor.withValues(alpha: 0.72);
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -1.57,
      6.283 * assetRatio,
      false,
      paint,
    );
    paint.color = baseColor.withValues(alpha: 0.42);
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -1.57 + 6.283 * assetRatio,
      6.283 * liabilityRatio,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AssetDonutPainter oldDelegate) {
    return oldDelegate.assetRatio != assetRatio ||
        oldDelegate.liabilityRatio != liabilityRatio ||
        oldDelegate.baseColor != baseColor;
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.space6),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: onPrimary.withValues(alpha: 0.84),
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.title,
    required this.totalLabel,
    required this.total,
    required this.totalSemantic,
    required this.accounts,
    required this.hideBalances,
  });

  final String title;
  final String totalLabel;
  final Money total;
  final MoneySemantic totalSemantic;
  final List<Account> accounts;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              totalLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.space6),
            hideBalances
                ? const _HiddenMoneyText()
                : MoneyText(
                  money: total,
                  semantic: totalSemantic,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        AppSurface(
          child:
              accounts.isEmpty
                  ? const _EmptyAccountSection()
                  : Column(
                    children: [
                      for (var i = 0; i < accounts.length; i++) ...[
                        _AccountRow(
                          account: accounts[i],
                          hideBalance: hideBalances,
                        ),
                        if (i < accounts.length - 1)
                          const Padding(
                            padding: EdgeInsets.only(
                              left: AppSpacing.space48 + AppSpacing.space24,
                              right: AppSpacing.space16,
                            ),
                            child: Divider(height: 1),
                          ),
                      ],
                    ],
                  ),
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.account, required this.hideBalance});

  final Account account;
  final bool hideBalance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantic =
        account.type == AccountType.asset
            ? MoneySemantic.asset
            : MoneySemantic.liability;

    return InkWell(
      onTap: () => context.push('/accounts/${account.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        child: Row(
          children: [
            BusinessIconBubble(
              size: AppSpacing.space32,
              child: BusinessIcon(
                iconKey: account.iconKey,
                size: AppSpacing.space28,
              ),
            ),
            const SizedBox(width: AppSpacing.space14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: AppTypography.fontSizeMd,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    account.subtype == null
                        ? accountTypeLabel(account.type)
                        : accountSubtypeLabel(account.subtype!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                hideBalance
                    ? const _HiddenMoneyText()
                    : MoneyText(
                      money: account.balance,
                      semantic: semantic,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                if (account.type == AccountType.liability &&
                    (account.billingDay != null ||
                        account.repaymentDay != null)) ...[
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    _liabilityDateText(account),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: AppTypography.fontSizeXs,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendSection extends StatelessWidget {
  const _TrendSection({required this.netAsset, required this.hideBalances});

  final Money netAsset;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Text(
              '资产趋势',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '本月',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            Icon(RemixIcons.arrow_down_s_line, color: colors.onSurfaceVariant),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        AppSurface(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '净资产变化',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space14),
                      Text(
                        hideBalances ? '+¥*,***.**' : '+¥1,250.60',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 190,
                  height: 86,
                  child: CustomPaint(
                    painter: _TrendPainter(color: colors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint =
        Paint()
          ..color = color.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height * 0.82),
      Offset(size.width, size.height * 0.82),
      gridPaint,
    );

    final points = [
      Offset(0, size.height * 0.70),
      Offset(size.width * 0.18, size.height * 0.48),
      Offset(size.width * 0.34, size.height * 0.62),
      Offset(size.width * 0.50, size.height * 0.38),
      Offset(size.width * 0.66, size.height * 0.30),
      Offset(size.width * 0.82, size.height * 0.44),
      Offset(size.width, size.height * 0.20),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    final fillPath =
        Path.from(path)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              color.withValues(alpha: 0.18),
              color.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Offset.zero & size);
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _HiddenMoneyText extends StatelessWidget {
  const _HiddenMoneyText();

  @override
  Widget build(BuildContext context) {
    return Text(
      '¥ ****',
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _EmptyAccountSection extends StatelessWidget {
  const _EmptyAccountSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space20),
      child: Row(
        children: [
          Icon(
            RemixIcons.wallet_3_line,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.space10),
          const Expanded(child: Text('还没有账户')),
        ],
      ),
    );
  }
}

class _AccountsErrorView extends StatelessWidget {
  const _AccountsErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Text('账户加载失败：$error'),
      ),
    );
  }
}

String _formatMoney(int minor) {
  final money = Money(minorUnits: minor);
  return money.format();
}

String _liabilityDateText(Account account) {
  final parts = <String>[];
  if (account.billingDay != null) {
    parts.add('出账日 ${account.billingDay}');
  }
  if (account.repaymentDay != null) {
    parts.add('还款日 ${account.repaymentDay}');
  }
  return parts.join('   ');
}
