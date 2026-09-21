import 'package:flutter/material.dart';

/// Shared palette. Migrate hard-coded `Color(0xFF...)` values here
/// instead of duplicating them in every page.
class AppColors {
  // Page chrome.
  static const Color background = Color(0xFF121316);
  static const Color surface = Color(0xFF212121);
  static const Color card = Color(0xFF232531);

  // Brand accent.
  static const Color accent = Color(0xFFD5E7B5);

  // Inputs.
  static const Color inputFill = Color(0xFF24272B);

  // Chart helpers (moved from `lib/pages/app_colors.dart`).
  static const Color mainGridLineColor = Color(0xff37434d);
  static const Color contentColorCyan = Colors.cyan;
  static const Color contentColorBlue = Colors.blue;
}
