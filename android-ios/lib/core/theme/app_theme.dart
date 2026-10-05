import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] from the design tokens.
///
/// Only [AppColors.accent] introduces colour into the UI. Everything else is
/// drawn from the greyscale ramp, which is what keeps the marketplace calm and
/// lets listings and photography carry the visual weight.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final Color background =
        isDark ? AppColors.darkBackground : AppColors.grey100;
    final Color surface = isDark ? AppColors.darkSurface : Colors.white;
    final Color raised =
        isDark ? AppColors.darkSurfaceRaised : AppColors.grey50;
    final Color border = isDark ? AppColors.darkBorder : AppColors.grey200;
    final Color strong = isDark ? AppColors.grey50 : AppColors.grey900;
    final Color body = isDark ? AppColors.grey200 : AppColors.grey700;
    final Color muted = isDark ? AppColors.grey400 : AppColors.grey500;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      primaryContainer: isDark
          ? const Color(0xFF10243A)
          : AppColors.accentSoft,
      onPrimaryContainer: isDark ? AppColors.grey100 : AppColors.grey900,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.accentSoft,
      onSecondaryContainer: AppColors.grey900,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: AppColors.dangerSoft,
      onErrorContainer: AppColors.danger,
      surface: surface,
      onSurface: strong,
      surfaceContainerLowest: surface,
      surfaceContainerLow: raised,
      surfaceContainer: raised,
      surfaceContainerHigh: isDark
          ? const Color(0xFF2A2A2A)
          : AppColors.grey150,
      surfaceContainerHighest: isDark
          ? const Color(0xFF303030)
          : AppColors.grey200,
      onSurfaceVariant: body,
      outline: border,
      outlineVariant: border,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: isDark ? AppColors.grey50 : AppColors.grey900,
      onInverseSurface: isDark ? AppColors.grey900 : AppColors.grey50,
      inversePrimary: AppColors.accentPressed,
    );

    final TextTheme text = AppTypography.textTheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: kFontFamily,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: strong,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgAll,
          side: BorderSide(color: border),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(color: body, size: 22),

      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: AppColors.accentSoft,
        side: BorderSide(color: border),
        labelStyle: text.labelMedium!.copyWith(color: strong),
        secondaryLabelStyle:
            text.labelMedium!.copyWith(color: AppColors.accent),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.pillAll),
        showCheckmark: false,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              isDark ? AppColors.grey800 : AppColors.grey200,
          disabledForegroundColor: muted,
          minimumSize: const Size.fromHeight(54),
          textStyle: text.labelLarge,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.mdAll,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: strong,
          minimumSize: const Size.fromHeight(52),
          textStyle: text.labelLarge,
          side: BorderSide(color: border, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.mdAll,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: text.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.smAll,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: text.bodyMedium!.copyWith(color: muted),
        labelStyle: text.bodyMedium!.copyWith(color: muted),
        floatingLabelStyle: text.labelMedium!.copyWith(
          color: AppColors.accent,
        ),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall!.copyWith(color: AppColors.danger),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
        showDragHandle: true,
        dragHandleColor: border,
        dragHandleSize: const Size(40, 4),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: text.headlineMedium,
        contentTextStyle: text.bodyMedium,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.xlAll,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.accentSoft,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return text.labelSmall!.copyWith(
            color: selected ? AppColors.accent : muted,
            letterSpacing: 0,
            fontWeight:
                selected ? AppFontWeight.semiBold : AppFontWeight.medium,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.accent : muted,
          );
        }),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.accent,
        unselectedLabelColor: muted,
        indicatorColor: AppColors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: text.titleSmall!.copyWith(
          color: AppColors.accent,
          fontWeight: AppFontWeight.semiBold,
        ),
        unselectedLabelStyle: text.titleSmall!.copyWith(
          color: muted,
          fontWeight: AppFontWeight.medium,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.grey200 : AppColors.grey900,
        contentTextStyle: text.bodyMedium!.copyWith(
          color: isDark ? AppColors.grey900 : AppColors.grey50,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.mdAll,
        ),
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        elevation: 6,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.grey200,
        circularTrackColor: AppColors.grey200,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: isDark ? AppColors.grey700 : AppColors.grey200,
        thumbColor: Colors.white,
        overlayColor: AppColors.accentSoft,
        trackHeight: 4,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : (isDark ? AppColors.grey400 : Colors.white);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accent
              : (isDark ? AppColors.grey700 : AppColors.grey300);
        }),
        trackOutlineColor: WidgetStateProperty.all(
          isDark ? AppColors.grey700 : AppColors.grey300,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accent
              : Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: BorderSide(color: isDark ? AppColors.grey600 : AppColors.grey300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodySmall,
        iconColor: muted,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionColor: AppColors.accentSoft,
        selectionHandleColor: AppColors.accent,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey700 : AppColors.grey900,
          borderRadius: AppRadii.smAll,
        ),
        textStyle: text.bodySmall!.copyWith(color: Colors.white),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}