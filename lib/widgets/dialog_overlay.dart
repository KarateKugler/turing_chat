import 'package:flutter/material.dart';

import '../../theme/style.dart';
import 'components/animated_blur_background.dart';

class DialogOverlay extends StatefulWidget {
  final String title;
  final String description;
  final IconData? primaryButtonIcon;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final bool isCritical;

  const DialogOverlay({
    super.key,
    required this.title,
    required this.description,
    this.primaryButtonIcon,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.isCritical = false,
  });

  @override
  State<DialogOverlay> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<DialogOverlay>
    with SingleTickerProviderStateMixin {
  /// Controls all animations timing
  late AnimationController _controller;

  /// Controls the blur intensity animation
  late Animation<double> _blurAnimation;

  /// Controls opacity and element transitions
  late Animation<double> _opacityAnimation;

  /// Controls dialog scale animation
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _controller.forward();
  }

  /// Set up all animation controllers and animations
  ///
  /// This method initializes all animations in one place
  void _initializeAnimations() {
    // Main controller that drives all animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Blur animation for background effect
    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Opacity animation for element fading
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  void _dismissOverlay() {
    // Dismiss the overlay
    _controller.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            // Background blur - handled by dedicated component
            AnimatedBlurBackground(
              blurAnimation: _blurAnimation,
              opacityAnimation: _opacityAnimation,
              onTap: _dismissOverlay,
            ),

            // Dialog content
            Center(
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.all(_scaleAnimation.value * 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(Style.cornerRadius),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Primary Button
                      FilledButton.icon(
                        onPressed: () {
                          widget.onPrimaryPressed();
                          _dismissOverlay();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.isCritical
                            ? Theme.of(context).colorScheme.error
                            : null,
                        ),
                        icon: Icon(widget.primaryButtonIcon),
                        label: Text(widget.primaryButtonText),
                      ),
                      const SizedBox(height: 8),

                      // Cancel Button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.close),
                        onPressed: _dismissOverlay,
                        label: const Text('cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
