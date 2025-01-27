import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_api/supabase_api.dart';

import '../models/chat_room.dart';

part 'chat_state.dart';

// todo: use hydrated cubit
class ChatCubit extends Cubit<ChatState> {
  final AuthService _auth;
  final DatabaseService _db;

  ChatCubit(this._auth, this._db)
      : super(ChatState(
          status: ChatStatus.initial,
          chatroomsByUsername: {},
        ));

  /// Initialize the ChatCubit with the [User] Model from auth
  void init({required User user}) async {
    /// ...
    emit(state.copyWith(status: ChatStatus.loading));

    try {
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
          chatroomsByUsername: chatrooms, status: ChatStatus.success));
    }

    /// ...
    catch (e) {
      emit(
          state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
      debugPrint(e.toString());
    }
  }

  /// Add a new friend by username
  Future<void> addFriendByUsername(String userId, String friendUsername) async {
    /// Try finding by username and adding
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      String friendId = await _db.addFriendByUsername(userId, friendUsername);

}
