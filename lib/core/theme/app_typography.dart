import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gaming typography system
/// Primary: System UI with gaming-appropriate weights
/// Mono: For prices, timers, codes
abstract class AppTypography {
  static const String _fontFamily = 'Segoe UI';
  static const String _monoFamily = 'Consolas';

  // ===== TYPE SCALE (modular 1.25) =====
  static const double sizeXs  = 10.0;
  static const double sizeSm  = 12.0;
  static const double sizeBase = 13.0;
  static const double sizeMd  = 15.0;
  static const double sizeLg  = 17.0;
  static const double sizeXl  = 20.0;
  static const double size2xl = 24.0;
  static const double size3xl = 30.0;
  static const double size4xl = 38.0;

  // ===== TEXT STYLES =====

  // Display — hero text, game titles
  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: size4xl,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.1,
  );

  // Heading H1 — section titles
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: size3xl,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.15,
  );

  // Heading H2 — card titles, panel headers
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: size2xl,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Heading H3 — subsections
  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: sizeXl,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  // Heading H4 — card game name
  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: sizeLg,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Body default — descriptions, content
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: sizeBase,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.55,
  );

  // Body small — secondary info
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: sizeSm,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Label — button text, chip labels
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: sizeSm,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.0,
  );

  // Label small — tiny labels, platform names
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: sizeXs,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.8,
    height: 1.0,
  );

  // Caption — timestamps, helper text
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: sizeXs,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // Timer — countdown, price
  static const TextStyle timer = TextStyle(
    fontFamily: _monoFamily,
    fontSize: sizeMd,
    fontWeight: FontWeight.w700,
    color: AppColors.feedbackExpiring,
    letterSpacing: 0.5,
    height: 1.0,
  );

  // Price — original price (strikethrough), FREE badge
  static const TextStyle price = TextStyle(
    fontFamily: _monoFamily,
    fontSize: sizeLg,
    fontWeight: FontWeight.w800,
    color: AppColors.feedbackFree,
    letterSpacing: 0.3,
    height: 1.0,
  );

  // Badge number — notification count
  static const TextStyle badge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: sizeXs,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.0,
  );

  // TextTheme for MaterialApp
  static TextTheme get textTheme => const TextTheme(
    displayLarge:  display,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge:    h4,
    titleMedium:   TextStyle(
      fontFamily: _fontFamily, fontSize: sizeMd, fontWeight: FontWeight.w500,
      color: AppColors.textPrimary, height: 1.4,
    ),
    bodyLarge:     body,
    bodyMedium:    bodySmall,
    labelLarge:    label,
    labelSmall:    labelSmall,
  );

  AppTypography._();
}
