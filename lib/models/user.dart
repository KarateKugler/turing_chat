import 'package:turing_chat/models/contact.dart';

/// The User Model
class User {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final List<Contact> friends = [];

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
  });
}
