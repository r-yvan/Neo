import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Satoshi is bundled with the app (see `pubspec.yaml`). No system-font
/// fallback is permitted: [kFontFamily] is applied through [ThemeData], and
/// every text style in the app derives from this file.
///
/// TEMPORARILY changed to system font until Satoshi font files are added.
const String kFontFamily = 'Roboto';

/// Named weights so call sites read declaratively instead of repeating ints.
abstract final class AppFontWeight {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight black = FontWeight.w900;
}

/// The full type scale. Sizes are in logical pixels at a 1.0 text scale.
@immutable
class AppTypography {
  const AppTypography._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    height: 1.14,
    fontWeight: AppFontWeight.black,
    letterSpacing: -1.0,
    color: AppColors.grey900,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    height: 1.2,
    fontWeight: AppFontWeight.bold,
    letterSpacing: -0.7,
    color: AppColors.grey900,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    height: 1.25,
    fontWeight: AppFontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.grey900,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    height: 1.3,
    fontWeight: AppFontWeight.bold,
    letterSpacing: -0.35,
    color: AppColors.grey900,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    height: 1.35,
    fontWeight: AppFontWeight.semiBold,
    letterSpacing: -0.25,
    color: AppColors.grey900,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    height: 1.4,
    fontWeight: AppFontWeight.semiBold,
    letterSpacing: -0.15,
    color: AppColors.grey900,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: AppFontWeight.semiBold,
    letterSpacing: -0.1,
    color: AppColors.grey800,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: AppFontWeight.regular,
    color: AppColors.grey700,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: AppFontWeight.regular,
    color: AppColors.grey600,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    height: 1.45,
    fontWeight: AppFontWeight.regular,
    color: AppColors.grey500,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    height: 1.2,
    fontWeight: AppFontWeight.semiBold,
    letterSpacing: -0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    height: 1.2,
    fontWeight: AppFontWeight.medium,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: AppFontWeight.semiBold,
    letterSpacing: 0.5,
  );

  /// Tabular figures for prices and counters.
  static const TextStyle numeric = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: AppFontWeight.bold,
    letterSpacing: -0.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static TextTheme textTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    TextStyle c(TextStyle style, Color colour) =>
        style.copyWith(color: colour);

    final Color strong = isDark ? AppColors.grey50 : AppColors.grey900;
    final Color medium = isDark ? AppColors.grey200 : AppColors.grey700;
    final Color muted = isDark ? AppColors.grey400 : AppColors.grey500;

    return TextTheme(
      displayLarge: c(displayLarge, strong),
      displayMedium: c(displayMedium, strong),
      headlineLarge: c(headlineLarge, strong),
      headlineMedium: c(headlineMedium, strong),
      titleLarge: c(titleLarge, strong),
      titleMedium: c(titleMedium, strong),
      titleSmall: c(titleSmall, isDark ? AppColors.grey100 : AppColors.grey800),
      bodyLarge: c(bodyLarge, medium),
      bodyMedium: c(bodyMedium, medium),
      bodySmall: c(bodySmall, muted),
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}