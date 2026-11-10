// Veltro Theme Configuration
// Path: lib/core/theme/veltro_theme.dart

import 'package:flutter/material.dart';

abstract class VeltroTheme {
  // Brand Palette
  static const Color primaryNavy = Color(0xFF0A192F);       // Deep Trust Navy
  static const Color primaryNavyLight = Color(0xFF1E293B);  // Slate Navy for elevated elements
  static const Color accentEmerald = Color(0xFF10B981);     // Emerald Green Accent
  static const Color accentEmeraldLight = Color(0xFFD1FAE5);// Subtle Emerald Tint
  static const Color backgroundLight = Color(0xFFF8FAFC);   // Soft Grey Canvas
  static const Color surfaceWhite = Color(0xFFFFFFFF);      // Clean Card Surface
  static const Color surfaceMuted = Color(0xFFF1F5F9);      // Muted Container

  // Risk Tiers
  static const Color riskLow = Color(0xFF10B981);           // Low Risk / Verified
  static const Color riskLowContainer = Color(0xFFECFDF5);
  static const Color riskMedium = Color(0xFFF59E0B);        // Medium Risk / Caution
  static const Color riskMediumContainer = Color(0xFFFFFBEB);
  static const Color riskHigh = Color(0xFFF97316);          // High Risk / Threat
  static const Color riskHighContainer = Color(0xFFFFF7ED);
  static const Color riskCritical = Color(0xFFEF4444);      // Critical / Scam
  static const Color riskCriticalContainer = Color(0xFFFEF2F2);

  // Neutral Typography & Borders
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderFocus = Color(0xFF0A192F);

  // Subtle Elevation Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.04),
      blurRadius: 12.0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get activeCardShadow => [
    BoxShadow(
      color: const Color(0xFF0A192F).withOpacity(0.08),
      blurRadius: 18.0,
      offset: const Offset(0, 6),
    ),
  ];

  // Theme Data Construction
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryNavy,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        onPrimary: surfaceWhite,
        secondary: accentEmerald,
        onSecondary: surfaceWhite,
        surface: surfaceWhite,
        onSurface: textPrimary,
        error: riskCritical,
        onError: surfaceWhite,
        outline: borderSubtle,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: const BorderSide(color: borderSubtle, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primaryNavy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: riskCritical),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: surfaceWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          textStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          side: const BorderSide(color: borderSubtle),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          textStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1.0,
        space: 24.0,
      ),
    );
  }
}
