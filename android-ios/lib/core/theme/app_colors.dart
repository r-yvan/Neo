/// Design tokens for the Neo visual system.
///
/// Rules enforced here:
///  * Exactly one accent colour — [AppColors.accent] (#0A84FF).
///  * Every neutral is a true grey (no colour cast whatsoever).
///  * British spelling for "grey" everywhere.
library;

import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------- accent
  /// The single brand accent. Used for primary actions, active states,
  /// progress indicators, focus rings and links. Nothing else.
  static const Color accent = Color(0xFF0A84FF);

  /// Accent pressed / active state.
  static const Color accentPressed = Color(0xFF0064D2);

  /// Very low-alpha accent wash for selected chips and soft backgrounds.
  static const Color accentSoft = Color(0x140A84FF);
  static const Color accentSofter = Color(0x0A0A84FF);

  // --------------------------------------------------------------- greys
  // Pure neutral ramp, light to dark.
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey150 = Color(0xFFEFEFEF);
  static const Color grey200 = Color(0xFFE5E5E5);
  static const Color grey300 = Color(0xFFD4D4D4);
  static const Color grey400 = Color(0xFFA3A3A3);
  static const Color grey500 = Color(0xFF737373);
  static const Color grey600 = Color(0xFF525252);
  static const Color grey700 = Color(0xFF404040);
  static const Color grey800 = Color(0xFF262626);
  static const Color grey850 = Color(0xFF1F1F1F);
  static const Color grey900 = Color(0xFF171717);
  static const Color grey950 = Color(0xFF0F0F0F);

  // ------------------------------------------------------------ semantics
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0x1A16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0x1AD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0x1ADC2626);
  static const Color star = Color(0xFFF59E0B);

  // --------------------------------------------------------------- dark
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceRaised = Color(0xFF242424);
  static const Color darkBorder = Color(0xFF303030);
}

/// Corner radii. Everything sits in the 12–16px band described by the brand
/// guidelines; pills use [AppRadii.pill].
@immutable
class AppRadii {
  const AppRadii._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 22;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Spacing scale — a 4pt grid.
@immutable
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets card = EdgeInsets.all(16);
}

/// Elevation presets. Very soft, greyscale only — no tinted shadows.
@immutable
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 18,
      offset: Offset(0, 6),
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 28,
      offset: Offset(0, 12),
      spreadRadius: -10,
    ),
  ];

  static const List<BoxShadow> accent = [
    BoxShadow(
      color: Color(0x330A84FF),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: -6,
    ),
  ];
}