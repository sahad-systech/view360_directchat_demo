class MessageEntity {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final bool isMe;

  MessageEntity({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    required this.isMe,
  });
}
