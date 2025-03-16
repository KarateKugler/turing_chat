import 'dart:math';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turing_chat/models/contact.dart';
import 'package:turing_chat/widgets/chat_input_field.dart';
import 'package:turing_chat/widgets/loading_widget.dart';

import '../logic/chat_cubit.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../theme/style.dart';
import '../widgets/game_overlay.dart';
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
  /// Text Input
  late final TextEditingController _inputController;
  final FocusNode _inputFocusNode = FocusNode();

  /// generation
  bool _generateLoading = false;

  /// Selecting a message
  Message? _selectedMessage;
  Widget? _selectedMessageBubble;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ChatCubit chatCubit = context.read<ChatCubit>();
    chatCubit.fetchMessages(widget.chatRoom.contact.username);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  /// msg bubble

  void _handleMessageLongPress(Message message, Widget messageBubble) {
    setState(() {
      _selectedMessage = message;
      _selectedMessageBubble = messageBubble;
    });
  }

  /// blur wgt funcs

  void _handleTapOutside() {
    setState(() {
      _selectedMessage = null;
      _selectedMessageBubble = null;
    });
  }

  void _handleExposeAction() {
    // This would be implemented to handle the "Expose" action
    // For now, just dismiss the blur
    _handleTapOutside();

    // In a real implementation, you would:
    // 1. Send a request to the backend to check if the message was generated
    // 2. Update the UI based on the response
    // 3. Update scores, etc.
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

          /// Page body
          body: Column(
            children: [
              /// Sliver list of messages
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
                                            _inputFocusNode.unfocus();

                                            _handleMessageLongPress(
                                              message,
                                              MessageBubble(message: message),
                                            );
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
                      widget.chatRoom.contact.contactStatus ==
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
                                  chatCubit.init();

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

                                    await Future.delayed(
                                        Duration(seconds: 1));

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
        GameOverlay(
          messageBubble: _selectedMessageBubble,
          onAction: _handleExposeAction,
        ),
      ],
    );
  }
}
