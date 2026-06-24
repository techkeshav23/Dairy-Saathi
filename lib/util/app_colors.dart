import 'package:flutter/material.dart';

/// Central colour tokens for DAIRY DEMO.
///
/// Pixel-matched to the real **Ananda Distributor** app (v1.67): a bold red brand
/// on white cards over a light blue-grey body, white app bars with black titles,
/// red active states, blue links, and green/red debit-credit accents.
class AppColors {
  AppColors._();

  // ---- Brand red ----
  static const Color primary = Color(0xFFE2231A);
  static const Color primaryDark = Color(0xFFC2121C);
  static const Color secondary = Color(0xFFF0455A);
  static const Color primaryLight = Color(0xFFFDEFEF); // blush / strip bg

  static const Color accent = primary;
  static const Color accentLight = primaryLight;

  // ---- Link blue (Ananda inline links) ----
  static const Color link = Color(0xFF1565D8);

  // ---- Semantic ----
  static const Color success = Color(0xFF1FA64F); // credit / available / resale
  static const Color successLight = Color(0xFFE3F6E3); // credit tint band
  static const Color warning = Color(0xFFF5A623); // claimed / invoiced / dots
  static const Color error = Color(0xFFE23B3B); // debit text / declined
  static const Color errorLight = Color(0xFFFBE3E3); // debit tint band
  static const Color ratingAmber = Color(0xFFFFB400);

  // discount / savings badge uses the savings green
  static const Color discount = success;

  // ---- Neutrals ----
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF555555);
  static const Color textLight = Color(0xFF9A9A9A);
  static const Color background = Color(0xFFEFF1F4); // light blue-grey body
  static const Color surface = Color(0xFFF4F5F7);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE6E6E6);
  static const Color divider = Color(0xFFECECEC);
  static const Color searchPillBorder = Color(0xFFE6E6E6);
  static const Color disabledButton = Color(0xFFC9CDD6);
  static const Color disabledText = Color(0xFFD0D2D6);

  // Quick-access pastel tints
  static const Color tintBlue = Color(0xFFE5EEFB);
  static const Color tintGreen = Color(0xFFE4F2E8);
  static const Color tintOrange = Color(0xFFFCEBDD);

  // ---- Dark theme ----
  static const Color darkBackground = Color(0xFF14151C);
  static const Color darkCard = Color(0xFF1E2029);
  static const Color darkBorder = Color(0xFF313440);

  // ---- Gradients ----
  static const List<Color> heroGradient = [Color(0xFFE2231A), Color(0xFFC2121C)];
  static const List<Color> offersGradient = [Color(0xFFF0455A), Color(0xFFE2231A)];
  static const List<Color> primaryGradient = [primary, primaryDark];
}
