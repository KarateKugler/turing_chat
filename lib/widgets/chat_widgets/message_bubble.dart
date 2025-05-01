import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:turing_chat/theme/style.dart';

import '../../models/message.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    /// align
    final alignment =
        message.sentByUser ? Alignment.centerRight : Alignment.centerLeft;
    final textAlignment = CrossAxisAlignment.start;

    /// fill col
    final bubbleColor = message.sentByUser
        ? colorScheme.secondary.withAlpha(200)
        : colorScheme.tertiary.withAlpha(200);

    /// text col
    final textColor =
        message.sentByUser ? colorScheme.onSecondary : colorScheme.onTertiary;

    /// border
    final border = (
            // (message.correctlyIdentified != null || message.sentByUser) && // for testing purposes todo: add back in ofc
            message.generated)
        ? Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          )
        : null;

    /// glow
    final shadowColor = message.correctlyIdentified == null
        ? Colors.transparent
        : (message.correctlyIdentified!
            ? Colors.greenAccent.withAlpha(100) // or blueAccent
            : Theme.of(context).colorScheme.error.withAlpha(100));

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
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Material(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(message.sentByUser ? 16 : 0),
              bottomRight: Radius.circular(message.sentByUser ? 0 : 16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.sentByUser ? 16 : 0),
                  bottomRight: Radius.circular(message.sentByUser ? 0 : 16),
                ),
                border: border,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: textAlignment,
                children: [
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: textColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeago.format(message.createdAt),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: textColor.withAlpha(180),
                          fontWeight: FontWeight.normal,
                            ),
                      ),
                      SizedBox(width: 2),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Icon(
                          message.sent
                              ? Icons.check_circle_outlined
                              : Icons.radio_button_unchecked,
                          size: Style.chatSubTextSize,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
