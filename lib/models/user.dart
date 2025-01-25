class UserModel {
  final String id;
  final String email;
  final String username;
  final List<String> friends = [];

  UserModel({
    required this.id,
    required this.email,
    required this.username,
  });
}
