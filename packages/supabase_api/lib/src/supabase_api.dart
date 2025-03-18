import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_api_client.dart';

/// The service class for the supabase repository
class SupabaseApi {
  static late SupabaseApiClient
      _client; // late means we take responsibility from compiler for the status of the variable. We know it can only be set once so it is ok.

  /// Initialize the SupabaseApi
  ///
  /// Initializes Supabase and sets the SupabaseApiClient instance.
  /// This has to be called on app startup before using the client.
  static Future<void> initialize({
    required String supabaseUrl,
    required String anonKey,
  }) async {
    // retries connecting if timeout or other error.
    await Supabase.initialize(
        url: supabaseUrl,
        anonKey: anonKey,
        realtimeClientOptions: RealtimeClientOptions(
          // we don't need that many for message sending
          eventsPerSecond: 1,
        ));
    _client = SupabaseApiClient(Supabase.instance.client);
  }

  /// SupabaseApiClient getter
  ///
  /// Throws a [StateError] if the client has not been initialized
  static SupabaseApiClient get client {
    return _client;
  }
}
