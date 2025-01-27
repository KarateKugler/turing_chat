part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

/// AuthLoading
final class AuthLoading extends AuthState {}

/// AuthLoggedIn
final class AuthLoggedIn extends AuthState {
  /// User
  final User user;

  AuthLoggedIn(this.user);
}

/// AuthAnonymous
final class AuthAnonymous extends AuthState {}

/// AuthError
final class AuthError extends AuthState {
  /// Error Message
  final String errorMessage;

  AuthError(this.errorMessage);

  @override
  String toString() {
    return 'AuthError($errorMessage)';
  }
}
