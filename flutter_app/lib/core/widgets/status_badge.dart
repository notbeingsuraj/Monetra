import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum StatusType { pending, repaid, overdue, defaulted }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final StatusType status;

  factory StatusBadge.fromString(String status) {
    switch (status.toLowerCase()) {
      case 'repaid':
        return const StatusBadge(status: StatusType.repaid);
      case 'overdue':
        return const StatusBadge(status: StatusType.overdue);
      case 'defaulted':
        return const StatusBadge(status: StatusType.defaulted);
      default:
        return const StatusBadge(status: StatusType.pending);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _config();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color, Color) _config() {
    switch (status) {
      case StatusType.repaid:
        return ('Repaid', AppColors.successSurface, AppColors.success);
      case StatusType.overdue:
        return ('Overdue', AppColors.errorSurface, AppColors.error);
      case StatusType.defaulted:
        return ('Defaulted', AppColors.errorSurface, AppColors.error);
      case StatusType.pending:
        return ('Pending', AppColors.warningSurface, AppColors.warning);
    }
  }
}
