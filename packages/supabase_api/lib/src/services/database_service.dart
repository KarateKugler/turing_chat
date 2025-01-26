import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client; // maybe replace with client.from etc.

  DatabaseService(this._client);

  /// Get Username by UID
  Future<String> getUsername({required String id}) async {
    var response = await _client.from('profiles').select('username').eq('user_id', id).maybeSingle();
    return response!['username'];
  }
  
  /// Add friend if email exists
  Future<void> addFriend(String userEmail, String friendEmail) async {
    await _client.from('friends').insert({'user_email': userEmail, 'friendEmail': friendEmail});
  }

  /// listen to messages in chat with email
  

  /// send message

  ///
}
