import 'package:dio/dio.dart';
import '../models/message_model.dart';

class ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSource({required this.dio});

  Future<List<MessageModel>> getChatHistory(String sessionId) async {
    final response = await dio.get('/api/v1/chat/$sessionId/history');
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  Future<MessageModel> sendMessage(String text, String sessionId) async {
    final response = await dio.post(
      '/api/v1/chat/$sessionId/send',
      data: {'text': text},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return MessageModel.fromJson(response.data);
    } else {
      throw Exception('Failed to send message');
    }
  }
}
