import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    log('Notification permission: ${settings.authorizationStatus}');

    // Listen for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('FCM foreground message received:');
      log(' - notification: title="${message.notification?.title}", body="${message.notification?.body}"');
      log(' - data: ${message.data}');
    });
  }
}
