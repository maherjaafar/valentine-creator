import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF6B81),
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: scheme.copyWith(
        primary: const Color(0xFFB71C4A),
        secondary: const Color(0xFF7C2B5F),
        surface: const Color(0xFFFFF7FB),
        background: const Color(0xFFFFF7FB),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF2B0A1E),
        onBackground: const Color(0xFF2B0A1E),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF7FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFE3EB),
        foregroundColor: Color(0xFF2B0A1E),
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2B0A1E)),
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2B0A1E)),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2B0A1E)),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2B0A1E)),
        bodyLarge: TextStyle(color: Color(0xFF2B0A1E)),
        bodyMedium: TextStyle(color: Color(0xFF2B0A1E)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB71C4A),
          foregroundColor: Colors.white,
          shadowColor: const Color(0xFFB71C4A).withOpacity(0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2B0A1E),
          side: const BorderSide(color: Color(0xFF7C2B5F), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE9B7C8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB71C4A), width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
