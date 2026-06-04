import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/leads/leads_bloc.dart';
import '../blocs/leads/leads_event.dart';
import '../models/lead.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // To access BLoC from global service, we'll need a navigator key or context
  // For now, we use a static global access or handle it via a stream
  static final _dataStreamController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

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
      settings: initSettings,
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
    
    // Push to stream so UI can react and update BLoC
    final data = message.data;
    if (data['type'] == 'lead_onboard' || data['type'] == 'lead_registration') {
       _dataStreamController.add(data);
    }
    
    // Show local notification
    _showLocalNotification(message);
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
  // In background, we rely on the next app open to sync from server 
  // because HydratedBloc doesn't easily persist across background isolates 
  // without complex setup.
}
