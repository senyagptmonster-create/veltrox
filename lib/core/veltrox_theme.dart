import 'package:flutter/material.dart';

class VeltroxColors {
  static const Color neonRed = Color(0xFFFF2A54);
  static const Color electricCyan = Color(0xFF00E5FF);
  static const Color darkCanvas = Color(0xFF0A0D14);
  static const Color cardSurface = Color(0xFF131824);
  static const Color surfaceElevated = Color(0xFF1B2232);
  static const Color borderSubtle = Color(0xFF263044);
  static const Color amberWarning = Color(0xFFFFB020);
  static const Color emeraldSuccess = Color(0xFF00E676);

  static const Color textBright = Color(0xFFF3F6FC);
  static const Color textMuted = Color(0xFF8C9BAE);
  static const Color textDim = Color(0xFF5A6678);
}

class VeltroxTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: VeltroxColors.darkCanvas,
      primaryColor: VeltroxColors.neonRed,
      colorScheme: const ColorScheme.dark(
        primary: VeltroxColors.neonRed,
        secondary: VeltroxColors.electricCyan,
        surface: VeltroxColors.cardSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: VeltroxColors.textBright,
      ),
      fontFamily: 'AppFont',
      cardTheme: CardThemeData(
        color: VeltroxColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: VeltroxColors.borderSubtle),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: VeltroxColors.darkCanvas,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: VeltroxColors.textBright,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: VeltroxColors.cardSurface,
        indicatorColor: VeltroxColors.neonRed.withAlpha(50),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: VeltroxColors.neonRed,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: VeltroxColors.textMuted,
          );
        }),
      ),
    );
  }
}
