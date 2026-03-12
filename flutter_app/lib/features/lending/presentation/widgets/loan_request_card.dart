import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/logic/auth_provider.dart';
import '../../lending/data/loan_models.dart';
import '../../lending/logic/loan_providers.dart';
import 'loan_agreement_card.dart';

class LoanRequestCard extends ConsumerWidget {
  const LoanRequestCard({
    super.key,
    required this.loan,
    required this.isIncoming,
  });

  final Loan loan;
  final bool isIncoming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFmt = DateFormat('d MMM yyyy');
    
    final bool isPending = loan.status == LoanStatus.pending;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text(
                      isIncoming ? 'From: ${loan.borrowerName}' : 'To: ${loan.borrowerName}',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Due ${dateFmt.format(loan.dueDate)}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutralMid),
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
                  if (loan.interest != null && loan.interest! > 0)
                    Text(
                      '${loan.interest}% Interest',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
                    )
                  else
                    Text(
                      '0% Interest',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
                    ),
                ],
              ),
            ],
          ),
          
          if (loan.note != null && loan.note!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.format_quote_rounded, size: 16, color: AppColors.neutralMid),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      loan.note!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutralMid, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (isPending) ...[
            const SizedBox(height: AppSpacing.md),
            if (isIncoming)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Reject',
                      variant: AppButtonVariant.ghost,
                      height: 40,
                      onPressed: () => _reject(context, ref),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Accept',
                      height: 40,
                      onPressed: () => _accept(context, ref),
                    ),
                  ),
                ],
              )
            else
              AppButton(
                label: 'Cancel Request',
                variant: AppButtonVariant.ghost,
                height: 40,
                onPressed: () => _cancel(context, ref),
              ),
            
            if (loan.expiresAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  'Expires ${dateFmt.format(loan.expiresAt!)}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: AppSpacing.md),
            // Show status badge
            Align(
              alignment: Alignment.centerRight,
              child: StatusBadge.fromString(loan.status.label),
            ),
          ],
        ],
      ),
    );
  }

  void _accept(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(loanActionProvider.notifier).acceptRequest(loan.id);
    if (success && context.mounted) {
      ref.invalidate(incomingLoanRequestsProvider);
      ref.invalidate(activeLoansProvider);
      ref.invalidate(loanSummaryProvider);
      
      // Show agreement card dialog
      final user = ref.read(authProvider).user;
      final lenderName = user?.name ?? 'Lender'; // Or fetch from the original requester if available
      
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoanAgreementCard(loan: loan, lenderName: loan.borrowerName), // For incoming request, borrower object holds lender's alias or we use current user as borrower. Actually the loan has borrowerName, maybe it is the other party.
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Screenshot to Share',
                icon: Icons.share_rounded,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Use device screenshot to share this agreement via WhatsApp!')),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Close', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _reject(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(loanActionProvider.notifier).rejectRequest(loan.id);
    if (success && context.mounted) {
      ref.invalidate(incomingLoanRequestsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loan request rejected')),
      );
    }
  }

  void _cancel(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(loanActionProvider.notifier).cancelRequest(loan.id);
    if (success && context.mounted) {
      ref.invalidate(outgoingLoanRequestsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loan request cancelled')),
      );
    }
  }
}
