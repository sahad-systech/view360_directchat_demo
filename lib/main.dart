import 'package:flutter/material.dart';

import 'features/Aivoice/active_voice_chat_screen.dart';
import 'features/Aivoice/ai_voice_screen.dart';
import 'features/Aivoice/call_completed_screen.dart';

void main() {
  runApp(const MyApp());
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
      home: const CallCompletedScreen(),
    );
  }
}
