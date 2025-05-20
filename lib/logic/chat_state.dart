part of 'chat_cubit.dart';

/// The possible states of the chats feature
enum ChatStatus {
  initial,
  loading,
  success,
  chatroom,
  messageSelected,
  error,
}

/// The main state for the chat feature, with all chatrooms
@immutable
final class ChatState {
  /// The current state of the chats
  final ChatStatus status;

  /// The currently logged in user
  final User? currentUser;

  /// The complete list of chatrooms by username and the associated contacts,
  /// whether they are friends, requested friends, blocked or otherwise.
  // could add separate list of contacts, but introduces more room for error
  // would have to set with Map.unmodifiable() if we want true immutable state
  // -> maybe ask in bloc discord
  final Map<String, ChatRoom> chatroomsByUsername;

  /// The customizable system prompt for sending generated messages
  final Settings userSettings;

  final String? errorMessage;

  /// The contact of the currently selected chatroom if any
  /// '' if none
  final String chatroomContactUsername;

  /// if in a chatroom the currently selected message
  /// -1 if none
  final int selectedMessageIndex;

  const ChatState({
    required this.status,
    this.currentUser,
    required this.chatroomsByUsername,
    required this.userSettings,
    this.errorMessage,
    required this.chatroomContactUsername,
    required this.selectedMessageIndex,
  });

  ChatState copyWith({
    ChatStatus? status,
    User? currentUser,
    Map<String, ChatRoom>? chatroomsByUsername,
    Settings? userSettings,
    String? errorMessage,
    String? chatroomContactUsername,
    int? selectedMessageIndex,
  }) {
    return ChatState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      chatroomsByUsername: chatroomsByUsername ?? this.chatroomsByUsername,
      userSettings: userSettings ?? this.userSettings,
      errorMessage: errorMessage,
      chatroomContactUsername:
          chatroomContactUsername ?? this.chatroomContactUsername,
      selectedMessageIndex: selectedMessageIndex ?? this.selectedMessageIndex,
    );
  }

  static ChatState initial = ChatState(
    status: ChatStatus.initial,
    currentUser: null,
    chatroomsByUsername: {},
    userSettings: Settings(
      systemPrompt: '',
      promptUpdatedAt: DateTime.fromMicrosecondsSinceEpoch(0),
    ),
    chatroomContactUsername: '',
    selectedMessageIndex: -1,
  );

  /// for dbg
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
