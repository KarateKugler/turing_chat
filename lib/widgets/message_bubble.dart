import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine bubble alignment and style based on sender
    final isUserMessage = message.sentByUser;
    final alignment =
        isUserMessage ? Alignment.centerRight : Alignment.centerLeft;
    final textAlignment =
        isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    // Base bubble color based on sender
    final bubbleColor = isUserMessage
        ? colorScheme.secondary.withOpacity(0.8)
        : colorScheme.tertiary.withOpacity(0.8);

    // Text color based on bubble color
    final textColor =
        isUserMessage ? colorScheme.onSecondary : colorScheme.onTertiary;

    // Border color for AI generated messages
    final borderColor = message.generated
        ? (message.correclyIdentified ? colorScheme.primary : colorScheme.error)
        : Colors.transparent;

    // Glow color for correctly identified messages
    final shadowColor = message.correclyIdentified
        ? Colors.greenAccent.withOpacity(0.4)
        : Colors.transparent;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUserMessage ? 16 : 0),
              bottomRight: Radius.circular(isUserMessage ? 0 : 16),
            ),
            border: Border.all(
              color: borderColor,
              width: message.generated ? 2 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: textAlignment,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeago.format(message.createdAt),
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
