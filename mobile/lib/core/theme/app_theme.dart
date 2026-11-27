import 'package:flutter/material.dart';
import 'package:tandem/core/theme/app_colors.dart';
import 'package:tandem/core/theme/app_spacing.dart';
import 'package:tandem/core/theme/app_typography.dart';

/// The Material theme of the app for one language.
ThemeData buildAppTheme(String languageCode) {
  final type = AppTypography.forLanguage(languageCode);
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.accent,
    onPrimary: AppColors.accentInk,
    secondary: AppColors.accentSoft,
    onSecondary: AppColors.accentDeep,
    // Material needs an error colour; Tandem never paints lateness red.
    error: AppColors.lateInk,
    onError: AppColors.paper,
    surface: AppColors.light,
    onSurface: AppColors.ink,
  );
  final outline = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.input),
    borderSide: const BorderSide(color: AppColors.muted),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.paper,
    fontFamily: type.isArabic ? AppFonts.arabic : AppFonts.body,
    textTheme: TextTheme(
      headlineMedium: type.heading(type.xl),
      titleLarge: type.heading(type.lg),
      bodyLarge: type.body(),
      bodyMedium: type.body(),
      bodySmall: type.caption(),
      labelLarge: type.bodyMedium(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.light,
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      border: outline,
      enabledBorder: outline,
      focusedBorder: outline.copyWith(
        borderSide: const BorderSide(color: AppColors.focus, width: 2),
      ),
      errorBorder: outline.copyWith(
        borderSide: const BorderSide(color: AppColors.ink, width: 2),
      ),
      focusedErrorBorder: outline.copyWith(
        borderSide: const BorderSide(color: AppColors.ink, width: 2),
      ),
      labelStyle: type.label(),
      hintStyle: type.caption(),
      errorStyle: type.label(color: AppColors.ink),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll<Color>(AppColors.light),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.paper3,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.muted,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: type.body(color: AppColors.paper),
    ),
    splashFactory: NoSplash.splashFactory,
  );
}
