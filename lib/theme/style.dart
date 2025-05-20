import 'package:flutter/material.dart';

class Style {
  static double fabIconSize = 25;
  static double cornerRadius = 16.0;
  static double contactTileBorderRadius = 8.0;
  static double chatTextSize = 13.0;
  static double chatSubTextSize = 10.0;
}

/// Animation constants for overlay effects
///
/// This class centralizes all animation-related values to:
/// - Provide a single place to modify animation parameters
///
/// Using a private constructor prevents instantiation, enforcing
/// access through static constants only.
class OverlayAnimations {
  // Colors
  static const glowColor = Color(0xA35F00FF);

  // Animation parameters
  static const blurIntensity = 5.0;
  static const duration = Duration(milliseconds: 500);
  static const curve = Curves.easeInOut;

  // Button animation values
  static const buttonMinPadding = 12.0;
  static const buttonMaxPadding = 60.0;
  static const buttonBottom = 40.0;
  static const buttonBorderRadius = 30.0;

  // Glow effect values
  static const glowBlurRadius = 30.0;
  static const glowMinSpread = -10.0;
  static const glowMaxSpread = 5.0;

  // Prevent instantiation
  OverlayAnimations._();
}