import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../core/helpers/app_logger.dart';
import 'local_notifications_util.dart';

class PushNotificationsUtil {
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    await LocalNotificationsUtil.init();

    // Request permissions
    await messaging.requestPermission();

    // IOS foreground notification presentation options
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    try {
      final token = await messaging.getToken();

      if (token != null) {
        sendTokenToServer(token);
      } else {
        AppLogger.log('FCM token is null', name: 'PUSH_NOTIFICATIONS');
      }
    } catch (e) {
      AppLogger.log('Failed to get FCM token: $e', name: 'PUSH_NOTIFICATIONS');
    }

    // Token refresh handling
    messaging.onTokenRefresh.listen((token) {
      sendTokenToServer(token);
    });

    // Background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages
    _handleForegroundMessages();

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

    // App opened from terminated
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }

    // Topic subscription
    try {
      await messaging.subscribeToTopic('all');

      AppLogger.log('Subscribed to topic: all', name: 'PUSH_NOTIFICATIONS');
    } catch (e) {
      AppLogger.log(
        'Failed to subscribe to topic: $e',
        name: 'PUSH_NOTIFICATIONS',
      );
    }
  }

  // Foreground message handling
  static void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.log(
        'Foreground Message: ${message.notification?.title ?? message.data}',
        name: 'PUSH_NOTIFICATIONS',
      );

      LocalNotificationsUtil.showBasicNotification(message);
    });
  }

  // Notification click handling
  static void _handleNotificationClick(RemoteMessage message) {
    AppLogger.log(
      'Notification clicked: ${message.data}',
      name: 'PUSH_NOTIFICATIONS',
    );

    // Add navigation logic based on message.data (final type = message.data['type'];)
  }

  // Get current FCM token
  static Future<String?> getCurrentToken() async {
    try {
      final token = await messaging.getToken();

      if (token != null) {
        AppLogger.log('FCM Token: $token', name: 'PUSH_NOTIFICATIONS');
      }

      return token;
    } catch (e) {
      AppLogger.log('Error getting FCM token: $e', name: 'PUSH_NOTIFICATIONS');

      return null;
    }
  }

  static void sendTokenToServer(String token) {
    AppLogger.log('Send token: $token', name: 'PUSH_NOTIFICATIONS');
  }
}

// Background message handler (must be a top-level function)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  AppLogger.log(
    'Background Message: ${message.notification?.title ?? message.data}',
    name: 'PUSH_NOTIFICATIONS',
  );
}
