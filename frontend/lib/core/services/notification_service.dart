import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../data/providers/notification_provider.dart';
import '../services/storage_service.dart';
import '../utils/snackbar_helper.dart';

class NotificationService extends GetxService {
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  NotificationProvider? _provider;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _tapSub;

  static const _channel = AndroidNotificationChannel(
    'renewd_reminders',
    'Renewal Reminders',
    description: 'Notifications for upcoming renewals',
    importance: Importance.high,
  );

  Future<NotificationService> init() async {
    await _initLocalNotifications();
    await _requestPermission();
    _listenForForegroundMessages();
    _listenForMessageTaps();
    await _handleInitialMessage();
    // Defer token registration — only if user is logged in
    // Otherwise, splash_controller calls registerToken() after login
    Future.delayed(const Duration(seconds: 3), () {
      final storage = Get.find<StorageService>();
      if (storage.readToken() != null) {
        _provider = NotificationProvider();
        _registerToken();
        _listenForTokenRefresh();
      }
    });
    return this;
  }

  /// Handle notification tap when app was completely killed
  Future<void> _handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      // Delay to let the app finish navigating to home first
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleMessageTap(message);
      });
    }
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
    // Show notifications when app is in foreground on iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> registerToken() async {
    _provider ??= NotificationProvider();
    await _registerToken();
  }

  Future<void> _registerToken() async {
    // Wait for APNS token to be ready (iOS requires this before FCM token)
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          final token = await _messaging.getToken();
          if (token != null) {
            await _provider?.registerFcmToken(token);
            return;
          }
        }
      } catch (e) {
        debugPrint('_registerToken attempt $attempt failed: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _listenForTokenRefresh() {
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) async {
      await _provider?.registerFcmToken(token);
    });
  }

  void _listenForForegroundMessages() {
    // On iOS, foreground notifications are handled by setForegroundNotificationPresentationOptions
    // On Android, we still need local notifications for foreground
    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      if (Platform.isAndroid) {
        _showLocalNotification(message);
      }
    });
  }

  void _listenForMessageTaps() {
    _tapSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
  }

  @override
  void onClose() {
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
    _tapSub?.cancel();
    super.onClose();
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

  static final _validIdPattern = RegExp(r'^[a-zA-Z0-9\-]+$');

  bool _isValidId(String? id) {
    if (id == null || id.isEmpty) return false;
    return id.length >= 20 && _validIdPattern.hasMatch(id);
  }

  void _handleMessageTap(RemoteMessage message) {
    final type = message.data['type'] as String?;
    if (type == 'support') {
      final ticketId = message.data['ticket_id'] as String?;
      if (!_isValidId(ticketId)) {
        debugPrint('_handleMessageTap: invalid ticketId: $ticketId');
        return;
      }
      Get.toNamed('/support', arguments: ticketId);
      return;
    }
    final renewalId = message.data['renewal_id'] as String?;
    if (_isValidId(renewalId)) {
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

    final type = data['type'] as String?;
    if (type == 'support') {
      final ticketId = data['ticket_id'] as String?;
      if (!_isValidId(ticketId)) {
        debugPrint('_onNotificationTap: invalid ticketId: $ticketId');
        return;
      }
      Get.toNamed('/support', arguments: ticketId);
      return;
    }

    final renewalId = data['renewal_id'] as String?;
    if (_isValidId(renewalId)) {
      Get.toNamed('/renewal-detail', arguments: renewalId);
    }
  }

  Future<void> _handleSnooze(Map<String, dynamic> data) async {
    final renewalId = data['renewal_id'] as String?;
    final reminderId = data['reminder_id'] as String?;
    if (renewalId == null || reminderId == null) return;
    try {
      _provider ??= NotificationProvider();
      await _provider!.snoozeReminder(renewalId, reminderId);
      showSuccessSnack('Reminder snoozed until tomorrow');
    } catch (e) {
      showErrorSnack('Failed to snooze reminder');
    }
  }
}
