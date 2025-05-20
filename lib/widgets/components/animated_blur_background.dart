import 'dart:ui';

import 'package:flutter/material.dart';

/// Animated background with blur effect
///
/// - Renders a fullscreen backdrop
/// - animated blur effect
/// - with background gradient
/// - tap detection
///
/// (The component accepts animations as parameters rather than
/// creating its own. i.e. dependency injection)
class AnimatedBlurBackground extends StatelessWidget {
  /// Animation that controls blur intensity
  final Animation<double> blurAnimation;

  /// Animation that controls background opacity
  final Animation<double> opacityAnimation;

  /// Callback when background is tapped
  final VoidCallback onTap;

  const AnimatedBlurBackground({
    super.key,
    required this.blurAnimation,
    required this.opacityAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurAnimation.value,
          sigmaY: blurAnimation.value,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0x3F353535)
                    .withOpacity(opacityAnimation.value * 0.3),
                const Color(0x402C2C2C)
                    .withOpacity(opacityAnimation.value * 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
