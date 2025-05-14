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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turing_chat/models/message.dart';
import 'package:turing_chat/widgets/chat_widgets/message_bubble.dart';

import '../../logic/chat_cubit.dart';

const glowColor = Color(0xA35F00FF);
const blurIntensity = 5.0;
const blurDuration = Duration(milliseconds: 500);
const geomDuration = Duration(milliseconds: 100);

/// The chat game overlay widget which displays one or more messages,
/// animates them and shows buttons at the bottom.
class GameOverlay extends StatefulWidget {
  const GameOverlay({
    super.key,
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;
  bool _active = false;

  @override
  void initState() {
    super.initState();

    // Set up animation controller
    _controller = AnimationController(
      vsync: this,
      duration: blurDuration,
    );

    // Blur animation
    _blurAnimation = Tween<double>(begin: 0.0, end: blurIntensity)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapOutside() {
    _controller.reverse();
    
    // Unfocus after animation completes
    Future.delayed(blurDuration).then((_) {
      setState(() {
        _active = false;
      });
      context.read<ChatCubit>().deselectMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        // Start animation when a message is selected
        if (state.selectedMessageIndex != -1 && !_active) {
          _controller.forward();
          setState(() {
            _active = true;
          });
        } else if (state.selectedMessageIndex == -1 && _active) {
          _controller.reverse().then((_) {
            setState(() {
              _active = false;
            });
          });
        }
      },
      builder: (context, state) {
        if (state.selectedMessageIndex != -1) {
          Message message = state
              .chatroomsByUsername[state.chatroomContactUsername]!
              .messages[state.selectedMessageIndex];
          MessageBubble messageBubble = MessageBubble(message: message);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                children: [
                  /// BLUR BACKGROUND
                  // with tap detection to dismiss
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// MESSAGE
                  // Centered message bubble with highlight effect
                  Column(
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
                                          spreadRadius: -5 * _opacityAnimation.value,
                                          color: glowColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                messageBubble
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  /// ACTION BUTTONS
                  // Action button with animation
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
                            onPressed: () {
                              ChatCubit chatCubit = context.read<ChatCubit>();
                              chatCubit.classifyMessage(messageId: message.id);
                            },
                            icon: const Icon(Icons.content_paste_search),
                            label: const Text('  C L A S S I F Y'),
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 + _opacityAnimation.value * 48,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.primary
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
