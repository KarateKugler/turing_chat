import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Style {
  static Color themeColor1 = Color(0xFFbd8cbf);
  static Color themeColor2 = Color(0xFF5d3161);
  static Color themeColor3 = Color(0xFF8781be);
  static Color themeColor4 = Color(0xFF453f5f);

  static Color glowColor1 = Color(0xffc125c7);
  static Color glowColor2 = Color(0xff3121c5);

  static double fabIconSize = 25;
  static double cornerRadius = 16.0;
  static double contactTileBorderRadius = 16.0;
  static double chatTextSize = 13.0;
  static double chatSubTextSize = 10.0;

  /// Creates a markdown style sheet that matches the app's theme
  static MarkdownStyleSheet markdownStyleSheet(BuildContext context) {
    return MarkdownStyleSheet(
      h1: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      h2: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      p: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontSize: 16,
        height: 1.5,
      ),
      strong: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.bold,
      ),
      em: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontStyle: FontStyle.italic,
      ),
      listBullet: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
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