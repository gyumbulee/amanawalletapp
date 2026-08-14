import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Poppins-based text theme, per branding guidelines (Inter/Roboto fallback
/// handled automatically by google_fonts if Poppins fails to load).
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color primaryText, Color secondaryText) {
    final base = GoogleFonts.poppinsTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      displayMedium: base.displayMedium?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      headlineLarge: base.headlineLarge?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      headlineMedium: base.headlineMedium?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      headlineSmall: base.headlineSmall?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(color: primaryText, fontWeight: FontWeight.w500),
      titleSmall: base.titleSmall?.copyWith(color: primaryText, fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(color: primaryText),
      bodyMedium: base.bodyMedium?.copyWith(color: primaryText),
      bodySmall: base.bodySmall?.copyWith(color: secondaryText),
      labelLarge: base.labelLarge?.copyWith(color: primaryText, fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(color: secondaryText),
      labelSmall: base.labelSmall?.copyWith(color: secondaryText),
    );
  }

  static TextTheme get light => textTheme(AppColors.textPrimary, AppColors.textSecondary);
  static TextTheme get dark => textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary);
}
