import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/theme.dart';

/// A single shimmering skeleton block.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = AppRadius.lg,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurface : AppColors.surfaceAlt,
      highlightColor: isDark ? AppColors.darkDivider : AppColors.divider,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton loader for a loan / transaction list row.
class LoanCardSkeleton extends StatelessWidget {
  const LoanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const SkeletonBox(height: 40, width: 40, borderRadius: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(height: 14),
                SizedBox(height: AppSpacing.sm),
                SkeletonBox(height: 12, width: 100),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonBox(height: 16, width: 72),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(height: 20, width: 52, borderRadius: AppRadius.full),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the dashboard summary card.
class SummaryCardSkeleton extends StatelessWidget {
  const SummaryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 12, width: 80),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(height: 22, width: 120),
          Spacer(),
          SkeletonBox(height: 10, width: 60),
        ],
      ),
    );
  }
}
