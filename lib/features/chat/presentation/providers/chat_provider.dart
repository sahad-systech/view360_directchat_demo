import 'package:flutter/foundation.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository repository;
  
  ChatProvider({required this.repository});

  bool isLoading = false;
  List<MessageEntity> messages = [];
  String? errorMessage;

  Future<void> fetchHistory(String sessionId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      messages = await repository.getChatHistory(sessionId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text, String sessionId) async {
    if (text.trim().isEmpty) return;
    
    // Optimistic UI update
    final optimisticMessage = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderId: 'user', // Ensure this matches current logged in user ID
      timestamp: DateTime.now(),
      isMe: true,
    );
    
    messages.add(optimisticMessage);
    notifyListeners();

    try {
      final actualMessage = await repository.sendMessage(text, sessionId);
      
      // Replace optimistic message with actual message returned from server
      final index = messages.indexWhere((m) => m.id == optimisticMessage.id);
      if (index != -1) {
        messages[index] = actualMessage;
        notifyListeners();
      }
    } catch (e) {
      // Remove optimistic message if failed
      messages.removeWhere((m) => m.id == optimisticMessage.id);
      errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }
}
