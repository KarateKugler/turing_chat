/// Just display the selected message bubble in the middle
/// and make the original sliver transparent. display it over the whole
/// chat screen
///
/// ofc tap outside ret
///
/// Give it a very wide blurred glow, for now just one fat action button
/// at the bottom/middle to 'expose'.
/// -> sends request to backend, checks if guessed correctly, lo.indc. etc., db intgt.
///
///
/// future versions: 'expose' button next to, reaction emojis, reply option

import 'dart:ui';

import 'package:flutter/material.dart';

final glowColor = Color(0xA35F00FF);

/// A widget that applies a blur effect to its background when a message bubble is selected.
///
/// When a message bubble is long-pressed, this widget blurs the entire screen except
/// for the selected message bubble, which is displayed prominently in the center.
/// Tapping outside the message bubble dismisses the blur effect.
class GameOverlay extends StatefulWidget {
  /// The selected message bubble to display prominently when blurred.
  /// If null, no blur effect is applied and the child is displayed normally.
  final Widget? messageBubble;

  /// Optional callback function for actions performed on the selected message bubble.
  final VoidCallback? onAction;

  /// The blur intensity to apply to the background when a message is selected.
  final double blurIntensity;

  /// Duration for the blur animation.
  final Duration animationDuration;

  GameOverlay({
    super.key,
    this.messageBubble,
    this.onAction,
    this.blurIntensity = 5.0,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  @override
  State<GameOverlay> createState() => _GameOverlayState();
}

class _GameOverlayState extends State<GameOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;
  bool _active = false;

  @override
  void initState() {
    super.initState();

    // set up anim con
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // blur anim
    _blurAnimation = Tween<double>(begin: 0.0, end: widget.blurIntensity)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // opc anim
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant GameOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messageBubble != oldWidget.messageBubble) {
      _controller.forward();
      setState(() {
        _active = true;
      });
    }
  }

  void _onTapOutside() {
    _controller.reverse();

    // unfocus
    Future.delayed(widget.animationDuration).then((_) {
      setState(() {
        _active = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messageBubble != null && _active) {
      return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                // Blur overlay with tap detection to dismiss
                // looks good
                GestureDetector(
                  onTap: _onTapOutside,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value,
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
                                .withOpacity(_opacityAnimation.value * 0.3),
                            const Color(0x402C2C2C)
                                .withOpacity(_opacityAnimation.value * 0.3),
                            //magic num
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Centered message bubble with highlight effect (only shown when a message is selected)
                Column(
                  // to hack the layout
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: _opacityAnimation.value,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 30,
                                        spreadRadius:
                                            -5 * _opacityAnimation.value,
                                        color: glowColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              widget.messageBubble!
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Action button (only shown when a message is selected and onAction is provided)
                if (widget.onAction != null)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 30 * _opacityAnimation.value,
                                spreadRadius: -10 + 5 * _opacityAnimation.value,
                                color: glowColor,
                              ),
                            ],
                          ),
                          child: FilledButton.icon(
                            // this needs to be bigger
                            onPressed: widget.onAction,
                            icon: const Icon(Icons.visibility),
                            label: const Text('Expose'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 + _opacityAnimation.value * 12,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          });
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
