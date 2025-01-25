import 'dart:ui';

import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  final double blur;
  final double? width;
  final double? height;
  final double? borderRadius;
  final List<Color>? gradientColors;
  final Border? border;
  final Widget? child;

  const GlassBox(
      {super.key,
      required this.blur,
      this.width,
      this.height,
      this.borderRadius,
      this.gradientColors,
      this.border,
      this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            /// Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blur,
                sigmaY: blur,
              ),
              child: Container(),
            ),

            /// gradient effect
            Container(
              decoration: BoxDecoration(
                border: border,
                borderRadius:
                    border != null // conditional might not be necessary
                        ? BorderRadius.circular(borderRadius ?? 0)
                        : null,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors ??
                      [
                        const Color(0xFF353535),
                        const Color(0xFF2C2C2C),
                      ],
                ),
              ),
            ),

            /// child
            child != null ? child! : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
