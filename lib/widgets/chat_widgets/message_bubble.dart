/// MessageBubble widget for chat messages
///
/// Displays chat messages with different styles based on:
/// - Who sent the message (user or contact)
/// - Message status (generated, correctly identified)
/// - Delivery status (sent, pending)

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:turing_chat/theme/style.dart';

import '../../models/message.dart';

/// Style constants for message bubbles
class MessageBubbleStyle {
  // Sizing
  static const double maxWidthFactor = 0.75;
  static const double borderRadius = 16.0;
  static const double padding = 12.0;
  static const double horizontalMargin = 16.0;
  static const double verticalMargin = 4.0;
  static const double metadataSpacing = 4.0;
  static const double metadataIconSpacing = 2.0;
  static const double iconPadding = 3.0;

  // Effects
  static const int bubbleOpacity = 200;
  static const double generatedBorderWidth = 2.0;
  static const double glowBlurRadius = 10.0;
  static const double glowSpreadRadius = 3.0;

  // Prevent instantiation
  MessageBubbleStyle._();
}

/// Main message bubble widget
class MessageBubble extends StatelessWidget {
  final Message message;

  /// Should show some pop up bbls to just drag and select (like pinterest)
  final void Function()? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * MessageBubbleStyle.maxWidthFactor,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: MessageBubbleStyle.horizontalMargin,
          vertical: MessageBubbleStyle.verticalMargin,
        ),
        child: GestureDetector(
          onLongPress: onLongPress,
          child: _BubbleContainer(message: message),
        ),
      ),
    );
  }

  /// Get alignment based on who sent the message
  Alignment _getAlignment() {
    return message.sentByUser ? Alignment.centerRight : Alignment.centerLeft;
  }
}

/// Container with styling for the bubble
class _BubbleContainer extends StatelessWidget {
  final Message message;

  const _BubbleContainer({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bubbleColor = _getBubbleColor(colorScheme);
    final textColor = _getTextColor(colorScheme);
    final border = _getBorder(context);
    final shadowColor = _getShadowColor(context);
    final borderRadius = _getBorderRadius();

    return Material(
      color: bubbleColor,
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: border,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: MessageBubbleStyle.glowBlurRadius,
              spreadRadius: MessageBubbleStyle.glowSpreadRadius,
            ),
          ],
        ),
        padding: const EdgeInsets.all(MessageBubbleStyle.padding),
        child: _MessageContent(
          message: message,
          textColor: textColor,
        ),
      ),
    );
  }

  /// Get bubble background color
  Color _getBubbleColor(ColorScheme colorScheme) {
    return message.sentByUser
        ? colorScheme.secondary.withAlpha(MessageBubbleStyle.bubbleOpacity)
        : colorScheme.tertiary.withAlpha(MessageBubbleStyle.bubbleOpacity);
  }

  /// Get text color based on bubble color
  Color _getTextColor(ColorScheme colorScheme) {
    return message.sentByUser 
        ? colorScheme.onSecondary 
        : colorScheme.onTertiary;
  }

  /// Get border if message is generated
  Border? _getBorder(BuildContext context) {
    return message.generated
        ? Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: MessageBubbleStyle.generatedBorderWidth,
          )
        : null;
  }

  /// Get shadow color based on correct identification
  Color _getShadowColor(BuildContext context) {
    if (message.correctlyIdentified == null) {
      return Colors.transparent;
    }
    
    return message.correctlyIdentified!
        ? Colors.greenAccent.withAlpha(100)
        : Theme.of(context).colorScheme.error.withAlpha(100);
  }

  /// Get border radius based on message direction
  BorderRadius _getBorderRadius() {
    return BorderRadius.only(
      topLeft: const Radius.circular(MessageBubbleStyle.borderRadius),
      topRight: const Radius.circular(MessageBubbleStyle.borderRadius),
      bottomLeft: Radius.circular(message.sentByUser ? MessageBubbleStyle.borderRadius : 0),
      bottomRight: Radius.circular(message.sentByUser ? 0 : MessageBubbleStyle.borderRadius),
    );
  }
}

/// Message content with text and metadata
class _MessageContent extends StatelessWidget {
  final Message message;
  final Color textColor;

  const _MessageContent({
    required this.message,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Message text
        Text(
          message.content,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: textColor,
              ),
        ),
        
        const SizedBox(height: MessageBubbleStyle.metadataSpacing),
        
        // Metadata row (timestamp and status)
        _MessageMetadata(
          message: message,
          textColor: textColor,
        ),
      ],
    );
  }
}

/// Metadata showing timestamp and delivery status
class _MessageMetadata extends StatelessWidget {
  final Message message;
  final Color textColor;

  const _MessageMetadata({
    required this.message,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Timestamp
        Text(
          timeago.format(message.createdAt),
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: textColor.withAlpha(180),
                fontWeight: FontWeight.normal,
              ),
        ),
        
        const SizedBox(width: MessageBubbleStyle.metadataIconSpacing),
        
        // Status icon
        Padding(
          padding: const EdgeInsets.all(MessageBubbleStyle.iconPadding),
          child: Icon(
            message.sent
                ? Icons.check_circle_outlined
                : Icons.radio_button_unchecked,
            size: Style.chatSubTextSize,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        )
      ],
    );
  }
}
