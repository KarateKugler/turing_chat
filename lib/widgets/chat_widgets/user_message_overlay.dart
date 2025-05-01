import 'package:flutter/material.dart';
import 'package:turing_chat/widgets/chat_widgets/message_bubble.dart';

/// The single message overlay using the game overlay
///
/// Is used for user's own messages.
/// Displays one message bubble and animates it.
/// And shows two buttons for the following actions:
///   - reply
///   - delete
///
/// (so it builds a GameOverlay, gives it the messageBubble,
///   the List<Widget> for the actions,
///   and specifies the animation it wants for the messageBubble.
class UserMessageOverlay extends StatelessWidget {
  const UserMessageOverlay({
    super.key,
    required this.messageBubble,
    required this.onReply,
    required this.onDelete,
  });

  final MessageBubble? messageBubble;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
