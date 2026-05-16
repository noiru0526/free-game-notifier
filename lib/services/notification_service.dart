import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are handled by the OS notification tray
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelFreeGames = AndroidNotificationChannel(
    'free_games',
    '無料ゲーム通知',
    description: '新しい無料ゲームが追加されたときに通知します',
    importance: Importance.high,
  );

  static const _channelExpiry = AndroidNotificationChannel(
    'expiry_warning',
    '期限切れ間近',
    description: '無料期間が24時間以内に終了するゲームを通知します',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channelFreeGames);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channelExpiry);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _subscribeToTopics();
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _subscribeToTopics() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('notify_free_games') ?? true) {
      await _messaging.subscribeToTopic('free_games');
    }
    if (prefs.getBool('notify_expiry') ?? true) {
      await _messaging.subscribeToTopic('expiry_warnings');
    }
  }

  Future<void> updateTopicSubscription(String topic, bool enabled) async {
    if (enabled) {
      await _messaging.subscribeToTopic(topic);
    } else {
      await _messaging.unsubscribeFromTopic(topic);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final isExpiry = message.data['type'] == 'expiry_warning';
    final channelId = isExpiry ? 'expiry_warning' : 'free_games';
    final importance = isExpiry ? Importance.max : Importance.high;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          isExpiry ? '期限切れ間近' : '無料ゲーム通知',
          importance: importance,
          priority: isExpiry ? Priority.max : Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF4E7CFF),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<String?> getToken() => _messaging.getToken();
}
