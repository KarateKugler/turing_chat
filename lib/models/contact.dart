import 'package:supabase_api/supabase_api.dart';

/// The possible states of the contact relationship
enum FriendStatus {
  requestedOut,
  requestedIn,
  friend,
  blockedIn,
  blockedOut,
  error;

  static FriendStatus fromFlags({
    required bool blockedIn,
    required bool blockedOut,
    required bool friendIn,
    required bool friendOut,
  }) {
    if (blockedOut) {
      return FriendStatus.blockedOut;
    }

    if (blockedIn) {
      return FriendStatus.blockedIn;
    }

    if (friendIn && friendOut) {
      return FriendStatus.friend;
    }

    if (friendIn) {
      return FriendStatus.requestedIn;
    }

    if (friendOut) {
      return FriendStatus.requestedOut;
    }

    return FriendStatus.error;
  }
}

class Contact {
  final String id;
  final String? email;
  final String username;

  /// The DateTime at which the friend request was accepted
  final DateTime friendsSince;

  /// The status of the contact relationship
  final FriendStatus contactStatus;

  Contact({
    required this.id,
    required this.email,
    required this.username,
    required this.friendsSince,
    required this.contactStatus,
  });

  Contact copyWith({
    String? id,
    String? email,
    String? username,
    DateTime? friendsSince,
    FriendStatus? contactStatus,
  }) {
    return Contact(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      friendsSince: friendsSince ?? this.friendsSince,
      contactStatus: contactStatus ?? this.contactStatus,
    );
  }

  static Contact fromModel(ContactModel data) {
    return Contact(
        id: data.contactId,
        email: null,
        username: data.username,
        friendsSince: data.createdAt,
        contactStatus: FriendStatus.fromFlags(
            blockedIn: data.blockedIn,
            blockedOut: data.blockedOut,
            friendIn: data.friendRequestedIn,
            friendOut: data.friendRequestedOut));
  }
}
