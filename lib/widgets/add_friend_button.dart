import 'package:flutter/material.dart';
import 'package:turing_chat/widgets/loading_widget.dart';

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
              onSubmitted: () async {
                /// Check if username exists and show loading icon
                setState(() {
                  isLoading = true;
                });



                /// If yes add to chats


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
