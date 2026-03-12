import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../lending/data/loan_models.dart';

class LoanAgreementCard extends StatelessWidget {
  const LoanAgreementCard({
    super.key,
    required this.loan,
    required this.lenderName,
  });

  final Loan loan;
  final String lenderName;

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFmt = DateFormat('d MMM yyyy');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(50),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text(
            'LOAN AGREEMENT',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lender', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralMid)),
                  Text(lenderName, style: AppTextStyles.titleMedium),
                ],
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.neutralLight),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Borrower', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralMid)),
                  Text(loan.borrowerName, style: AppTextStyles.titleMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSpacing.xl),
          Text('Amount', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralMid)),
          Text(
            currencyFmt.format(loan.amount),
            style: AppTextStyles.financialLarge.copyWith(color: AppColors.neutralDark),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Due: ${dateFmt.format(loan.dueDate)}',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          if (loan.interest != null && loan.interest! > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Interest Rate: ${loan.interest}%',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutralDark),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'Accepted by both parties',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.success),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Monetra', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight)),
        ],
      ),
    );
  }
}
