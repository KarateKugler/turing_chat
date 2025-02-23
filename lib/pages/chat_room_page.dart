import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turing_chat/logic/auth_cubit.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';

class ChatRoomPage extends StatelessWidget {
  final ChatRoom chatRoom;

  const ChatRoomPage({
    super.key,
    required this.chatRoom,
  });

  @override
  Widget build(BuildContext context) {
    AuthLoggedIn authState = context.read<AuthCubit>().state as AuthLoggedIn;
    List<Message>? messages = [Message(id: authState.user.id, profileId: chatRoom.contact.id, content: 'Hello void.', createdAt: DateTime.now().subtract(Duration(minutes: 15)), sentByUser: false, generated: true, correclyIdentified: true)];
    //chatRoom.messages;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(chatRoom.contact.username),
        actions: [
          // Score display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You: ${chatRoom.userScore}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '🔥 ${chatRoom.userStreak}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Them: ${chatRoom.contactScore}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '🔥 ${chatRoom.contactStreak}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: messages == null || messages.isEmpty
          ? Center(
              child: Text(
                'No messages yet',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          : CustomScrollView(
              reverse: true, // Show latest messages at the bottom
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final message = messages[index];
                        return MessageBubble(message: message);
                      },
                      childCount: messages.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
