
/// The possible states of the contact relationship
enum ContactStatus {
  requestedOut,
  requestedIn,
  friend,
  blocked,
  reported,
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
}
