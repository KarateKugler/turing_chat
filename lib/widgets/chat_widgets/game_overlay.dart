/// GameOverlay Widget
/// 
/// A modular, animation-rich overlay system that displays a selected message with
/// visual effects and interactive elements.
///
/// # Architecture Overview
///
/// This file implements a modular overlay system with these key components:
///
/// 1. Main Container (GameOverlay): Orchestrates the overlay system and manages state
/// 2. Animation Constants (OverlayAnimations): Centralizes all animation parameters
/// 3. Component Widgets:
///    - _AnimatedBlurBackground: Handles backdrop effects
///    - _MessageBubbleWithGlow: Manages message display and glow effects
///    - _AnimatedActionButton: Controls interaction buttons with animations
///
/// # Modularization Benefits
///
/// - Single Responsibility: Each component has a focused purpose
/// - Maintainability: Changes to one component don't affect others
/// - Reusability: Components can be used in other contexts
/// - Testability: Components can be tested in isolation
/// - Readability: Clear separation makes code intent obvious
///
/// # Usage Example
///
/// Place this widget above your chat interface:
///
/// ```dart
/// Stack(
///   children: [
///     ChatMessages(),
///     GameOverlay(), // Appears when a message is selected
///   ],
/// )
/// ```
///
/// The overlay automatically responds to state changes in the ChatCubit.
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

/// The main overlay widget for handling message selection and actions
///
/// # Responsibilities
///
/// 1. State Management:
///    - Track animation state and active status
///    - Respond to ChatCubit state changes
///
/// 2. Animation Control:
///    - Initialize and dispose animation controllers
///    - Control forward/reverse animations based on state
///
/// 3. Coordination:
///    - Combine component widgets (_AnimatedBlurBackground,
///      _MessageBubbleWithGlow, _AnimatedActionButton)
///    - Pass appropriate animations to each component
///
/// delegates rendering to specialized component widgets
class GameOverlay extends StatefulWidget {
  const GameOverlay({super.key});

  @override
  State<GameOverlay> createState() => _GameOverlayState();
}

/// State for the GameOverlay widget
///
/// This state manages animation controllers and responds to
/// state changes from the ChatCubit. It uses a modular design where
/// UI rendering is delegated to specialized components.
///
/// # Modular Architecture:
///
/// The state class focuses on:
/// - Animation setup and management
/// - Building the component tree
/// - State change detection
///
/// Components handle their specific rendering concerns.
class _GameOverlayState extends State<GameOverlay>
    with SingleTickerProviderStateMixin {
  /// Controls all animations timing
  late AnimationController _controller;
  
  /// Controls the blur intensity animation
  late Animation<double> _blurAnimation;
  
  /// Controls opacity and element transitions
  late Animation<double> _opacityAnimation;
  
  /// Whether the overlay is currently active
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Set up all animation controllers and animations
  ///
  /// This method initializes all animations in one place
  void _initializeAnimations() {
    // Main controller that drives all animations
    _controller = AnimationController(
      vsync: this,
      duration: OverlayAnimations.duration,
    );

    // Blur animation for background effect
    _blurAnimation = Tween<double>(
      begin: 0.0, 
      end: OverlayAnimations.blurIntensity,
    ).animate(CurvedAnimation(
      parent: _controller, 
      curve: OverlayAnimations.curve,
    ));

    // Opacity animation for element fading
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
    // Properly dispose animation resources
    _controller.dispose();
    super.dispose();
  }

  /// Handle tap outside the message bubble to dismiss
  ///
  /// This creates a smooth dismissal experience
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
  ///
  /// - When a message becomes selected, start forward animation
  /// - When a message becomes deselected, start reverse animation
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
  ///
  /// # Modular Component Assembly
  ///
  /// Adding components with:
  ///    - Appropriate animation values
  ///    - Required data (message)
  ///    - Callback functions
  ///
  /// Each component handles its own rendering details.
  Widget _buildOverlayContent(Message message) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            // Background blur - handled by dedicated component
            _AnimatedBlurBackground(
              blurAnimation: _blurAnimation,
              opacityAnimation: _opacityAnimation,
              onTap: _onTapOutside,
            ),

            // Message bubble - handled by dedicated component
            _MessageBubbleWithGlow(
              message: message,
              opacityAnimation: _opacityAnimation,
            ),

            // Action button - handled by dedicated component
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
///
/// - Rendering the fullscreen backdrop
/// - Applying animated blur effect
/// - Managing the background gradient
/// - Handling tap detection
///
/// - Isolates backdrop rendering logic
/// - Can be reused for other overlay effects
///
/// The component accepts animations as parameters rather than
/// creating its own. (dependency injection)
class _AnimatedBlurBackground extends StatelessWidget {
  /// Animation that controls blur intensity
  final Animation<double> blurAnimation;
  
  /// Animation that controls background opacity
  final Animation<double> opacityAnimation;
  
  /// Callback when background is tapped
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
///
/// - Encapsulates message display logic
///
/// The Stack configuration creates the glow effect behind the actual
/// message bubble.
class _MessageBubbleWithGlow extends StatelessWidget {
  /// The message to display
  final Message message;
  
  /// Animation that controls opacity and other effects
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
                  // Glow effect layer - positioned behind the message
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
                  // Actual message bubble
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
///
/// - Isolates button rendering and behavior
///
/// The button uses animated padding and glow effects that
/// respond to the same animation as other components.
class _AnimatedActionButton extends StatelessWidget {
  /// The message that the action applies to
  final Message message;
  
  /// Animation that controls button effects
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
                // Dynamic padding creates a "growing" effect
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
  ///
  /// This method keeps business logic for the button separated from the UI rendering code.
  void _classifyMessage(BuildContext context) {
    context.read<ChatCubit>().classifyMessage(messageId: message.id);
  }
}
