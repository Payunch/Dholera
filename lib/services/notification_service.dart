import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'local_database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final LocalDatabaseService _db = LocalDatabaseService();

  Future<void> initialize() async {
    // 1. Request Permission (iOS/Android 13+)
    final NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('User granted permission');
    }

    // 2. Setup Local Notifications (Foreground support)
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click if needed
      },
    );

    // 3. Configure FCM Callbacks
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // 4. Subscribe to Admin Alerts topic
    await _fcm.subscribeToTopic('admin_alerts');
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) print('Foreground Message: ${message.notification?.title}');
    
    // Save to local DB
    _saveNotificationToLocalDb(message);
    
    // Show local notification so user sees it while app is open
    _showLocalNotification(message);
  }

  Future<void> _saveNotificationToLocalDb(RemoteMessage message) async {
    try {
      final data = message.data;
      
      // Save the raw notification record
      await _db.insertNotification({
        'title': message.notification?.title ?? 'Admin Alert',
        'body': message.notification?.body ?? '',
        'data': jsonEncode(data),
        'receivedAt': DateTime.now().toIso8601String(),
      });

      // If it's a lead, save to leads table
      if (data['type'] == 'lead_onboard' || data['type'] == 'lead_registration') {
        await _db.insertLead({
          'server_id': data['lead_id'],
          'name': data['name'],
          'phone': data['phone'],
          'source': data['source'],
          'status': 'New',
          'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
          'synced': 1,
        });
        if (kDebugMode) print('Lead saved locally: ${data['name']}');
      }
    } catch (e) {
      if (kDebugMode) print('Error saving notification: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'dholera_admin_channel',
      'Admin Alerts',
      channelDescription: 'Notifications for new leads and payments',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    
    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Admin Alert',
      body: message.notification?.body,
      notificationDetails: details,
    );
  }
}

// Global background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Since this runs in a separate isolate, we need to re-initialize services if needed
  // However, sqflite works fine across isolates.
  final db = LocalDatabaseService();
  final data = message.data;

  try {
    await db.insertNotification({
      'title': message.notification?.title ?? 'Background Alert',
      'body': message.notification?.body ?? '',
      'data': jsonEncode(data),
      'receivedAt': DateTime.now().toIso8601String(),
    });

    if (data['type'] == 'lead_onboard' || data['type'] == 'lead_registration') {
      await db.insertLead({
        'server_id': data['lead_id'],
        'name': data['name'],
        'phone': data['phone'],
        'source': data['source'],
        'status': 'New',
        'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        'synced': 1,
      });
    }
  } catch (e) {
    // Ignore errors in background
  }
}
