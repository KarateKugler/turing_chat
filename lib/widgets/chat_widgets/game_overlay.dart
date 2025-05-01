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
import 'package:turing_chat/widgets/chat_widgets/message_bubble.dart';

const glowColor = Color(0xA35F00FF);

/// The chat game overlay widget which displays one or more messages,
/// animates them and shows buttons at the bottom.




/// A widget that applies a blur effect to its background when a message bubble is selected.
///
/// When a message bubble is long-pressed, this widget blurs the entire screen except
/// for the selected message bubble, which is displayed prominently in the center.
/// Tapping outside the message bubble dismisses the blur effect.
class GameOverlay extends StatefulWidget {
  /// The selected message bubble to display prominently when blurred.
  /// If null, no blur effect is applied and the child is displayed normally.
  final List<MessageBubble>? messageBubbles;

  /// Optional callback function for actions performed on the selected message bubble.
  final VoidCallback? onAction;

  /// The blur intensity to apply to the background when a message is selected.
  final double blurIntensity;

  /// Duration for the blur animation.
  final Duration blurDuration;

  /// Duration for the blur animation.
  final Duration geomDuration;

  const GameOverlay({
    super.key,
    this.messageBubbles,
    this.onAction,
    this.blurIntensity = 5.0,
    this.blurDuration = const Duration(milliseconds: 500),
    this.geomDuration = const Duration(milliseconds: 100),
  });

  @override
  State<GameOverlay> createState() => _GameOverlayState();
}

/// This widget has two purposes:
///
/// 1. Select one of your own messages:
///   - delete
///   - reply
///
/// 2. select friends message:
///   - reply
///   - guess 'generated'
///   - (last few messages get shown)
///
/// So the animation should go like this:
///
/// The background opacity/blur animation starts at the same time as
/// The Button and Messages animation starts
///
/// The last ~5 messages slide+fade in from the top, staggered,
/// i.e. animation duration 200ms, stagger offset of 100ms
class _GameOverlayState extends State<GameOverlay>
    with TickerProviderStateMixin {
  late AnimationController _blurController;
  late AnimationController _geomController;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _buttonAnimation;

  /// The Durations for the animations
  static const _initialDelayTime = Duration(milliseconds: 50);
  static const _staggerTime = Duration(milliseconds:  100);
  static const _messageTime = Duration(milliseconds: 200);

  final List<Interval> _slideIntervals = [];
  late Interval _buttonInterval;


  // whether the message widget is currently being shown
  bool _active = false;

  @override
  void initState() {
    super.initState();

    // set up anim con
    _blurController = AnimationController(
      vsync: this,
      duration: widget.blurDuration,
    );

    _geomController =
        AnimationController(vsync: this, duration: widget.geomDuration);

    // blur anim
    _blurAnimation = Tween<double>(begin: 0.0, end: widget.blurIntensity)
        .animate(
            CurvedAnimation(parent: _blurController, curve: Curves.easeInOut));

    // opc anim
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _blurController, curve: Curves.easeInOut));



    // geom anim
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _geomController, curve: Curves.easeInOut));
  }


  @override
  void didUpdateWidget(covariant GameOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messageBubbles != null) {
      _blurController.forward();
      _geomController.forward();
      setState(() {
        _active = true;
      });
    }
  }


  void _onTapOutside() {
    _blurController.reverse();
    _geomController.reverse();

    // unfocus
    Future.delayed(widget.blurDuration).then((_) {
      setState(() {
        _active = false;
      });
    });
  }

  // void _createAnimationIntervals() {
  //   for (var i = 0; i < _menuTitles.length; ++i) {
  //     final startTime = _initialDelayTime + (_staggerTime * i);
  //     final endTime = startTime + _itemSlideTime;
  //     _itemSlideIntervals.add(
  //       Interval(
  //         startTime.inMilliseconds / _animationDuration.inMilliseconds,
  //         endTime.inMilliseconds / _animationDuration.inMilliseconds,
  //       ),
  //     );
  //   }
  //
  //   final buttonStartTime =
  //       Duration(milliseconds: (_menuTitles.length * 50)) + _buttonDelayTime;
  //   final buttonEndTime = buttonStartTime + _buttonTime;
  //   _buttonInterval = Interval(
  //     buttonStartTime.inMilliseconds / _animationDuration.inMilliseconds,
  //     buttonEndTime.inMilliseconds / _animationDuration.inMilliseconds,
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    if (widget.messageBubbles != null && _active) {
      return Stack(
        children: [
          /// BLUR BACKGROUND
          // with tap detection to dismiss
          // looks good
          GestureDetector(
            onTap: _onTapOutside,
            child: AnimatedBuilder(
                animation: _blurController,
                builder: (context, _) {
                  return BackdropFilter(
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
                  );
                }),
          ),

          /// MESSAGE/S
          // Centered message bubble with highlight effect (only shown when a message is selected)
          Column(
            // to hack the layout
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _blurController,
                    builder: (context, child) {
                      return Opacity(
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
                                          20 * _opacityAnimation.value - 20,
                                      color: glowColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            child!
                          ],
                        ),
                      );
                    },
                    child: widget.messageBubbles!.first,
                  ),
                ],
              ),
            ],
          ),

          /// ACTION BUTTONS
          // Action button (only shown when a message is selected and onAction is provided)
          if (widget.onAction != null)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                    animation: _geomController,
                    builder: (context, _) {
                      return Opacity(
                        opacity: _buttonAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 30 * _buttonAnimation.value,
                                spreadRadius: -10 + 5 * _buttonAnimation.value,
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
                                horizontal: 12 + _buttonAnimation.value * 12,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _blurController.dispose();
    super.dispose();
  }
}
