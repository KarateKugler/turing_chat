import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotFoundException implements Exception {
  final String message;

  NotFoundException([this.message = 'Value not found']);

  @override
  String toString() => 'NotFoundException: $message';
}

class DatabaseService {
  final SupabaseClient _client; // maybe replace with client.from etc.

  DatabaseService(this._client);

  /// Get Username by UID
  Future<String> getUsername({required String id}) async {
    var response = await _client
        .from('profiles')
        .select('auth_id, username')
        .eq('auth_id', id)
        .single();
    return response['username'];
  }

  /// Add friend if username exists
  Future<void> addFriendByUsername(String userId, String friendUsername) async {
    var response = await _client
        .from('profiles')
        .select()
        .eq('username', friendUsername)
        .maybeSingle();

    /// Throw exception if username doesn't exist
    if (response == null) {
      throw NotFoundException('Username doesn\'t exist');
    }

    /// add contact to database
    await _client
        .from('friends')
        .insert({'user_id_1': userId, 'user_id_2': response['auth_id']});
  }

  Future<void> addFriendByUUID(String userId, String friendId) async {
    await _client
        .from('friends')
        .insert({'user_id_1': userId, 'user_id_2': friendId});
  }

  /// listen to messages in chat with email

  /// send message
}
