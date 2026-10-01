import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:view360directchat/view360directchat.dart';
import 'package:view360_direct_chat_example/features/Home/home_screen.dart';
import 'package:view360_direct_chat_example/features/chat/presentation/providers/chat_provider.dart';
import 'package:view360_direct_chat_example/core/constants/app_constants.dart';

void main() {
  final chatService = ChatService(baseUrl: AppConstants.chatBaseUrl, appId: AppConstants.chatAppId);
  final socketManager = SocketManager();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider(chatService: chatService, socketManager: socketManager)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'View360 Direct Chat Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
