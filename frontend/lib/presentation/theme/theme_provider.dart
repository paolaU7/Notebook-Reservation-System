// lib/presentation/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme {
  // Colores base (existentes)
  static const Color primaryBlue     = Color(0xFF0F4C81);
  static const Color secondaryBlue   = Color(0xFF1E88E5);
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color cardLight       = Colors.white;
  static const Color textDark        = Color(0xFF2C3E50);

  // Aliases usados en widgets
  static const Color cardColor   = Color(0xFFECF4FF);
  static const Color accentColor = primaryBlue;
  static const Color textColor   = textDark;

  // Colores de estado
  static const Color statusAvailable = Color(0xFF27AE60);
  static const Color statusInUse     = Color(0xFFE67E22);
  static const Color statusMaint     = Color(0xFFE74C3C);
  static const Color statusOff       = Color(0xFF95A5A6);

  // Warning (cuenta en aire)
  static const Color warningColor = Color(0xFFF39C12);

  static ThemeData get deepSeaTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: cardLight,
        onPrimary: Colors.white,
        onSurface: textDark,
      ),
      textTheme: const TextTheme(
        bodyLarge:  TextStyle(color: textDark),
        bodyMedium: TextStyle(color: textDark),
        titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: textDark),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Professional Dark Blue Palette
    const Color darkBg = Color(0xFF0F172A);      // Slate 900
    const Color darkSurface = Color(0xFF1E293B); // Slate 800
    const Color darkPrimary = Color(0xFF3B82F6); // Blue 500
    const Color darkSecondary = Color(0xFF60A5FA); // Blue 400
    const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
    const Color textSecondary = Color(0xFFCBD5E1); // Slate 300

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: const TextTheme(
        bodyLarge:  TextStyle(color: textSecondary),
        bodyMedium: TextStyle(color: textSecondary),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: darkSurface)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF334155))), // Slate 700
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
      ),
    );
  }
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);