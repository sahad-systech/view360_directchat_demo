import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:view360directchat/view360directchat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService chatService;
  final SocketManager socketManager;

  ChatProvider({required this.chatService, required this.socketManager}) {
    _initSocket();
  }

  bool isLoading = false;
  List<ChatMessage> messages = [];
  String? errorMessage;
  VoidCallback? onChatClosed;

  void _initSocket() {
    socketManager.connect(
      baseUrl: chatService.baseUrl,
      onConnected: () {
        debugPrint('Socket connected');
      },
      onAgentJoin: ({dynamic name}) {
        log('working agent join block');
        final String agentName =
            (name != null && name.toString().trim().isNotEmpty)
            ? name.toString().trim()
            : 'Agent';
        debugPrint('Agent joined: $agentName');
      },
      onAgentClose: () {
        debugPrint('Agent closed');
        closeChat();
        onChatClosed?.call();
      },
      onChatTransfer: ({required String name}) {
        debugPrint('Chat transferred to: $name');
      },
      onRemovedByInActivity: ({required dynamic reason}) {
        debugPrint('Removed by inactivity: $reason');
        closeChat();
        onChatClosed?.call();
      },
      onMessage:
          ({
            required dynamic content,
            required dynamic createdAt,
            required dynamic response,
            required dynamic senderType,
            List<String>? filePaths,
          }) {
            final newMessage = ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch,
              content: content?.toString() ?? '',
              senderType: senderType?.toString() ?? '',
              files: filePaths ?? [],
              createdAt:
                  createdAt?.toString() ?? DateTime.now().toIso8601String(),
            );
            messages.add(newMessage);
            notifyListeners();
          },
    );
  }

  Future<void> fetchHistory(String sessionId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await chatService.fetchMessages();
      messages = response.messages;
      log(messages.length.toString());
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSession({
    required String name,
    required String email,
    required String phone,
    required String firstMessage,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await chatService.createChatSession(
        chatContent: firstMessage,
        customerName: name,
        customerEmail: email,
        fetchFCMToken: false,
      );

      if (!response.success && response.isInQueue != true) {
        errorMessage = response.message ?? 'Failed to start chat';
        return false;
      }

      String defaultMessage = 'We will get back to you as soon as possible';
      messages = [
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch,
          content: 'Chat Session Created',
          senderType: 'system',
          files: [],
          createdAt: DateTime.now().toString(),
        ),
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch + 1,
          content: firstMessage,
          senderType: 'customer',
          files: [],
          createdAt: DateTime.now().toString(),
        ),
      ];

      if (response.isInQueue == true) {
        messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch + 2,
            content: response.message ?? defaultMessage,
            senderType: 'user',
            files: [],
            createdAt: DateTime.now().toString(),
          ),
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasActiveChatSession', true);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text, String sessionId) async {
    if (text.trim().isEmpty) return;

    // Optimistic UI update
    final optimisticMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      content: text,
      senderType: 'customer',
      createdAt: DateTime.now().toIso8601String(),
      files: [],
    );

    messages.add(optimisticMessage);
    notifyListeners();

    try {
      final response = await chatService.sendChatMessage(
        chatContent: text,
        filePath: [],
      );
      if (!response.status) {
        throw Exception(response.error ?? 'Unknown error sending message');
      }
    } catch (e) {
      // Remove optimistic message if failed
      messages.removeWhere((m) => m.id == optimisticMessage.id);
      errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  Future<void> closeChat() async {
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('hasActiveChatSession');
      chatService.closeChat();
      messages.clear();
      socketManager.disconnect();
    } catch (e) {
      errorMessage = 'Failed to close chat: $e';
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    socketManager.disconnect();
    super.dispose();
  }
}
