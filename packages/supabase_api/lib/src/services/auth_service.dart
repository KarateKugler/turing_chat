import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoTrueClient _auth;

  AuthService(this._auth);

  Session? get currentSession => _auth.currentSession;

  Future<AuthResponse> refreshSession() async {
    return await _auth.refreshSession();
  }

  /// Sign in with E-Mail and password
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with E-Mail and password (phone is optional)
  Future<AuthResponse> signUpWithUsernameEmailPassword({
    required String username,
    required String email,
    required String password,
    String? phone,
  }) async {
    /// Send SignUp data to supabase with username metadata
    return await _auth.signUp(
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
