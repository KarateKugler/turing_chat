import 'contact.dart';
import 'message.dart';

class ChatRoom {
  /// The contact of the user
  final Contact contact;
  final List<Message>? messages;

  /// How many points the user has scored
  final int userScore;

  /// The Streak of the user
  final int userStreak;

  /// How many points the friend has scored
  final int contactScore;

  /// The Streak of the contact
  final int contactStreak;

  ChatRoom({
    required this.contact,
    required this.messages,
    required this.userScore,
    required this.userStreak,
    required this.contactScore,
    required this.contactStreak,
  });
}
