import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/logic/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                        style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(user?.name ?? '—', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user?.email ?? user?.phone ?? '—',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralMid),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Trust score card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Icon(Icons.verified_outlined, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trust Score', style: AppTextStyles.titleMedium),
                        Text(
                          'Based on your repayment history',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${user?.trustScore.toInt() ?? 0}',
                    style: AppTextStyles.financialMedium.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Settings list
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsRow(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsRow(
                    icon: Icons.security_outlined,
                    label: 'Security',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsRow(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),

            // Logout
            AppCard(
              padding: EdgeInsets.zero,
              child: _SettingsRow(
                icon: Icons.logout,
                label: 'Sign Out',
                labelColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () => _confirmLogout(context, ref),
              ),
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Out', style: AppTextStyles.headlineSmall),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.neutral, size: 22),
      title: Text(
        label,
        style: AppTextStyles.titleMedium.copyWith(color: labelColor ?? AppColors.neutralDark),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.neutralLight, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
    );
  }
}
