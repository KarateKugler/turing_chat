const usernameRegexString = r'^[A-Za-z0-9_]{3,24}$';

/// Check valid E-Mail
bool validateEmail(String email) {
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}

/// Check valid username
bool validateUsername(String username) {
  return RegExp(usernameRegexString).hasMatch(username);
}