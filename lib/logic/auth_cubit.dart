import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_api/supabase_api.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';

part 'auth_state.dart';

/// The Cubit that is responsible for managing the basic authentication state
/// of the app, i.e. whether the user is logged in or not.
/// (Mainly responsible for gating the home page and handling sign in/sign up
/// /sign out tasks etc. Shouldn't be called for getting the user id or user
/// name)
class AuthCubit extends Cubit<AuthState> {
  final AuthService _auth;
  final DatabaseService _db;

  AuthCubit(this._auth, this._db) : super(AuthInitial());

  void init() async {
    /// Try getting a valid session
    try {
      /// Refreshes the session to check if user still exists
      await _auth.refreshSession(); // shouldn't be necessary in prod-level app
      // todo: remove

      /// Check if valid session
      if (_auth.sessionActive) {
        /// Check if Session isn't expired
        if (!_auth.sessionExpired) {
          final userData = _auth.userData!;

          /// Get username from database
          // todo: use hydrated cubit instead
          String username = await _db.getUsername(id: userData['id']!);

          emit(AuthLoggedIn(
            User(
              username: username,
              id: userData['id']!,
              email: userData['email']!,
              createdAt: DateTime.parse(userData['created_at']!),
            ),
          ));
        }

        /// Otherwise send error indicating to log in again
        else {
          emit(AuthError(
              'Authentication has expired, please try logging in again'));
        }
      }
    }

    /// catch any errors
    catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Log in with E-Mail and password
  ///
  /// emits [AuthError] state with error message when an error occurs
  Future<void> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    /// validate email and password
    if (email.isEmpty || password.isEmpty) {
      emit(AuthError('Email and password are required.'));
      throw ('Email and password are required.');
    }

    /// emit loading state
    emit(AuthLoading());

    /// try logging in
    try {
      await _auth.signInWithEmailPassword(
        email: email,
        password: password,
      );

      final userData = _auth.userData!;

      String username = await _db.getUsername(id: userData['id']!);

      /// emit Logged in state if successful
      emit(AuthLoggedIn(User(
        username: username,
        id: userData['id']!,
        email: userData['email']!,
        createdAt: DateTime.parse(userData['created_at']),
      )));
    }

    /// emit Error state if failed
    catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Sign up with E-Mail and password
  /// can add phone number if we want
  ///
  /// emits [AuthError] state with error message when an error occurs
  Future<void> signUpWithUsernameEmailPassword({
    required String username,
    required String email,
    required String password,
    String? phone,
  }) async {
    /// emit loading state
    emit(AuthLoading());

    /// try signing up
    try {
      await _auth.signUpWithUsernameEmailPassword(
        username: username,
        email: email,
        password: password,
        phone: phone,
      );

      final userData = _auth.userData!;

      /// emit Logged in state if successful
      emit(AuthLoggedIn(User(
        username: username,
        id: userData['id']!,
        email: userData['email']!,
        createdAt: DateTime.parse(userData['created_at']),
      )));
    }

    /// emit Error state if failed
    catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Log Out
  Future<void> logOut() async {
    if (state is AuthLoggedIn) {
      /// try log out
      try {
        await _auth.signOut();
        emit(AuthInitial());
      }

      /// catch any errors
      on Exception catch (e) {
        emit(AuthError(e.toString()));
      }
    }
  }

  /// delete account
  Future<void> deleteAccount() async {
    if (state is AuthLoggedIn) {
      /// try delete account
      try {
        await _auth.deleteAccount();
        emit(AuthInitial());
      }

      /// catch any errors
      on Exception catch (e) {
        emit(AuthError(e.toString()));
      }
    }
  }

  /// Emit an error if we notice something went wrong.
  void authError(String errorMessage) {
    emit(AuthError(errorMessage));
  }
}
