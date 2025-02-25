import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turing_chat/widgets/chat_input_field.dart';

import '../logic/chat_cubit.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';

/// The Chat Room page

/// At the top we of course display the friends username
/// as well as the Scores and whether someone has a streak

/// After every message sent by the contact, one can guess whether it was generated or not
/// And next to the text field there is a generate button, which generates the next message and
/// marks it as generated. After that, the user can decide to either keep sending generated
/// messages, or go back to manual typing.

/// If a message is guessed as generated, the user receives feedback and points depending on whether
/// it was actually generated. If it was generated, the user has to keep guessing, whether the
/// previous messages where also generated or not, and receives additional points for each
/// correct guess.

/// If a block of generated messages ends, the user has 5 messages of buffer to guess in retrospect
/// otherwise, the other user gains some points.

class ChatRoomPage extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatRoomPage({
    super.key,
    required this.chatRoom,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Message>? messages = [
      Message(
        id: '1',
        profileId: context.read<ChatCubit>().state.currentUser!.id,
        content: 'Hello void.',
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        sentByUser: false,
        generated: false,
        correclyIdentified: false,
      ),
      Message(
        id: '2',
        profileId: widget.chatRoom.contact.id,
        content: 'Hello000ooo0101100010100000',
        createdAt: DateTime.now().subtract(Duration(minutes: 10)),
        sentByUser: true,
        generated: false,
        correclyIdentified: false,
      ),
      Message(
        id: '3',
        profileId: widget.chatRoom.contact.id,
        content: 'generated/not identified',
        createdAt: DateTime.now().subtract(Duration(minutes: 5)),
        sentByUser: true,
        generated: true,
        correclyIdentified: false,
      ),
      Message(
        id: '4',
        profileId: widget.chatRoom.contact.id,
        content: 'generated/identified',
        createdAt: DateTime.now().subtract(Duration(minutes: 5)),
        sentByUser: true,
        generated: true,
        correclyIdentified: true,
      ),
      Message(
        id: '5',
        profileId: widget.chatRoom.contact.id,
        content: 'not generated/identified',
        createdAt: DateTime.now().subtract(Duration(minutes: 5)),
        sentByUser: true,
        generated: false,
        correclyIdentified: true,
      ),
    ];
    //chatRoom.messages;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoom.contact.username),
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
                      'You: ${widget.chatRoom.userScore}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '🔥 ${widget.chatRoom.userStreak}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Them: ${widget.chatRoom.contactScore}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '🔥 ${widget.chatRoom.contactStreak}',
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
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          : BlocListener<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)));
                }
              },
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      child: CustomScrollView(
                        reverse: true, // Show latest messages at the bottom
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final message =
                                      messages[messages.length - index - 1];
                                  return MessageBubble(message: message);
                                },
                                childCount: messages.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, right: 8.0, bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ChatInputField(
                                controller: _messageController,
                                onChanged: (_) {
                                  setState(() {});
                                  debugPrint(_messageController.text);
                                }),
                          ),
                          SizedBox(width: 8),
                          FloatingActionButton(
                            onPressed: () {
                              final message = _messageController.text.trim();

                              /// Send the message if just typed
                              if (message.isNotEmpty) {
                                context.read<ChatCubit>().sendMessage(
                                      contactId: widget.chatRoom.contact.id,
                                      content: message,
                                    );
                                _messageController.clear();
                              }

                              /// Otherwise send generation request
                              else {
                                debugPrint('Generate!');
                                // todo
                              }
                            },
                            child: Icon(
                                _messageController.text.isEmpty
                                    ? Icons.psychology
                                    : Icons.send,
                                size: 25),
                            shape: CircleBorder(),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
