import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turing_chat/logic/auth_cubit.dart';
import 'package:turing_chat/logic/chat_cubit.dart';
import 'package:turing_chat/widgets/contact_tile.dart';

import '../models/chat_room.dart';
import '../widgets/add_friend_button.dart';
import '../widgets/home_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .surface,
      drawer: HomeDrawer(),
      appBar: AppBar(
        title: Text('⌘  t u r i n g . c h a t  ⍜'),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {},
        child: Stack(children: [
          BlocConsumer<ChatCubit, ChatState>(
            listener: (context, state) {
              if (state.status == ChatStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage ?? '')));
              }
            },
            builder: (context, state) {
              debugPrint(state.toString());
              return ListView.builder(
                itemCount: state.chatroomsByUsername.length,

                itemBuilder: (context, index) {
                  MapEntry<String, ChatRoom> entry = state.chatroomsByUsername
                      .entries.elementAt(index);

                  /// The List of Chat Rooms with Friends
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ContactTile(
                      text: entry.key,
                      onTap: () {

                      },
                    ),
                  );
                },
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

    /// initialize the chat cubit with the user model from authstate
    AuthCubit authCubit = context.read<AuthCubit>();
    AuthState authState = authCubit.state;

    /// If not logged in, something went wrong
    if (authState is AuthLoggedIn) {
      ChatCubit chatCubit = context.read<ChatCubit>();
      chatCubit.init(user: authState.user);

      // authCubit.authError(
      //     'there was an error with the authentication. try logging in again.');
      // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false,);
      // return;
    }
  }
}
