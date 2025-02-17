/// The Model which stores the contact information from supabase
/// Named ContactModel to prevent ambiguity with Contact class in Feature layer
class ContactModel {
  final bool friendRequestedIn;
  final bool friendRequestedOut;
  final bool blocked;
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
    required this.blocked,
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
      blocked: json['blocked'],
      contactId: json['contact_id'],
      username: json['username'],
      userScore: json['user_1_score'],
      contactScore: json['user_2_score'],
      userStreak: json['user_1_streak'],
      contactStreak: json['user_2_streak'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
