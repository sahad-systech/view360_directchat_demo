import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<List<MessageEntity>> getChatHistory(String sessionId);
  Future<MessageEntity> sendMessage(String text, String sessionId);
}
