
/// A Material 3 (M3) dark theme implementation that follows Google's latest design system guidelines.
/// Emphasizes accessibility, consistent component behavior, and systematic color application
/// while maintaining the fundamental M3 principles of dynamic color, tone mapping, and contrast modes.
///
/// This theme adheres to M3's core color roles and their relationships:
/// - Key Colors: Primary, Secondary, Tertiary, and Error
/// - Neutral Keys: Background and Surface
/// - Content Colors: On-colors for each key color
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


/// M3 ColorScheme implementation following the color system's role-based approach.
/// Each color serves a specific purpose in the interface:
///
/// Primary colors:
/// - primary: Main brand color, used for prominent UI elements
/// - onPrimary: Content color appearing on primary color
/// - primaryContainer: Used for less prominent components
/// - onPrimaryContainer: Content color for primaryContainer
///
/// Secondary colors:
/// - secondary: Used for less prominent components
/// - onSecondary: Content color appearing on secondary color
/// - secondaryContainer: Used for lower emphasis components
/// - onSecondaryContainer: Content color for secondaryContainer
///
/// Tertiary colors:
/// - tertiary: Used for contrast and balancing
/// - onTertiary: Content color appearing on tertiary color
/// - tertiaryContainer: Used for subtle variations
/// - onTertiaryContainer: Content color for tertiaryContainer
///
/// Error colors:
/// - error: Used for error states and validation
/// - onError: Content color appearing on error color
///
/// Neutral colors:
/// - background: Main app background
/// - onBackground: Primary content color
/// - surface: Component surface color
/// - onSurface: Primary content color on surface
/// - surfaceVariant: Alternative surface color
/// - onSurfaceVariant: Content color for surfaceVariant
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

/// M3 Typography implementation using the type scale system.
/// Follows M3's systematic approach to type scaling and hierarchy:
///
/// Display (Large, Medium, Small):
/// - Used for the largest text elements
/// - Typically headlines and hero text
///
/// Headline (Large, Medium, Small):
/// - Used for content section headers
/// - Provides clear visual hierarchy
///
/// Title (Large, Medium, Small):
/// - Used for UI component headers
/// - More prominent than body text
///
/// Body (Large, Medium, Small):
/// - Used for primary content text
/// - Optimized for readability
///
/// Label (Large, Medium, Small):
/// - Used for component labels and captions
/// - Typically smaller and more compact
///
/// Each text style maintains M3's recommended:
/// - Size relationships
/// - Weight distributions
/// - Letter spacing
/// - Line heights
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