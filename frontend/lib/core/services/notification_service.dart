import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/providers/notification_provider.dart';
import '../utils/snackbar_helper.dart';

class NotificationService extends GetxService {
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _provider = NotificationProvider();

  static const _channel = AndroidNotificationChannel(
    'renewd_reminders',
    'Renewal Reminders',
    description: 'Notifications for upcoming renewals',
    importance: Importance.high,
  );

  Future<NotificationService> init() async {
    await _initLocalNotifications();
    await _requestPermission();
    await _registerToken();
    _listenForTokenRefresh();
    _listenForForegroundMessages();
    _listenForMessageTaps();
    return this;
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _registerToken() async {
    // Wait for APNS token to be ready (iOS requires this before FCM token)
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          final token = await _messaging.getToken();
          if (token != null) {
            debugPrint('[FCM] Token: ${token.substring(0, 20)}...');
            await _provider.registerFcmToken(token);
            debugPrint('[FCM] Token registered with backend');
            return;
          }
        }
      } catch (e) {
        debugPrint('[FCM] Attempt ${attempt + 1} failed: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    debugPrint('[FCM] Could not register token after 5 attempts');
  }

  void _listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      await _provider.registerFcmToken(token);
    });
  }

  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  void _listenForMessageTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final hasReminder = message.data['reminder_id'] != null;
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          actions: hasReminder
              ? const [
                  AndroidNotificationAction('snooze', 'Snooze',
                      showsUserInterface: false),
                ]
              : null,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    final renewalId = message.data['renewal_id'];
    if (renewalId != null) {
      Get.toNamed('/renewal-detail', arguments: renewalId);
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    final data = jsonDecode(response.payload!) as Map<String, dynamic>;

    if (response.actionId == 'snooze') {
      _handleSnooze(data);
      return;
    }

    final renewalId = data['renewal_id'];
    if (renewalId != null) {
      Get.toNamed('/renewal-detail', arguments: renewalId);
    }
  }

  Future<void> _handleSnooze(Map<String, dynamic> data) async {
    final renewalId = data['renewal_id'] as String?;
    final reminderId = data['reminder_id'] as String?;
    if (renewalId == null || reminderId == null) return;
    try {
      await _provider.snoozeReminder(renewalId, reminderId);
      showSuccessSnack('Reminder snoozed until tomorrow');
    } catch (e) {
      showErrorSnack('Failed to snooze reminder');
    }
  }
}
