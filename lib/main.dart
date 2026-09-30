import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:view360_direct_chat_example/features/Home/home_screen.dart';
import 'package:view360_direct_chat_example/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:view360_direct_chat_example/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:view360_direct_chat_example/features/chat/presentation/providers/chat_provider.dart';

void main() {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com')); // Placeholder base URL
  final chatRemoteDataSource = ChatRemoteDataSource(dio: dio);
  final chatRepository = ChatRepositoryImpl(remoteDataSource: chatRemoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider(repository: chatRepository)),
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
