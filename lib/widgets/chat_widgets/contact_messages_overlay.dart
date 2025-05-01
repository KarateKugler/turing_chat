import 'package:flutter/material.dart';



/// The multi message overlay for selecting a contact's message
///
/// Is used for replying/ guessing generated for the contact.
/// It implements a queue for the message List. So we might have to add
/// some new logic for for the enqueue(), dequeue() and so on.
/// On open the multiple messages are displayed in a staggered animation.
/// When a message is guessed, it will display some indicator for the guess (correct/incorrect)
/// Then it will slide to the side and disappear with an animation.
/// Then the remaining messages will slide down and a new message is added to the top/end of the queue.
///
///
///
/// And shows two buttons for the following actions:
///   - reply
///   - guess generated
///
/// (if we guess generated,
///
/// (so it builds a GameOverlay, gives it the messageBubble,
///   the List<Widget> for the actions,
///   and specifies the animation it wants for the messageBubble.
class ContactMessagesOverlay extends StatelessWidget {
  const ContactMessagesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
