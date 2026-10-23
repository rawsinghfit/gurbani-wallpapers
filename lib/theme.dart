import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colours inspired by Sri Darbar Sahib at amrit vela.
class AppColors {
  static const night = Color(0xFF0E1B2C);
  static const panel = Color(0xFF16263A);
  static const gold = Color(0xFFC9A24A);
  static const marble = Color(0xFFEEF0F2);
  static const muted = Color(0xFF9FB0C2);
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    primary: AppColors.gold,
    onPrimary: AppColors.night,
    secondary: AppColors.gold,
    onSecondary: AppColors.night,
    surface: AppColors.night,
    onSurface: AppColors.marble,
    onSurfaceVariant: AppColors.muted,
    surfaceContainerLowest: AppColors.night,
    surfaceContainerLow: AppColors.panel,
    surfaceContainer: AppColors.panel,
    surfaceContainerHigh: AppColors.panel,
    surfaceContainerHighest: AppColors.panel,
    outline: Color(0xFF2E425A),
    outlineVariant: Color(0xFF233448),
    error: Color(0xFFF2B8B5),
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final textTheme = GoogleFonts.figtreeTextTheme(base.textTheme).apply(
    bodyColor: AppColors.marble,
    displayColor: AppColors.marble,
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.night,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.night,
      foregroundColor: AppColors.marble,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: AppColors.marble,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.panel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.panel,
      helperStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF233448)),
  );
}
