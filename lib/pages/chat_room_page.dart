import 'package:flutter/material.dart';

class ChatRoomPage extends StatelessWidget {
  final String contactName;

  const ChatRoomPage({super.key, required this.contactName});

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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contactName),
        centerTitle: true,
      ),
      body: Placeholder(),
    );
  }
}
