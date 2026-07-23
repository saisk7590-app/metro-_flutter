import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: LightColors.primary,
    scaffoldBackgroundColor: LightColors.background,
    cardColor: LightColors.card,

    colorScheme: const ColorScheme.light().copyWith(
      primary: LightColors.primary,
      secondary: LightColors.textSecondary,
      surface: LightColors.card,
      surfaceContainerHighest: LightColors.headerBackground,
      outline: LightColors.border,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: LightColors.card,
      foregroundColor: LightColors.textPrimary,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: LightColors.textPrimary, fontSize: 14),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: DarkColors.primary,
    scaffoldBackgroundColor: DarkColors.background,
    cardColor: DarkColors.card,

    colorScheme: const ColorScheme.dark().copyWith(
      primary: DarkColors.primary,
      secondary: DarkColors.textSecondary,
      surface: DarkColors.card,
      surfaceContainerHighest: DarkColors.headerBackground,
      outline: DarkColors.border,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: DarkColors.card,
      foregroundColor: DarkColors.textPrimary,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: DarkColors.textPrimary, fontSize: 14),
    ),
  );
}
