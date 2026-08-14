import 'package:flutter/material.dart';

/// Amana Wallet brand palette — see Branding & Design Guidelines.
class AppColors {
  AppColors._();

  // Primary — Charcoal Gray: buttons, nav bar, wallet card, headers, icons
  static const Color primary = Color(0xFF374151);

  // Secondary — Slate Gray: secondary buttons, labels, supporting text
  static const Color secondary = Color(0xFF6B7280);

  // Background — Light Gray: main app background, forms, empty spaces
  static const Color background = Color(0xFFF9FAFB);

  // Surface / Card — cards, dialogs, bottom sheets, wallet details
  static const Color surface = Color(0xFFFFFFFF);

  // Accent — Royal Blue: active nav, links, selected items, CTAs
  static const Color accent = Color(0xFF2563EB);

  // Status colors
  static const Color success = Color(0xFF22C55E); // successful tx, verified
  static const Color warning = Color(0xFFF59E0B); // pending tx, warnings
  static const Color error = Color(0xFFEF4444); // failed tx, validation errors

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  // Borders / dividers
  static const Color border = Color(0xFFE5E7EB);

  // --- Dark theme counterparts ---
  // Kept close to Material dark defaults while preserving brand accent/status
  // colors, since the branding doc doesn't specify separate dark hex values.
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
}
