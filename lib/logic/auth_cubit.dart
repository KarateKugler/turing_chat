import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_api/supabase_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _auth;
  final DatabaseService _db;

  AuthCubit(this._auth, this._db) : super(AuthInitial());

  void init() async {
    /// Try getting a valid session
    try {
      /// Refreshes the session to check if user still exists
      AuthResponse response = await _auth
          .refreshSession(); // shouldn't be necessary in prod-level app
      // todo: remove

      /// Check if valid session
      Session? currentSession = _auth.currentSession;

      if (currentSession != null) {
        /// Check if Session isn't expired
        if (!currentSession.isExpired) {
          /// Get username from database
          // todo: use hydrated cubit instead
          String username = await _db.getUsername(id: currentSession.user.id);

          emit(AuthLoggedIn(
            UserModel(
              username: username,
              id: currentSession.user.id,
              email: currentSession.user.email!,
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
    on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
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
      AuthResponse response = await _auth.signInWithEmailPassword(
        email: email,
        password: password,
      );

      String username = await _db.getUsername(id: response.user!.id);

      /// emit Logged in state if successful
      emit(AuthLoggedIn(UserModel(
        username: username,
        id: response.user!.id,
        email: response.user!.email!,
      )));
    }

    /// emit Error state if failed
    on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
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
      AuthResponse response = await _auth.signUpWithUsernameEmailPassword(
        username: username,
        email: email,
        password: password,
        phone: phone,
      );

      /// emit Logged in state if successful
      emit(AuthLoggedIn(UserModel(
        id: response.user!.id,
        email: response.user!.email!,
        username: username, // lazy but works
      )));

      /// Add profile to 'profile' table
      _db.addProfile(response.user!.email!);
    }

    /// emit Error state if failed
    on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
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
}
