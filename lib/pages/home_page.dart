import 'dart:math';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:turing_chat/logic/auth_cubit.dart';
import 'package:turing_chat/logic/chat_cubit.dart';
import 'package:turing_chat/widgets/contact_tile.dart';

import '../models/chat_room.dart';
import '../models/message.dart';
import '../widgets/add_friend_button.dart';
import '../widgets/home_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// refresh contacts
  Future<void> _onRefresh() async {
    ChatCubit chatCubit = context.read<ChatCubit>();
    await chatCubit.fetchContactsAndChannels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),
      appBar: AppBar(
        title: Text('⌘ turing_chat ⍜'),
        centerTitle: true,
      ),
      // do multi bloc listener
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {},
          ),
          BlocListener<ChatCubit, ChatState>(
            listener: (context, state) {
              if (state.status == ChatStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage ?? '')));
              }
            },
          ),
        ],
        child: Stack(children: [
          BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (previous, current) => true,
            builder: (context, state) {
              // todo: build when contact status changed.
              debugPrint(state.toString()); //todo rmv
              return CustomMaterialIndicator(
                onRefresh: _onRefresh,

                /// pull down to refresh:
                trigger: IndicatorTrigger.leadingEdge,
                leadingScrollIndicatorVisible: true,
                trailingScrollIndicatorVisible: false,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                //todo: prim?

                /// the indicator
                indicatorBuilder: (context, controller) {
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      value: controller.state.isLoading
                          ? null
                          : min(controller.value, 1.0),
                    ),
                  );
                },
                child: ListView.builder(
                  itemCount: state.chatroomsByUsername.length,
                  itemBuilder: (context, index) {
                    MapEntry<String, ChatRoom> entry =
                        state.chatroomsByUsername.entries.elementAt(index);

                    print(entry.value.contact.onlineStatus);

                    // Get the last message if there are any messages
                    String? lastMessage;
                    bool isLastMessageFromUser = false;
                    
                    if (entry.value.messages.isNotEmpty) {
                      Message message = entry.value.messages.last;
                      lastMessage = message.content;
                      isLastMessageFromUser = message.sentByUser;
                    }

                    /// The List of Chat Rooms with Friends
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ContactTile(
                        contactName: entry.key,
                        contactId: entry.value.contact.id,
                        friendStatus: entry.value.contact.friendStatus,
                        onTap: () {
                          // emit ChatRoomState
                          context.read<ChatCubit>().openChatRoom(entry.key);

                          // Navigate to chat room with the chatroom data
                          context.push('/chat/${entry.value.contact.id}',
                              extra: entry.value);
                        },
                        onlineStatus: entry.value.contact.onlineStatus,
                        lastMessage: lastMessage,
                        isLastMessageFromUser: isLastMessageFromUser,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              return Container();
            },
          )
        ]),
      ),
      floatingActionButton: const AddFriendButton(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// initialize the chat cubit if logged in
    AuthCubit authCubit = context.read<AuthCubit>();
    AuthState authState = authCubit.state;

    /// If not logged in, something went wrong
    if (authState is AuthLoggedIn) {
      context.read<ChatCubit>().init();

      // If not logged in, redirect to login
    } else {
      context.go('/login');
    }
  }
}
