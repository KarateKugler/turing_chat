/// A blur overlay that displays a selected message with glow effects and
/// action buttons for interaction. Animates in/out smoothly when a message
/// is selected/deselected.
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

/// Animation constants for overlay effects
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

/// The main overlay widget for handling message selection and actions
class GameOverlay extends StatefulWidget {
  const GameOverlay({super.key});

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
    _initializeAnimations();
  }

  /// Set up all animation controllers and animations
  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: OverlayAnimations.duration,
    );

    // Blur animation
    _blurAnimation = Tween<double>(
      begin: 0.0, 
      end: OverlayAnimations.blurIntensity,
    ).animate(CurvedAnimation(
      parent: _controller, 
      curve: OverlayAnimations.curve,
    ));

    // Opacity animation
    _opacityAnimation = Tween<double>(
      begin: 0.0, 
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller, 
      curve: OverlayAnimations.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handle tap outside the message bubble to dismiss
  void _onTapOutside() {
    _controller.reverse();
    
    // Unfocus after animation completes
    Future.delayed(OverlayAnimations.duration).then((_) {
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
        _handleStateChanges(state);
      },
      builder: (context, state) {
        // Only show overlay when a message is selected
        if (state.selectedMessageIndex != -1) {
          Message selectedMessage = _getSelectedMessage(state);
          return _buildOverlayContent(selectedMessage);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// Handle state changes from the ChatCubit
  void _handleStateChanges(ChatState state) {
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
  }

  /// Get the currently selected message from state
  Message _getSelectedMessage(ChatState state) {
    return state.chatroomsByUsername[state.chatroomContactUsername]!
        .messages[state.selectedMessageIndex];
  }

  /// Build the main overlay content with animations
  Widget _buildOverlayContent(Message message) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            // Background blur
            _AnimatedBlurBackground(
              blurAnimation: _blurAnimation,
              opacityAnimation: _opacityAnimation,
              onTap: _onTapOutside,
            ),

            // Message bubble
            _MessageBubbleWithGlow(
              message: message,
              opacityAnimation: _opacityAnimation,
            ),

            // Action button
            _AnimatedActionButton(
              message: message,
              opacityAnimation: _opacityAnimation,
            ),
          ],
        );
      }
    );
  }
}

/// Animated background with blur effect
class _AnimatedBlurBackground extends StatelessWidget {
  final Animation<double> blurAnimation;
  final Animation<double> opacityAnimation;
  final VoidCallback onTap;

  const _AnimatedBlurBackground({
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

/// Message bubble with glow effect
class _MessageBubbleWithGlow extends StatelessWidget {
  final Message message;
  final Animation<double> opacityAnimation;

  const _MessageBubbleWithGlow({
    required this.message,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: opacityAnimation.value,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: OverlayAnimations.glowBlurRadius,
                            spreadRadius: -5 * opacityAnimation.value,
                            color: OverlayAnimations.glowColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  MessageBubble(message: message),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Animated action button with glow effect
class _AnimatedActionButton extends StatelessWidget {
  final Message message;
  final Animation<double> opacityAnimation;

  const _AnimatedActionButton({
    required this.message,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: OverlayAnimations.buttonBottom,
      left: 0,
      right: 0,
      child: Center(
        child: Opacity(
          opacity: opacityAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: OverlayAnimations.glowBlurRadius * opacityAnimation.value,
                  spreadRadius: OverlayAnimations.glowMinSpread + 
                      (OverlayAnimations.glowMaxSpread + 
                       OverlayAnimations.glowMinSpread) * opacityAnimation.value,
                  color: OverlayAnimations.glowColor,
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: () => _classifyMessage(context),
              icon: const Icon(Icons.content_paste_search),
              label: const Text('  C L A S S I F Y'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: OverlayAnimations.buttonMinPadding + 
                    (OverlayAnimations.buttonMaxPadding - OverlayAnimations.buttonMinPadding) * 
                    opacityAnimation.value,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OverlayAnimations.buttonBorderRadius),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Send message for classification
  void _classifyMessage(BuildContext context) {
    context.read<ChatCubit>().classifyMessage(messageId: message.id);
  }
}
