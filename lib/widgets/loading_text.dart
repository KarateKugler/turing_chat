import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// A text-based loading widget that shows animated indicators
///
/// Displays either a spinning braille pattern (for length 1) or
/// animated symbols (for length > 1) with configurable style
class LoadingText extends StatefulWidget {
  /// The length of text to display
  final int length;

  /// The style to apply to the text
  final TextStyle? style;

  /// The speed of the timer
  final Duration tickDuration;

  const LoadingText({
    Key? key,
    this.length = 1,
    this.style,
    this.tickDuration = const Duration(milliseconds: 80),
  }) : super(key: key);

  @override
  State<LoadingText> createState() => _LoadingTextState();
}

class _LoadingTextState extends State<LoadingText> {
  // Timer for animation
  Timer? _timer;
  
  // Current frame index
  int _currentFrame = 0;
  
  // Text currently displayed
  String _displayText = '';
  
  // Spinner frames for length 1
  static const List<String> _spinnerFrames = [
    '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'
  ];
  
  // Symbol pool for length > 1
  static const String _symbolPool = 
    '↯↭↬↫⇱⇲⇅⇶⇵⇄⇆⇹⇻⇼⟿⤾⤿⥀⥁⥂⥃⥄⌬⍾⎔⏢⏣⏤⏥✧✦=✵✶✷✸⎇⎆⎔⎕⌗⏣⏥⏢⌤⍰⎈⌂⌁⏻⏼⭘⏾⏽⭗';
  
  // All possible symbols to use in animation
  List<String> _symbols = [];
  
  // Random generator
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initSymbols();
    _startAnimation();
  }
  
  @override
  void didUpdateWidget(LoadingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length != widget.length) {
      _initSymbols();
    }
  }

  @override
  void dispose() {
    _stopAnimation();
    super.dispose();
  }
  
  /// Initialize the symbols list based on the length
  void _initSymbols() {
    if (widget.length <= 1) {
      _displayText = _spinnerFrames[0];
      return;
    }
    
    // For longer lengths, create a random permutation of symbols
    _symbols = _symbolPool.split('');
    _symbols.shuffle(_random);
    // and only take as many symbols as the lenght.
    _symbols = _symbols.take(widget.length).toList();

    // Create initial display text
    _displayText = _generateDisplayText(0);
  }
  
  /// Start the animation timer
  void _startAnimation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 80), _updateFrame);
  }
  
  /// Stop the animation timer
  void _stopAnimation() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// Update the animation frame
  void _updateFrame(Timer timer) {
    setState(() {
      if (widget.length <= 1) {
        // For length 1, just rotate through spinner frames
        _currentFrame = (_currentFrame + 1) % _spinnerFrames.length;
        _displayText = _spinnerFrames[_currentFrame];
      } else {
        _currentFrame = (_currentFrame + 1) % widget.length;
        // For longer lengths, generate a new random display text
        _displayText = _generateDisplayText(_currentFrame);
      }
    });
  }
  
  /// Generate a display text with random symbols for the specified length
  String _generateDisplayText(int currentFrame) {
    // Create a string with the specified length
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < widget.length; i++) {
      int index = (currentFrame + i) % widget.length;
      buffer.write(_symbols[index]);
    }
    
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style,
    );
  }
} 