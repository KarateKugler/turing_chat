/// The Model which stores the contact information from supabase
/// Named ContactModel to prevent ambiguity with Contact class in Feature layer
class ContactModel {
  final bool friendRequestedIn;
  final bool friendRequestedOut;
  final bool blockedIn;
  final bool blockedOut;
  final String contactId;
  final String username;
  final int userScore;
  final int contactScore;
  final int userStreak;
  final int contactStreak;
  final DateTime createdAt;

  ContactModel({
    required this.friendRequestedIn,
    required this.friendRequestedOut,
    required this.blockedIn,
    required this.blockedOut,
    required this.contactId,
    required this.username,
    required this.userScore,
    required this.contactScore,
    required this.userStreak,
    required this.contactStreak,
    required this.createdAt,
  });

  static ContactModel fromJson({
    required Map<String, dynamic> json,
    required bool friendIn,
    required bool friendOut,
  }) {
    return ContactModel(
      friendRequestedIn: friendIn,
      friendRequestedOut: friendOut,
      blockedIn: json['blocked_in'] ?? false,
      blockedOut: json['blocked_out'] ?? false,
      contactId: json['contact_id'],
      username: json['username'],
      userScore: json['sender_score'] ?? 0,
      contactScore: json['sender_streak'] ?? 0,
      userStreak: json['receiver_score'] ?? 0,
      contactStreak: json['receiver_streak'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  String toString() {
    return 'ContactModel{friendRequestedIn: $friendRequestedIn, friendRequestedOut: $friendRequestedOut, blockedIn: $blockedIn, blockedOut: $blockedOut, contactId: $contactId, username: $username, userScore: $userScore, contactScore: $contactScore, userStreak: $userStreak, contactStreak: $contactStreak, createdAt: $createdAt}';
  }
}
