import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_api/supabase_api.dart';
import 'package:turing_chat/helpers/auth_utils.dart';
import '../logic/chat_cubit.dart';
import 'loading_widget.dart';

import '../logic/auth_cubit.dart';
import 'text_field_dialog.dart';

class AddFriendButton extends StatefulWidget {
  const AddFriendButton({
    super.key,
  });

  @override
  State<AddFriendButton> createState() => _AddFriendButtonState();
}

class _AddFriendButtonState extends State<AddFriendButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        /// Add a new Chat Room per username
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return TextFieldDialog(
              /// Check if username is valid (..)
              validator: (submitText) => validateUsername(submitText.trim()),
              errorHint: 'invalid username',
              onSubmitted: (submitText) async {
                /// Try adding friend by username (..)
                setState(() {
                  isLoading = true;
                });

                ChatCubit chatCubit = context.read<ChatCubit>();
                AuthCubit authCubit = context.read<AuthCubit>();
                AuthState authState = authCubit.state;

                try {
                  if (authState is AuthLoggedIn) {
                    String userId = authState.user.id;
                    chatCubit.addFriendByUsername(userId, submitText.trim());
                  }
                }

                /// if the user doesn't exist,
                on NotFoundException catch (e) {
                  chatCubit.chatError(e.message);
                }

                catch (e) {
                  chatCubit.chatError(e.toString());
                }

                /// if no show snack bar

                setState(() {
                  isLoading = false;
                });
              },
              titleText: 'add a friend',
              hintText: 'username_001',
              submitText: 'add',
            );
          },
        );
      },

      /// Show a circular progress indicator after pressed
      child: isLoading ? LoadingWidget() : Icon(Icons.add_circle_outline),
    );
  }
}
