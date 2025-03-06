/// The Model storing all information about a message
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool generated;
  final bool? identified;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.generated,
    required this.identified,
    required this.createdAt,
  });

  static MessageModel fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      generated: json['generated'],
      identified: json['identified'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
