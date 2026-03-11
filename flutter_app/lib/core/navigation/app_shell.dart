import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../constants/app_routes.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (path: AppRoutes.dashboard, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    (path: AppRoutes.transactions, icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Loans'),
    (path: AppRoutes.profile, icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.transactions)) return 1;
    if (location.startsWith(AppRoutes.profile)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final selected = currentIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () => context.go(tab.path),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              selected ? tab.activeIcon : tab.icon,
                              key: ValueKey(selected),
                              color: selected ? AppColors.primary : AppColors.neutralMid,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tab.label,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: selected ? AppColors.primary : AppColors.neutralMid,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
