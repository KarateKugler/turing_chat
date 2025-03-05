import 'package:supabase_api/supabase_api.dart';

/// The possible states of the contact relationship
enum ContactStatus {
  requestedOut,
  requestedIn,
  friend,
  blockedIn,
  blockedOut,
  error;

  static ContactStatus fromFlags({
    required bool blockedIn,
    required bool blockedOut,
    required bool friendIn,
    required bool friendOut,
  }) {
    if (blockedOut) {
      return ContactStatus.blockedOut;
    }

    if (blockedIn) {
      return ContactStatus.blockedIn;
    }

    if (friendIn && friendOut) {
      return ContactStatus.friend;
    }

    if (friendIn) {
      return ContactStatus.requestedIn;
    }

    if (friendOut) {
      return ContactStatus.requestedOut;
    }

    return ContactStatus.error;
  }
}

class Contact {
  final String id;
  final String? email;
  final String username;

  /// The DateTime at which the friend request was accepted
  final DateTime friendsSince;

  /// The status of the contact relationship
  final ContactStatus contactStatus;

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
    ContactStatus? contactStatus,
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
        contactStatus: ContactStatus.fromFlags(
            blockedIn: data.blockedIn,
            blockedOut: data.blockedOut,
            friendIn: data.friendRequestedIn,
            friendOut: data.friendRequestedOut));
  }
}
