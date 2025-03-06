import 'package:supabase_api/src/models/contact_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';

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

  /// Add friend if username exists (and return friendId)
  Future<String> addFriendByUsername(
      String userId, String friendUsername) async {
    /// try to get user profile
    var response = await _client
        .from('profiles')
        .select('username, auth_id')
        .eq('username', friendUsername)
        .maybeSingle();

    /// Throw exception if username doesn't exist
    if (response == null) {
      throw NotFoundException('Username doesn\'t exist');
    }

    /// add contact to database
    await _client
        .from('contacts')
        .insert({'sender_id': userId, 'receiver_id': response['auth_id']});

    return response['auth_id'];
  }

  /// Add a friend by UserID (for accepting pending friend requests)
  Future<void> addFriendByUUID(String userId, String friendId) async {
    await _client
        .from('contacts')
        .insert({'user_id_1': userId, 'user_id_2': friendId});
  }

  /// Fetch all contacts
  Future<List<ContactModel>> fetchContacts(String userId) async {
    /// Mutuals (Friend out and Friend in)
    List? response =
        await _client.rpc('get_mutuals', params: {'user_id': userId});

    List<ContactModel> contactsMutual = response
            ?.map((entry) => ContactModel.fromJson(
                json: entry, friendIn: true, friendOut: true))
            .toList() ??
        [];

    /// Outgoing friend requests (but not accepted)
    response =
        await _client.rpc('get_contacts_out', params: {'user_id': userId});

    List<ContactModel> contactsOut = response
            ?.map((entry) => ContactModel.fromJson(
                json: entry, friendIn: false, friendOut: true))
            .toList() ??
        [];

    /// Ingoing friend requests (but not accepted)
    response =
        await _client.rpc('get_contacts_in', params: {'user_id': userId});

    List<ContactModel> contactsIn = response
            ?.map((entry) => ContactModel.fromJson(
                json: entry, friendIn: true, friendOut: false))
            .toList() ??
        [];

    /// combine
    List<ContactModel> contacts = [
      ...contactsMutual,
      ...contactsIn,
      ...contactsOut
    ];

    return contacts;
  }

  /// fetch messages for a chat room initially.

  /// listen to messages in chat with email

  /// send message
  ///
  /// todo: enable sending null, to show '...' writing in progress (idea)
  /// -> (returns Future<String> of message id and then override when actually sending)
  Future<void> sendMessage({
    required String userId,
    required String contactId,
    required String content,
  }) async {
    /// Try sending
    try {
      await _client.from('messages').insert({
        'sender_id': userId,
        'receiver_id': contactId,
        'content': content,
        'generated': false,
        'identified': null,
      });
    } catch (e) {
      // todo handle specific error types
      rethrow;
    }
  }

  /// generate message
// todo
}
