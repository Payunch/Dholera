import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../config/api_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();
  
  static final _dataStreamController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  Future<void> initialize() async {
    // 1. Request Permission
    final NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('Notification Permission Granted');
    }

    // 2. Setup Local Notifications
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click
      },
    );

    // 3. Configure FCM Callbacks
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // 4. Initial Topics
    await _fcm.subscribeToTopic('investors');
    
    // 5. Sync token if already logged in
    await syncTokenWithBackend();
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      return null;
    }
  }

  Future<void> syncTokenWithBackend() async {
    try {
      final leadToken = await _apiService.getAuthToken();
      if (leadToken == null) return;

      final fcmToken = await getToken();
      if (fcmToken == null) return;

      final headers = await _apiService.getMutationHeaders();
      headers['x-lead-token'] = leadToken;

      await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/preferences/fcm-token'),
        headers: headers,
        body: jsonEncode({'fcmToken': fcmToken}),
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) print('FCM Token synced successfully');
    } catch (e) {
      if (kDebugMode) print('FCM Token sync failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) print('Foreground Message: ${message.notification?.title}');
    
    final data = message.data;
    _dataStreamController.add(data);
    
    _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'dholera_general_channel',
      'General Notifications',
      channelDescription: 'Updates on Dholera SIR infrastructure and projects',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: const Color(0xFFFF7A00),
    );
    
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    
    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Dholera Platform',
      body: message.notification?.body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Logic for background processing if needed
}
