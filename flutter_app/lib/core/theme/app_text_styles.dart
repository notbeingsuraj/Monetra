import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.inter();

  // Display
  static TextStyle get displayLarge => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.neutralDark,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.neutralDark,
        height: 1.25,
        letterSpacing: -0.3,
      );

  // Headlines
  static TextStyle get headlineLarge => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.neutralDark,
        height: 1.3,
      );

  static TextStyle get headlineMedium => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.neutralDark,
        height: 1.35,
      );

  static TextStyle get headlineSmall => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.neutralDark,
        height: 1.4,
      );

  // Section titles
  static TextStyle get titleLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.neutralDark,
        height: 1.5,
      );

  static TextStyle get titleMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.neutralDark,
        height: 1.5,
      );

  static TextStyle get titleSmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral,
        letterSpacing: 0.5,
        height: 1.5,
      );

  // Body
  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral,
        height: 1.6,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral,
        height: 1.6,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.neutralMid,
        height: 1.5,
      );

  // Labels
  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral,
      );

  static TextStyle get labelMedium => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.neutralMid,
        letterSpacing: 0.3,
      );

  static TextStyle get labelSmall => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.neutralLight,
        letterSpacing: 0.3,
      );

  // Financial / numbers – uses tabular figures for alignment
  static TextStyle get financialLarge => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.neutralDark,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: -0.5,
      );

  static TextStyle get financialMedium => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.neutralDark,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get financialSmall => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
