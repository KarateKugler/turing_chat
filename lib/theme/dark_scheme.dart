import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const darkColorScheme = ColorScheme.dark(
  primary: Color(0xFF6E4FFF),        // Very dark purple
  onPrimary: Colors.white,
  primaryContainer: Color(0xFF2C2C2C), // Dark charcoal
  onPrimaryContainer: Colors.white70,

  secondary: Color(0xFF3E4756),       // Dark blueish grey
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFF2A3140),
  onSecondaryContainer: Colors.white70,

  tertiary: Color(0xFF4A4A4A),        // Deep grey
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFF353535),
  onTertiaryContainer: Colors.white70,

  error: Color(0xFFCF6679),
  onError: Colors.black,

  background: Color(0xFF121212),      // Almost black background
  onBackground: Colors.white70,

  surface: Color(0xFF1E1E1E),         // Slightly lighter than background
  onSurface: Colors.white70,

  surfaceVariant: Color(0xFF252525),
  onSurfaceVariant: Colors.white54,
);

final terminalDarkTheme = ThemeData(
  colorScheme: darkColorScheme,
  typography: Typography.material2021(),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.robotoMono(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: darkColorScheme.onBackground,
    ),
    displayMedium: GoogleFonts.robotoMono(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: darkColorScheme.onBackground,
    ),
    displaySmall: GoogleFonts.robotoMono(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: darkColorScheme.onBackground,
    ),
    headlineLarge: GoogleFonts.robotoMono(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: darkColorScheme.onBackground,
    ),
    headlineMedium: GoogleFonts.robotoMono(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: darkColorScheme.onBackground,
    ),
    headlineSmall: GoogleFonts.robotoMono(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: darkColorScheme.onBackground,
    ),
    titleLarge: GoogleFonts.robotoMono(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: darkColorScheme.onBackground,
    ),
    titleMedium: GoogleFonts.robotoMono(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: darkColorScheme.onBackground,
    ),
    titleSmall: GoogleFonts.robotoMono(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: darkColorScheme.onBackground,
    ),
    bodyLarge: GoogleFonts.robotoMono(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: darkColorScheme.onBackground,
    ),
    bodyMedium: GoogleFonts.robotoMono(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: darkColorScheme.onBackground,
    ),
    bodySmall: GoogleFonts.robotoMono(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: darkColorScheme.onBackground.withOpacity(0.7),
    ),
    labelLarge: GoogleFonts.robotoMono(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: darkColorScheme.onBackground,
    ),
    labelMedium: GoogleFonts.robotoMono(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: darkColorScheme.onBackground,
    ),
    labelSmall: GoogleFonts.robotoMono(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: darkColorScheme.onBackground.withOpacity(0.7),
    ),
  ),
);