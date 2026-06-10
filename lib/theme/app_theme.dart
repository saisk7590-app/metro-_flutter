import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    primaryColor: const Color(0xFF007BFF),

    scaffoldBackgroundColor: const Color(0xFFF5F7FA),

    cardColor: Colors.white,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF007BFF),
      secondary: Color(0xFF6B7280),

      surface: Colors.white,

      outline: Color(0xFFD1D5DB),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF111827),
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF111827), fontSize: 14),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    primaryColor: const Color(0xFF00AEEF),

    scaffoldBackgroundColor: const Color(0xFF0B0F1A),

    cardColor: const Color(0xFF121826),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00AEEF),
      secondary: Color(0xFF9CA3AF),

      surface: Color(0xFF121826),

      outline: Color(0xFF1F2937),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121826),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
    ),
  );
}
