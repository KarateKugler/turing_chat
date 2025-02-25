part of 'chat_cubit.dart';

/// The possible states of the chats feature
enum ChatStatus {
  initial,
  loading,
  success,
  error,
}

@immutable
final class ChatState {
  /// The current state of the chats
  final ChatStatus status;
  /// The currently logged in user
  final User? currentUser;
  /// The complete list of chatrooms by username and the associated contacts,
  /// whether they are friends, requested friends, blocked or otherwise.
  final Map<String, ChatRoom> chatroomsByUsername; // could add separate list of contacts, but introduces more room for error
  final String? errorMessage;

  const ChatState({
    required this.status,
    this.currentUser,
    required this.chatroomsByUsername,
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    User? currentUser,
    Map<String, ChatRoom>? chatroomsByUsername,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      chatroomsByUsername: chatroomsByUsername ?? this.chatroomsByUsername,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    String chatroomsString = '';

    if (chatroomsByUsername.isNotEmpty) {
      for (String username in chatroomsByUsername.keys) {
        chatroomsString += 'ChatRoom(user: $username), ';
      }
    }
    chatroomsString = '[$chatroomsString]';

    return 'ChatState($status, error: $errorMessage, $chatroomsString)';
  }
}
