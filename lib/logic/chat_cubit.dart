import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:supabase_api/supabase_api.dart';
import 'package:turing_chat/models/contact.dart';

import '../models/chat_room.dart';
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
        ));

  /// Initialize the ChatCubit
  /// (only called if Authenticated, so current session is ensured)
  void init() async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final currentUser = _auth.currentSession!.user;

      // Get username from database and create User model
      final username = await _db.getUsername(id: currentUser.id);
      final user = User(
        id: currentUser.id,
        email: currentUser.email!,
        username: username,
        createdAt: DateTime.parse(currentUser.createdAt),
      );

      /// we get the list of contacts
      List<ContactModel> contactData = await _db.fetchContacts(user.id);
      debugPrint(contactData.toString());

      /// get chatroom list with contacts, scores and streaks and emit if it worked
      // todo: also get messages

      Map<String, ChatRoom> chatrooms = {};
      for (ContactModel entry in contactData) {
        chatrooms[entry.username] = ChatRoom.fromContactModel(entry);
      }

      emit(state.copyWith(
        currentUser: user,
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
    on NotFoundException catch (e) {
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
}
