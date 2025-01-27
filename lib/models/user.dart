import 'package:turing_chat/models/contact.dart';


class User {
  final String id;
  final String email;
  final String username;
  final List<Contact> friends = [];

  User({
    required this.id,
    required this.email,
    required this.username,
  });
}
