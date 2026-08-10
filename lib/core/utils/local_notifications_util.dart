import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsUtil {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final StreamController<NotificationResponse> streamController =
      StreamController.broadcast();

  static const String channelId = 'high_importance_channel';

  // Init local notifications
  static Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onTap,
    );

    await _createNotificationChannel();
  }

  // Create notification channel (Android 8.0+)
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      'High Importance Notifications',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // Show a basic notification
  static Future<void> showBasicNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Notification';

    final body = message.notification?.body ?? message.data['body'] ?? '';

    const androidDetails = AndroidNotificationDetails(
      channelId,
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final int notificationId =
        message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }

  // Tap handling for notifications
  static void _onTap(NotificationResponse response) {
    streamController.add(response);
  }

  static void dispose() {
    streamController.close();
  }
}
