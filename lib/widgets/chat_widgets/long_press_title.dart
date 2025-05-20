import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LongPressTitle extends StatefulWidget {
  final String text;
  final VoidCallback onLongPress;

  const LongPressTitle({
    super.key,
    required this.text,
    required this.onLongPress,
  });

  @override
  State<LongPressTitle> createState() => _LongPressTitleState();
}

class _LongPressTitleState extends State<LongPressTitle> {
  bool _isLongPressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        setState(() {
          _isLongPressing = true;
        });
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        widget.onLongPress();
      },
      onTapCancel: () {
        setState(() {
          _isLongPressing = false;
        });
      },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 1.0, end: _isLongPressing ? 0.95 : 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Text(widget.text),
      ),
    );
  }
} 