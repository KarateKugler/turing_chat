import 'dart:math';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turing_chat/models/contact.dart';
import 'package:turing_chat/widgets/chat_widgets/chat_input_field.dart';
import 'package:turing_chat/widgets/loading_widget.dart';

import '../logic/chat_cubit.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../theme/style.dart';
import '../widgets/chat_widgets/game_overlay.dart';
import '../widgets/chat_widgets/long_press_title.dart';
import '../widgets/chat_widgets/message_bubble.dart';
import '../widgets/dialog_overlay.dart';

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
  /// Text Input
  late final TextEditingController _inputController;
  final FocusNode _inputFocusNode = FocusNode();

  /// generation
  bool _generateLoading = false;

  /// Selecting a message
  List<MessageBubble>? _selectedMessageBubble;

  /// Long press state
  bool _isLongPressing = false;

  /// Reference to the chatcubit
  late ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _chatCubit = context.read<ChatCubit>();
  }

  @override
  void didChangeDependencies() {
    ChatCubit chatCubit = context.read<ChatCubit>();
    chatCubit.fetchMessages(widget.chatRoom.contact.username);
    // listen to messages
    chatCubit.addMessageSubscription(widget.chatRoom.contact.username);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // remove message listener
    _chatCubit.removeMessageSubscription(widget.chatRoom.contact.username);
    _inputController.dispose();
    super.dispose();
  }

  /// msg bubble

  void _handleMessageLongPress(int messageIndex) {
    // change state, just emit with selected message index,
    // rest is done by cubit and the overlay widget
    context.read<ChatCubit>().selectMessage(messageIndex);
  }

  @override
  Widget build(BuildContext context) {
    /// Placeholder messages for testing
    List<Message> messages = widget.chatRoom.messages;
    //chatRoom.messages;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: LongPressTitle(
              text: widget.chatRoom.contact.username,
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => DialogOverlay(
                    title: 'block contact',
                    description:
                        'are you sure you want to block ${widget.chatRoom.contact.username}? You will no longer be able to send or receive messages from them.',
                    primaryButtonText: 'block',
                    primaryButtonIcon: Icons.no_accounts,
                    onPrimaryPressed: () {
                      context
                          .read<ChatCubit>()
                          .blockContact(widget.chatRoom.contact.id);
                    },
                    isCritical: true,
                  ),
                );
              },
            ),
            actions: [
              // Score display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'You: ${state.chatroomsByUsername[state.chatroomContactUsername]!.userScore}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '🔥 ${state.chatroomsByUsername[state.chatroomContactUsername]!.userStreak}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Them: ${state.chatroomsByUsername[state.chatroomContactUsername]!.contactScore}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '🔥 ${state.chatroomsByUsername[state.chatroomContactUsername]!.contactStreak}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          /// Page body
          body: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      /// initial loading
                      if (state.status == ChatStatus.loading &&
                          messages.isEmpty) {
                        return Center(
                          child: LoadingWidget(),
                        ); // shimmer effect messages
                      }

                      /// loaded
                      else {
                        /// No msgs
                        if (messages.isEmpty) {
                          return Center(
                            child: Text(
                              state.status == ChatStatus.success
                                  ? 'no msgs yet, start chatting!'
                                  : 'an error has occurred. sry',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          );
                        }

                        /// msgs present
                        else {
                          /// Refresh indicator
                          return CustomMaterialIndicator(
                            /// pull up to refresh:
                            trigger: IndicatorTrigger.leadingEdge,
                            leadingScrollIndicatorVisible: true,
                            trailingScrollIndicatorVisible: false,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,

                            /// the indicator
                            indicatorBuilder: (context, controller) {
                              return Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: CircularProgressIndicator(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  value: controller.state.isLoading
                                      ? null
                                      : min(controller.value, 1.0),
                                ),
                              );
                            },

                            /// refreshes
                            onRefresh: () async {
                              ChatCubit chatCubit = context.read<ChatCubit>();
                              chatCubit.fetchMessages(
                                  widget.chatRoom.contact.username);

                              await chatCubit.stream.firstWhere(
                                (state) =>
                                    state.status == ChatStatus.success ||
                                    state.status == ChatStatus.error,
                              );
                            },

                            /// Sliver list of messages
                            child: CustomScrollView(
                              reverse: true,
                              // Show latest messages at the bottom
                              slivers: [
                                SliverPadding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 8),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final message = messages[
                                            messages.length - index - 1];
                                        // Create a key for this message bubble to ensure it's unique
                                        final key = ValueKey(message.id);

                                        /// Create the message bubble
                                        final messageBubble = MessageBubble(
                                          key: key,
                                          message: message,
                                          onLongPress: () {
                                            /// currently only messages sent by contact
                                            if (!message.sentByUser) {
                                              _inputFocusNode.unfocus();

                                              _handleMessageLongPress(
                                                  messages.length - index - 1);
                                            }
                                          },
                                        );

                                        return messageBubble;
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
                    },
                  ),
                ),
              ),

              /// Text Input and action button
              /// (or accept request, if ChatStatus.requestedIn)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, left: 8.0, right: 8.0, bottom: 16.0),
                  child:

                      /// If the contact has requested to chat, show the accept button
                      widget.chatRoom.contact.friendStatus ==
                              FriendStatus.requestedIn
                          ? SizedBox(
                              width: double.infinity,
                              child: FloatingActionButton.extended(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                onPressed: () async {
                                  /// get chat cubit and add the contact as a new
                                  /// friend by username
                                  ChatCubit chatCubit =
                                      context.read<ChatCubit>();
                                  await chatCubit.addFriendByUsername(
                                      widget.chatRoom.contact.username);

                                  /// refresh chat room
                                  chatCubit.fetchMessages(
                                      widget.chatRoom.contact.username);

                                  // todo: use state mgmt and refresh page with bloc builder
                                  // if (context.mounted) {
                                  //   context.pop();
                                  // }
                                },
                                icon: Icon(
                                  Icons.check_circle_outline,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                label: Text(
                                  '<3 accept request <3',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            )

                          /// Otherwise show the text input and send button
                          : Row(
                              children: [
                                Expanded(
                                  child: ChatInputField(
                                      focusNode: _inputFocusNode,
                                      controller: _inputController,
                                      onChanged: (_) {
                                        setState(() {});
                                        debugPrint(_inputController.text);
                                      }),
                                ),
                                SizedBox(width: 8),
                                FloatingActionButton(
                                  onPressed: () async {
                                    final message =
                                        _inputController.text.trim();

                                    ChatCubit chatCubit =
                                        context.read<ChatCubit>();

                                    /// Send the message if just typed
                                    if (message.isNotEmpty) {
                                      // (and add to the state)
                                      setState(() {
                                        messages.add(Message(
                                          id: chatCubit.state.currentUser!.id,
                                          profileId: widget.chatRoom.contact.id,
                                          content: message,
                                          createdAt: DateTime.now(),
                                          sentByUser: true,
                                          generated: false,
                                          correctlyIdentified: null,
                                          sent: false,
                                        ));
                                      });

                                      await chatCubit.sendMessage(
                                        contactId: widget.chatRoom.contact.id,
                                        content: message,
                                      );

                                      _inputController.clear();
                                    }

                                    /// Send generation request
                                    else {
                                      debugPrint('Generate!');
                                      setState(() {
                                        _generateLoading = true;
                                      });

                                      chatCubit.sendGeneratedMessage(
                                          widget.chatRoom.contact.id);
                                    }

                                    /// and refresh

                                    await Future.delayed(Duration(seconds: 1));

                                    chatCubit.fetchMessages(
                                        widget.chatRoom.contact.username);

                                    setState(() {
                                      _generateLoading = false;
                                    });

                                    /// todo just set up realtime listener
                                  },
                                  child: _generateLoading
                                      ? LoadingWidget(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        )
                                      : Icon(
                                          _inputController.text.isEmpty
                                              ? Icons.psychology
                                              : Icons.send,
                                          size: Style.fabIconSize),
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

        // The blur/ fcs overlay
        const GameOverlay(),
      ],
    );
  }
}
