import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';
import '../models/models.dart';

class DatabaseService {
  final SupabaseClient _client; // maybe replace with client.from etc.
  final Map<String, RealtimeChannel> _channels;

  DatabaseService(this._client)
      : _channels = {
          'online-status': _client.channel(
            'online-status',
            opts: const RealtimeChannelConfig(private: true),
          )
        };

  /// /////////////////////////////////
  /// realtime

  /// online status
  Future<void> initStatusPresence(String username) async {
    // testing
    _channels['online-status']!.onPresenceSync((payload) {
      final newState = _channels['online-status']!.presenceState();
      print('sync: $newState (payload: $payload)');
    }).onPresenceJoin((payload) {
      print('join: $payload');
    }).onPresenceLeave((payload) {
      print('leave: $payload');
    }).subscribe((status, error) async {
      if (status != RealtimeSubscribeStatus.subscribed) return;

      final presenceTrackStatus = await _channels['online-status']!.track(
          {
            'user': username,
            'online_at': DateTime.now().toIso8601String(),
          }
      );
      print(presenceTrackStatus);
    },);
  }


  /// /////////////////////////////////
  ///   PROFILE AND CONTACTS

  /// Get Username by UID

  Future<String> getUsername({required String id}) async {
    var response = await _client
        .from('profiles')
        .select('auth_id, username')
        .eq('auth_id', id)
        .single();
    return response['username'];
  }

  /// Add friend if username exists (returns friendId)

  Future<String> addFriendByUsername(
      String userId, String friendUsername) async {
    // try to get user profile
    var response = await _client
        .from('profiles')
        .select('username, auth_id')
        .eq('username', friendUsername)
        .maybeSingle();

    // Throw exception if username doesn't exist
    if (response == null) {
      throw NotFoundException('Username doesn\'t exist');
    }

    // add contact to database
    await _client
        .from('contacts')
        .insert({'sender_id': userId, 'receiver_id': response['auth_id']});

    return response['auth_id'];
  }

  /// Add a friend by UserID (/accept pending request)

  Future<void> addFriendByUUID(String userId, String friendId) async {
    await _client
        .from('contacts')
        .insert({'user_id_1': userId, 'user_id_2': friendId});
  }

  /// Fetch all contacts

  Future<List<ContactModel>> fetchContacts(String userId) async {
    // Mutuals (Friend out and Friend in)
    List? response =
        await _client.rpc('get_mutuals', params: {'user_id': userId});

    List<ContactModel> contactsMutual = response
            ?.map((entry) => ContactModel.fromJson(
                json: entry, friendIn: true, friendOut: true))
            .toList() ??
        [];

    // Outgoing friend requests (but not accepted)
    response =
        await _client.rpc('get_contacts_out', params: {'user_id': userId});

    List<ContactModel> contactsOut = response
            ?.map((entry) => ContactModel.fromJson(
                json: entry, friendIn: false, friendOut: true))
            .toList() ??
        [];

    // Ingoing friend requests (but not accepted)
    response =
        await _client.rpc('get_contacts_in', params: {'user_id': userId});

    List<ContactModel> contactsIn = response
            ?.map((entry) => ContactModel.fromJson(
                json: entry, friendIn: true, friendOut: false))
            .toList() ??
        [];

    // combine
    List<ContactModel> contacts = [
      ...contactsMutual,
      ...contactsIn,
      ...contactsOut
    ];

    return contacts;
  }

  /// /////////////////////////////////
  ///   MESSAGES

  /// fetch all messages for a chat room.
// maybe invert, and get latest msgs first, then invert rendering in chatroom page
// (so that not all msgs have to be loaded for large chat rooms)
  Future<List<MessageModel>> fetchMessages({
    required String userId,
    required String contactId,
  }) async {
    try {
      List<Map<String, dynamic>> response = await _client.rpc('get_messages',
          params: {'user_id': userId, 'contact_id': contactId});

      return response.map((e) => MessageModel.fromJson(e)).toList();
    }

    ///
    catch (e) {
      // todo handle specific error types
      rethrow;
    }
  }

  /// set up realtime channel w contact name
  Future<void> addChannel({
    required String username,
    required String contactName,
  }) async {
    _channels[contactName] = _client.channel(
      _getChannelName(username: username, contactName: contactName),
      opts: const RealtimeChannelConfig(private: true),
    );
  }

  /// send message
  ///
  /// todo: (idea) enable sending null, to show '...' writing in progress
  /// -> (returns Future<String> of message id and then override when actually sending)

  Future<void> sendMessage({
    required String userId,
    required String contactId,
    required String content,
  }) async {
    /// Try sending
    try {
      await _client.rpc('insert_message', params: {
        'sender_id': userId,
        'receiver_id': contactId,
        'content': content,
        'generated': false,
      });
    } catch (e) {
      // todo handle specific error types
      rethrow;
    }
  }

  /// generate message
  Future<void> sendGeneratedMessage({
    required String userId,
    required String contactId,
  }) async {
    /// Try sending
    try {
      await _client.rpc('send_generated_chat_message', params: {
        'user_id': userId,
        'contact_id': contactId,
      });
    } catch (e) {
      // todo handle specific error types
      rethrow;
    }
  }

  /// /////////////////////////////////
  ///   GENERATION SETTINGS

  /// fetch system prompt
  Future<Map<String, dynamic>> fetchSystemPrompt(String userId) async {
    /// ...
    try {
      var result = await _client
          .from('settings')
          .select('system_prompt, prompt_created_at')
          .eq('user_id', userId)
          .single();

      return result;
    }

    /// ...
    catch (e) {
      rethrow;
    }
  }

  /// update system prompt
  Future<void> updateSystemPrompt(
      {required String userId, required String prompt}) async {
    ///
    try {
      await _client
          .rpc('update_prompt', params: {'id': userId, 'prompt': prompt});
    }

    ///
    catch (e) {
      rethrow;
    }
  }

  /// reset system prompt
  Future<void> resetSystemPrompt(String userId) async {
    ///
    try {
      await _client
          .rpc('update_prompt', params: {'id': userId, 'prompt': null});
    }

    ///
    catch (e) {
      rethrow;
    }
  }

  /// /////////////////////
  /// helpers

  /// get the ordered channel name from the user names

  String _getChannelName({
    required String username,
    required String contactName,
  }) {
    List<String> names = [username, contactName];
    names.sort((a, b) {
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    return names.join('-');
  }
}
