import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_api/supabase_api.dart';

import '../models/chat_room.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final AuthService _auth;
  final DatabaseService _db;

  ChatCubit(this._auth, this._db) : super(ChatInitial());


}
