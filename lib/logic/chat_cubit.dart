import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_api/supabase_api.dart';
import 'package:turing_chat/models/contact.dart';
import 'package:turing_chat/models/settings.dart';

import '../models/chat_room.dart';
import '../models/message.dart';
import '../models/user.dart';

part 'chat_state.dart';

// todo: use hydrated cubit
class ChatCubit extends Cubit<ChatState> {
  final AuthService _auth;
  final DatabaseService _db;

  ChatCubit(this._auth, this._db)
      : super(ChatState(
          status: ChatStatus.initial,
          currentUser: null,
          chatroomsByUsername: {},
          userSettings: Settings(
            systemPrompt: '',
            promptUpdatedAt: DateTime.fromMicrosecondsSinceEpoch(0),
          ),
        ));

  /// Initialize the ChatCubit
  /// (only called if Authenticated, so active session is ensured)
  void init() async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final userData = _auth.userData!;
      final String userId = userData['id']!;

      /// Get username from database and create User model
      final username = await _db.getUsername(id: userId);
      final user = User(
        id: userId,
        email: userData['email']!,
        username: username,
        createdAt: DateTime.parse(userData['created_at']!),
      );

      final promptData = await _db.fetchSystemPrompt(userId);

      /// add to state
      emit(state.copyWith(
          currentUser: user,
          userSettings: Settings(
            systemPrompt: promptData['system_prompt'],
            promptUpdatedAt: DateTime.parse(promptData['prompt_created_at']),
          )));

      /// fetch contacts initially
      fetchContacts();
    }

    /// ...
    catch (e) {
      emit(
          state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
      debugPrint(e.toString());
    }
  }

  /// fetch/refrsh all cntcts.
  Future<void> fetchContacts() async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      /// we get the list of contacts
      List<ContactModel> contactData =
          await _db.fetchContacts(state.currentUser!.id);
      debugPrint(contactData.toString());

      /// ..
      Map<String, ChatRoom> chatrooms = {};
      for (ContactModel entry in contactData) {
        /// score, streak, contact data
        chatrooms[entry.username] = ChatRoom.fromContactModel(entry);
      }

      emit(state.copyWith(
        chatroomsByUsername: chatrooms,
        status: ChatStatus.success,
      ));
    }

    /// ...
    catch (e) {
      emit(
          state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
      debugPrint(e.toString());
    }
  }

  /// Add a new friend by username
  Future<void> addFriendByUsername(String friendUsername) async {
    /// Try finding by username and adding
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      if (state.currentUser == null) {
        emit(state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'No authenticated user found',
        ));
        return;
      }

      String friendId =
          await _db.addFriendByUsername(state.currentUser!.id, friendUsername);

      ChatRoom? chatroom = state.chatroomsByUsername[friendUsername];

      /// if this works, two possiblities:

      /// this is a new contact, and the user just sent a friend request
      if (chatroom == null) {
        ChatRoom newChatroom = ChatRoom(
          contact: Contact(
            id: friendId,
            email: null,
            username: friendUsername,
            friendsSince: DateTime.now(),
            contactStatus: ContactStatus.requestedOut,
          ),
          messages: [],
          userScore: 0,
          userStreak: 0,
          contactScore: 0,
          contactStreak: 0,
        );
        state.chatroomsByUsername.addAll({friendUsername: newChatroom});
      }

      /// the user just accepted a friend request
      else {
        /// update contact status
        state.chatroomsByUsername[friendUsername] = state
            .chatroomsByUsername[friendUsername]!
            .copyWithUpdatedContactStatus(ContactStatus.friend);
      }

      emit(state.copyWith(status: ChatStatus.success));

      // todo: add more logic for case of contact being blocked or reported
    }

    /// Error if username was not found
    on NotFoundException {
      emit(state.copyWith(errorMessage: 'username not found'));
    }

    /// other error
    catch (e) {
      emit(state.copyWith(errorMessage: 'unexpected error occured: $e'));
    }
  }

  /// emit a chat error state directly
  void chatError(String errorMessage) {
    emit(state.copyWith(status: ChatStatus.error, errorMessage: errorMessage));
  }

  /// send a message to a contact
  Future<void> sendMessage({
    required String contactId,
    required String content,
  }) async {
    User user = state.currentUser!;

    ///
    try {
      _db.sendMessage(
        userId: user.id,
        contactId: contactId,
        content: content,
      );
    }

    ///
    catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// request a generated message and send to a contact

  /// fetch/refresh msgs for one contact
  Future<void> fetchMessages(String contactName) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      List<MessageModel> messageData = await _db.fetchMessages(
          userId: state.currentUser!.id,
          contactId: state.chatroomsByUsername[contactName]!.contact.id);

      state.chatroomsByUsername[contactName]!.messages.clear();
      state.chatroomsByUsername[contactName]!.messages.addAll(
          messageData.map((e) => Message.fromModel(e, state.currentUser!.id)));

      emit(state.copyWith(status: ChatStatus.success));
    } catch (e) {
      debugPrint(e.toString());
      emit(
          state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
    }
  }
}
