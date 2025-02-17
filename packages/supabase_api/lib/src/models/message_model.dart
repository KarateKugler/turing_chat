/// The Model storing all information about a message
class MessageModel {
  final String id;
  final String senderId;
  final bool sentByUser;
  final String content;
  final bool generated;
  final bool identified;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.sentByUser,
    required this.content,
    required this.generated,
    required this.identified,
    required this.createdAt,
  });
}
