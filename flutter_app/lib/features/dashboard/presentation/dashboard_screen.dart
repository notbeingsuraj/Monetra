import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/logic/auth_provider.dart';
import '../../lending/data/loan_models.dart';
import '../../lending/logic/loan_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedTab = 0; // 0 for Active Loans, 1 for Requests

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final summaryAsync = ref.watch(loanSummaryProvider);
    final activeLoansAsync = ref.watch(activeLoansProvider);
    final trustAsync = ref.watch(trustScoreProvider);

    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(loanSummaryProvider);
            ref.invalidate(activeLoansProvider);
            ref.invalidate(trustScoreProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning,',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralMid),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.name.split(' ').first ?? 'there',
                            style: AppTextStyles.headlineMedium,
                          ),
                        ],
                      ),
                      // Trust score ring
                      trustAsync.when(
                        data: (trust) => _TrustScoreRing(score: trust.finalScore.toInt()),
                        loading: () => const SkeletonBox(height: 48, width: 48, borderRadius: 24),
                        error: (_, __) => const SizedBox(height: 48, width: 48),
                      ),
                    ],
                  ),
                ),
              ),

              // Summary cards
              SliverToBoxAdapter(
                child: summaryAsync.when(
                  data: (summary) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      children: [
                        // Total balance card
                        AppCard(
                          backgroundColor: AppColors.primary,
                          borderColor: AppColors.primary,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Lent',
                                style: AppTextStyles.labelMedium.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                currencyFmt.format(summary.totalLent),
                                style: AppTextStyles.financialLarge.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: AppSpacing.base),
                              Divider(color: Colors.white.withAlpha(40), thickness: 1),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  _SummaryChip(
                                    label: 'Pending',
                                    value: '${summary.pending}',
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: AppSpacing.xl),
                                  _SummaryChip(
                                    label: 'Repaid',
                                    value: '${summary.repaid}',
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: AppSpacing.xl),
                                  _SummaryChip(
                                    label: 'Overdue',
                                    value: '${summary.overdue}',
                                    color: summary.overdue > 0
                                        ? const Color(0xFFFFB3B3)
                                        : Colors.white70,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Quick actions
                        Row(
                          children: [
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.add_rounded,
                                label: 'New Loan',
                                onTap: () => context.push(AppRoutes.lend),
                              ),
                            ),
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.send_rounded,
                                label: 'Request',
                                onTap: () => context.push(AppRoutes.lendRequest),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.receipt_long_outlined,
                                label: 'All Loans',
                                onTap: () => context.go(AppRoutes.transactions),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      children: [
                        const SummaryCardSkeleton(),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: const [
                            Expanded(child: SummaryCardSkeleton()),
                            SizedBox(width: AppSpacing.md),
                            Expanded(child: SummaryCardSkeleton()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: ErrorState(
                      message: 'Could not load summary.',
                      onRetry: () => ref.invalidate(loanSummaryProvider),
                    ),
                  ),
                ),
              ),

              // Section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Text(
                          'Active Loans',
                          style: _selectedTab == 0
                              ? AppTextStyles.headlineSmall
                              : AppTextStyles.headlineSmall.copyWith(color: AppColors.neutralMid),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Text(
                          'Requests',
                          style: _selectedTab == 1
                              ? AppTextStyles.headlineSmall
                              : AppTextStyles.headlineSmall.copyWith(color: AppColors.neutralMid),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content based on tab
              if (_selectedTab == 0)
                activeLoansAsync.when(
                  data: (loans) => loans.isEmpty
                      ? SliverToBoxAdapter(
                          child: EmptyState(
                            icon: Icons.handshake_outlined,
                            title: 'No active loans',
                            subtitle: 'Loans you create will appear here.',
                            actionLabel: 'Record a Loan',
                            onAction: () => context.push(AppRoutes.lend),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: _LoanRow(loan: loans[i]),
                              ),
                              childCount: loans.length,
                            ),
                          ),
                        ),
                  loading: () => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => const Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: LoanCardSkeleton(),
                        ),
                        childCount: 3,
                      ),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: ErrorState(
                      message: 'Could not load loans.',
                      onRetry: () => ref.invalidate(activeLoansProvider),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manage requests to and from you.',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralMid)),
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          label: 'View All Requests',
                          onPressed: () => context.push(AppRoutes.requests),
                          variant: AppButtonVariant.primary,
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.huge)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustScoreRing extends StatelessWidget {
  const _TrustScoreRing({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? AppColors.success
        : score >= 60
            ? AppColors.warning
            : AppColors.error;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 3,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Text(
          '$score',
          style: AppTextStyles.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.financialMedium.copyWith(color: color)),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: color.withAlpha(180))),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headlineSmall),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
          ),
      ],
    );
  }
}

class _LoanRow extends StatelessWidget {
  const _LoanRow({required this.loan});
  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFmt = DateFormat('d MMM yyyy');
    final isOverdue = loan.status == LoanStatus.overdue;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Center(
              child: Text(
                loan.borrowerName.isNotEmpty ? loan.borrowerName[0].toUpperCase() : '?',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loan.borrowerName, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Due ${dateFmt.format(loan.dueDate)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isOverdue ? AppColors.error : AppColors.neutralMid,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFmt.format(loan.amount),
                style: AppTextStyles.financialSmall.copyWith(color: AppColors.neutralDark),
              ),
              const SizedBox(height: 4),
              StatusBadge.fromString(loan.status.name),
            ],
          ),
        ],
      ),
    );
  }
}
