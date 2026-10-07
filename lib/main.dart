import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:view360directchat/view360directchat.dart';
import 'package:view360_direct_chat_example/features/Home/home_screen.dart';
import 'package:view360_direct_chat_example/features/chat/presentation/providers/chat_provider.dart';
import 'package:view360_direct_chat_example/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:view360_direct_chat_example/features/chat/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasActiveChatSession = prefs.getBool('hasActiveChatSession') ?? false;
  await View360.init(View360Config(
    baseUrl: AppConstants.chatBaseUrl,
    appId: AppConstants.chatAppId,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            chatService: View360.chat,
            socketManager: View360.socket,
          ),
        ),
      ],
      child: MyApp(hasActiveChatSession: hasActiveChatSession),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasActiveChatSession;

  const MyApp({super.key, required this.hasActiveChatSession});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'View360 Direct Chat Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: hasActiveChatSession ? const ChatScreen() : const HomeScreen(),
    );
  }
}
