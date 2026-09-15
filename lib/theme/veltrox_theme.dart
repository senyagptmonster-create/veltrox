import 'package:flutter/material.dart';

class VeltroxTheme {
  static const background = Color(0xFF0A0E17);
  static const surface = Color(0xFF141B2B);
  static const card = Color(0xFF1E283E);
  static const cyan = Color(0xFF38BDF8);
  static const crimson = Color(0xFFEF4444);
  static const amber = Color(0xFFF59E0B);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: cyan,
      cardColor: card,
      fontFamily: 'AppFont',
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: crimson,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
