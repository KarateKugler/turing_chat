import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/auth_service.dart';
import 'services/database_service.dart';

/// The custom API Client which is provided to the widget tree
/// and holds the various services:
///
/// * [AuthService]
/// * [DatabaseService]
class SupabaseApiClient {
  final SupabaseClient client;
  late final AuthService _authService;
  late final DatabaseService _databaseService;

  SupabaseApiClient(this.client) {
    _authService = AuthService(client.auth);
    _databaseService = DatabaseService(client);
  }

  AuthService get authService => _authService;
  DatabaseService get databaseService => _databaseService;
}
