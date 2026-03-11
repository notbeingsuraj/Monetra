import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../services/api/api_client.dart';
import '../../lending/data/loan_models.dart';
import '../../lending/logic/loan_providers.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String? _selectedStatus;

  static const _tabs = [
    (label: 'All', status: null),
    (label: 'Pending', status: 'pending'),
    (label: 'Repaid', status: 'repaid'),
    (label: 'Overdue', status: 'overdue'),
  ];

  @override
  Widget build(BuildContext context) {
    final loansAsync = ref.watch(loansProvider(_selectedStatus));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.lend),
            tooltip: 'Record Loan',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 6),
              children: _tabs.map((tab) {
                final selected = _selectedStatus == tab.status;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: FilterChip(
                      label: Text(tab.label),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedStatus = tab.status),
                      backgroundColor: AppColors.surfaceAlt,
                      selectedColor: AppColors.primarySurface,
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: selected ? AppColors.primary : AppColors.neutralMid,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.divider,
                      ),
                      visualDensity: VisualDensity.compact,
                      showCheckmark: false,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: loansAsync.when(
        data: (loans) => loans.isEmpty
            ? EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No loans found',
                subtitle: 'Record a new loan to see it here.',
                actionLabel: 'Record Loan',
                onAction: () => context.push(AppRoutes.lend),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => ref.invalidate(loansProvider(_selectedStatus)),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  itemCount: loans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => _LoanListItem(loan: loans[index]),
                ),
              ),
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.xl),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, __) => const LoanCardSkeleton(),
        ),
        error: (e, _) => ErrorState(
          message: ApiClient.parseError(e),
          onRetry: () => ref.invalidate(loansProvider(_selectedStatus)),
        ),
      ),
    );
  }
}

class _LoanListItem extends StatelessWidget {
  const _LoanListItem({required this.loan});
  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFmt = DateFormat('d MMM ''yy');
    final isOverdue = loan.status == LoanStatus.overdue;

    return AppCard(
      onTap: () {}, // Navigate to detail
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Center(
              child: Text(
                loan.borrowerName.isNotEmpty ? loan.borrowerName[0].toUpperCase() : '?',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loan.borrowerName, style: AppTextStyles.titleMedium),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_outlined,
                      size: 12,
                      color: isOverdue ? AppColors.error : AppColors.neutralMid,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due ${dateFmt.format(loan.dueDate)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isOverdue ? AppColors.error : AppColors.neutralMid,
                      ),
                    ),
                    if (loan.note != null && loan.note!.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '· ${loan.note}',
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFmt.format(loan.amount),
                style: AppTextStyles.financialSmall.copyWith(
                  color: AppColors.neutralDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              StatusBadge.fromString(loan.status.name),
            ],
          ),
        ],
      ),
    );
  }
}
