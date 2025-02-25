import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoTrueClient _auth;

  AuthService(this._auth);

  bool get sessionActive => _auth.currentSession != null;

  /// returns true if session is null
  bool get sessionExpired => _auth.currentSession?.isExpired ?? true;

  // artifact of not using a repository layer, just deal with it
  /// Returns the raw user data of the current session:
  ///
  /// e.g.
  /// ```dart
  /// {
  ///  'id': '1234-5678-9012-3456',
  ///  'email': '
  ///  'created_at': '2021-09-01T12:00:00.000Z'
  /// }
  /// ```
  /// or null if no session is active
  Map<String, dynamic>? get userData => _auth.currentSession != null
      ? {
          'id': _auth.currentUser!.id,
          'email': _auth.currentUser!.email,
          'created_at': _auth.currentUser!.createdAt
        }
      : null;

  Future<void> refreshSession() async {
    AuthResponse response = await _auth.refreshSession();
  }

  /// Sign in with E-Mail and password
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    AuthResponse response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with E-Mail and password (phone is optional)
  Future<void> signUpWithUsernameEmailPassword({
    required String username,
    required String email,
    required String password,
    String? phone,
  }) async {
    /// Send SignUp data to supabase with username metadata
    AuthResponse response = await _auth.signUp(
      email: email,
      password: password,
      phone: phone,
      data: {'username': username},
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// delete account
  Future<void> deleteAccount() async {
    // todo
  }

  /// Get user Email
  String? getCurrentUserEmail() {
    final session = _auth.currentSession;
    final user = session?.user;

    return user?.email;
  }

  /// Get user Phone
  String? getCurrentUserPhone() {
    final session = _auth.currentSession;
    final user = session?.user;

    return user?.phone;
  }
}
