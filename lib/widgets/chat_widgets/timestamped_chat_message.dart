import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// The Custom Widget. Widgets are immutable, so when it is changed, we actually
/// have a new widget, and the old widget is long gone. At the beginning a
/// render object is created. Render Objects are mutable, and 'dynamic', at the
/// beginning we pass the initial values. When the Widget changes, the
/// changed parameters are passed to the render object via updateRenderObject.
/// The RenderObject then performs the declared actions or none at all.
class TimeStampedChatMessage extends LeafRenderObjectWidget {
  const TimeStampedChatMessage({
    super.key,
    required this.text,
    required this.sentAt,
    required this.style,
  });

  final String text;
  final String sentAt;
  final TextStyle style;

  /// First necessary function
  @override
  RenderObject createRenderObject(BuildContext context) {
    return TimeStampedChatMessageRenderObject(
      text: text,
      sentAt: sentAt,
      style: style,
      textDirection: Directionality.of(context),
    );
  }

  /// Second necessary function
  @override
  void updateRenderObject(
      BuildContext context,
      TimeStampedChatMessageRenderObject renderObject,
      ) {
    renderObject.text = text;
    renderObject.sentAt = sentAt;
    renderObject.style = style;
    renderObject.textDirection = Directionality.of(context);
  }
}



/// The actual RenderObject
/// It has many private attributes, which we have to declare the getters/setters
/// for. In the case of a Text based RenderObject we also declare private
/// TextSpans which we need for the layout and painting.
///
/// The RenderObject requires us to declare 3 methods:
///
/// 1. performLayout: if we have children, we recursively layout the children.
///    In any case we need to calculate the extents of the objects and set the
///    size.
/// 2. paint: if we have children, we now ofc recursively draw the children.
///    otherwise, we just paint our objects on the canvas with an offset.
/// 3. describeSemanticsConfiguration: this is for accessibility like screen
///    readers.
///
/// I think that's it in general.
class TimeStampedChatMessageRenderObject extends RenderBox {
  TimeStampedChatMessageRenderObject({
    required String sentAt,
    required String text,
    required TextStyle style,
    required TextDirection textDirection,
  }) {
    _sentAt = sentAt;
    _text = text;
    _style = style;
    _textDirection = textDirection;

    _textPainter = TextPainter(
      text: textTextSpan,
      textDirection: _textDirection,
    );

    _sentAtTextPainter = TextPainter(
      text: sentAtTextSpan,
      textDirection: _textDirection,
    );
  }

  late String _sentAt;
  late String _text;
  late TextStyle _style;
  late TextDirection _textDirection;

  late TextPainter _textPainter;
  late TextPainter _sentAtTextPainter;

  late bool _sentAtFitsOnLastLine;
  late double _lineHeight;
  late double _lastMessageLineWidth;
  late double _longestLineWidth;
  late double _sentAtLineWidth;
  late int _numMessageLines;

  /// ----------------- Getters and Setters -----------------
  String get text => _text;

  set text(String val) {
    /// "Guard Statement" to check short circuit conditions
    if (val == _text) {
      return;
    }

    // we now know the value is new
    _text = val;
    _textPainter.text = textTextSpan;

    // because the layout and paintjob depend on text:
    markNeedsLayout();
    // markNeedsPaint(); (is also called by markNeedsLayout)
  }

  String get sentAt => _sentAt;

  set sentAt(String val) {
    if (val == _sentAt) {
      return;
    }

    _sentAt = val;
    _sentAtTextPainter.text = sentAtTextSpan;
    markNeedsLayout();
  }

  TextStyle get style => _style;

  set style(TextStyle val) {
    if (val == _style) {
      return;
    }

    _style = val;
    _textPainter.text = textTextSpan;
    _sentAtTextPainter.text = sentAtTextSpan;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection val) {
    if (val == _textDirection) {
      return;
    }

    _textDirection = val;
    _textPainter.textDirection = val;
    _sentAtTextPainter.textDirection = val;
    markNeedsLayout();
  }

  TextSpan get textTextSpan => TextSpan(text: _text, style: _style);

  TextSpan get sentAtTextSpan =>
      TextSpan(text: _sentAt, style: _style.copyWith(color: Colors.grey));

  /// ----------------- Render Methods -----------------

  /// Has to determine the dimensions of the objects to draw and save to size
  /// object
  @override
  void performLayout() {
    // if this wasn't a Leaf Render Object, and had children we would first
    // have to recursively layout the children:
    // final childrenSize = child.layout();

    // with this we find out the size of the text Painter
    _textPainter.layout(maxWidth: constraints.maxWidth);
    // but we want the specific line dimensions
    final textLines = _textPainter.computeLineMetrics();

    _longestLineWidth = textLines.fold(
      0.0,
          (previousValue, element) => max(previousValue, element.width),
    );
    _lastMessageLineWidth = textLines.last.width;
    _lineHeight = textLines.last.height;
    _numMessageLines = textLines.length;

    final sizeOfMessage = Size(_longestLineWidth, _textPainter.height);

    _sentAtTextPainter.layout(maxWidth: constraints.maxWidth);
    _sentAtLineWidth = _sentAtTextPainter.computeLineMetrics().first.width;

    final lastLineWidthCombined =
        _lastMessageLineWidth + (_sentAtLineWidth * 1.1);
    if (textLines.length == 1) {
      _sentAtFitsOnLastLine = lastLineWidthCombined < constraints.maxWidth;
    } else {
      _sentAtFitsOnLastLine =
          lastLineWidthCombined < min(_longestLineWidth, constraints.maxWidth);
    }

    late Size computedSize;
    if (!_sentAtFitsOnLastLine) {
      computedSize = Size(
        sizeOfMessage.width,
        sizeOfMessage.height + _sentAtTextPainter.height,
      );
    } else {
      if (textLines.length == 1) {
        computedSize = Size(lastLineWidthCombined, sizeOfMessage.height);
      } else {
        computedSize = Size(_longestLineWidth, sizeOfMessage.height);
      }
    }

    size = constraints.constrain(computedSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _textPainter.paint(context.canvas, offset);

    late Offset sentAtOffset;
    if (_sentAtFitsOnLastLine) {
      sentAtOffset = Offset(
        offset.dx + (size.width - _sentAtLineWidth),
        offset.dy + (_lineHeight * (_numMessageLines - 1)),
      );
    } else {
      sentAtOffset = Offset(
        offset.dx + (size.width - _sentAtLineWidth),
        offset.dy + (_lineHeight * _numMessageLines),
      );
    }

    _sentAtTextPainter.paint(context.canvas, sentAtOffset);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    config.isSemanticBoundary = true;
    config.label = '$_text, sent at $_sentAt';
    config.textDirection = _textDirection;
  }
}
