import 'package:flutter/material.dart';
import 'package:view360directchat/view360directchat.dart';

import '../../core/constants/app_constants.dart';

class VoiceAiUi extends StatefulWidget {
  const VoiceAiUi({super.key});

  @override
  State<VoiceAiUi> createState() => _VoiceAiUiState();
}

class _VoiceAiUiState extends State<VoiceAiUi> {
  String userName = '';
  String userPhone = '';
  String userEmail = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = 'Tester';
    final phone = '1234567890';
    final email = 'tester@gmail.com';
    if (mounted) {
      setState(() {
        userName = name;
        userPhone = phone;
        userEmail = email;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Localizations.override(
      context: context,
      locale: const Locale('en', 'US'),
      child: View360CallPage(
        config: const View360CallConfig(
          tokenUrl: AppConstants.tokenUrlLivekit,
          sdkId: AppConstants.sdkIdLivekit,
          apiKey: AppConstants.apiKeyLivekit,
          livekitUrl: AppConstants.livekitUrl,
        ),
        userName: userName,
        userPhone: userPhone,
        userEmail: userEmail,
      ),
    );
  }
}
