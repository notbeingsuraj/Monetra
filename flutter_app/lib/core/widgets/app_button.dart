import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum AppButtonVariant { primary, outlined, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bgColor;
    Color fgColor;
    BorderSide? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        border = BorderSide.none;
        break;
      case AppButtonVariant.outlined:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        border = const BorderSide(color: AppColors.primary);
        break;
      case AppButtonVariant.ghost:
        bgColor = AppColors.primarySurface;
        fgColor = AppColors.primary;
        border = BorderSide.none;
        break;
      case AppButtonVariant.danger:
        bgColor = AppColors.error;
        fgColor = Colors.white;
        border = BorderSide.none;
        break;
    }

    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(color: fgColor),
              ),
            ],
          );

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.base),
            side: border ?? BorderSide.none,
          ),
          disabledBackgroundColor: colorScheme.primary.withAlpha(80),
          disabledForegroundColor: Colors.white,
        ),
        child: content,
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
