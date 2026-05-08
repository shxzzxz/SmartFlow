import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design_system/tokens/spacing.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
          child: Row(
            children: [
              _BottomNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                selected: selectedIndex == 0,
                onTap: () => context.go('/'),
              ),
              _BottomNavItem(
                icon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month_rounded,
                selected: selectedIndex == 1,
                onTap: () => context.go('/calendar'),
              ),
              _BottomNavItem(
                icon: Icons.account_balance_wallet_outlined,
                selectedIcon: Icons.account_balance_wallet_rounded,
                selected: selectedIndex == 2,
                onTap: () => context.go('/accounts'),
              ),
              _BottomNavItem(
                icon: Icons.pie_chart_outline_rounded,
                selectedIcon: Icons.pie_chart_rounded,
                selected: selectedIndex == 3,
                onTap: () => context.go('/statistics'),
              ),
              _BottomNavItem(
                icon: Icons.category_outlined,
                selectedIcon: Icons.category_rounded,
                selected: selectedIndex == 4,
                onTap: () => context.go('/categories'),
              ),
              _BottomNavItem(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                selected: selectedIndex == 5,
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/calendar')) {
      return 1;
    }
    if (path.startsWith('/accounts')) {
      return 2;
    }
    if (path.startsWith('/statistics')) {
      return 3;
    }
    if (path.startsWith('/categories')) {
      return 4;
    }
    if (path.startsWith('/profile')) {
      return 5;
    }
    return 0;
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = selected ? colors.primary : colors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.space16),
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.space8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
