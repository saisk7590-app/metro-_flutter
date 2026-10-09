import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
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
      outlineVariant: LightColors.outlineVariant,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: LightColors.card,
      foregroundColor: LightColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: LightColors.textPrimary),
      titleTextStyle: TextStyle(
        color: LightColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: LightColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: LightColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: LightColors.background,
      surfaceTintColor: Colors.transparent,
    ),

    dividerTheme: const DividerThemeData(
      color: LightColors.border,
      thickness: 1,
      space: 1,
    ),

    cardTheme: CardThemeData(
      color: LightColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: LightColors.border, width: 0.8),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LightColors.inputBg,
      hintStyle: const TextStyle(color: LightColors.placeholder, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: LightColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: LightColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: LightColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: LightColors.textPrimary, fontSize: 15),
      bodyMedium: TextStyle(color: LightColors.textPrimary, fontSize: 14),
      bodySmall: TextStyle(color: LightColors.textSecondary, fontSize: 12),
      titleLarge: TextStyle(color: LightColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: LightColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: LightColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
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
      outlineVariant: DarkColors.outlineVariant,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: DarkColors.card,
      foregroundColor: DarkColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: DarkColors.textPrimary),
      titleTextStyle: TextStyle(
        color: DarkColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: DarkColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DarkColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: DarkColors.background,
      surfaceTintColor: Colors.transparent,
    ),

    dividerTheme: const DividerThemeData(
      color: DarkColors.border,
      thickness: 1,
      space: 1,
    ),

    cardTheme: CardThemeData(
      color: DarkColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: DarkColors.border, width: 0.8),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkColors.inputBg,
      hintStyle: const TextStyle(color: DarkColors.placeholder, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: DarkColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: DarkColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: DarkColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: DarkColors.textPrimary, fontSize: 15),
      bodyMedium: TextStyle(color: DarkColors.textPrimary, fontSize: 14),
      bodySmall: TextStyle(color: DarkColors.textSecondary, fontSize: 12),
      titleLarge: TextStyle(color: DarkColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: DarkColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: DarkColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );
}
