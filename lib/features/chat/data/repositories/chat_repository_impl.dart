import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MessageEntity>> getChatHistory(String sessionId) async {
    final models = await remoteDataSource.getChatHistory(sessionId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<MessageEntity> sendMessage(String text, String sessionId) async {
    final model = await remoteDataSource.sendMessage(text, sessionId);
    return model.toEntity();
  }
}
