import 'package:supabase_api/supabase_api.dart';

import 'contact.dart';
import 'message.dart';

class ChatRoom {
  /// The contact of the user
  final Contact contact;
  final List<Message> messages;

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

  ChatRoom copyWith({
    Contact? contact,
    int? userScore,
    int? userStreak,
    int? contactScore,
    int? contactStreak,
  }) {
    return ChatRoom(
      contact: contact ?? this.contact,
      messages: messages,
      userScore: userScore ?? this.userScore,
      userStreak: userStreak ?? this.userStreak,
      contactScore: contactScore ?? this.contactScore,
      contactStreak: contactStreak ?? this.contactStreak,
    );
  }

  /// only update the contact status
  ChatRoom copyWithUpdatedContactStatus(ContactStatus contactStatus) {
    return ChatRoom(
      contact: contact.copyWith(contactStatus: contactStatus),
      messages: messages,
      userScore: userScore,
      userStreak: userStreak,
      contactScore: contactScore,
      contactStreak: contactStreak,
    );
  }

  // todo scrap later
  static ChatRoom fromContactModel(ContactModel data) {
    return ChatRoom(
      contact: Contact.fromModel(data),
      messages: [],
      userScore: data.userScore,
      userStreak: data.userStreak,
      contactScore: data.contactScore,
      contactStreak: data.contactStreak,
    );
  }
}
