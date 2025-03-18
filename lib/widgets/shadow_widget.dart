import 'package:flutter/material.dart';

class ShadowWidget extends StatelessWidget {
  final Color? color;
  final List<BoxShadow>? shadow;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;

  final Widget child;

  const ShadowWidget({
    super.key,
    this.color,
    this.shadow,
    this.border,
    this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: shadow,
              border: border,
              borderRadius: borderRadius,
            ),
          ),
        ),
        Material(
          borderRadius: borderRadius,
          child: child,
        ),
      ],
    );
  }
}
