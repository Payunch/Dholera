import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../config/api_config.dart';
import '../models/app_update.dart';
import '../pages/update_detail_page.dart';
import '../pages/updates_page.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static GlobalKey<NavigatorState>? navigatorKey;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  static final _dataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get dataStream =>
      _dataStreamController.stream;

  Future<void> initialize({GlobalKey<NavigatorState>? navKey}) async {
    if (navKey != null) {
      navigatorKey = navKey;
    }

    // 1. Request Permission
    final NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('Notification Permission Granted');
    }

    // 2. Setup Local Notifications & Channel
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(details.payload!);
            _handleNotificationClick(Map<String, dynamic>.from(data));
          } catch (e) {
            if (kDebugMode) print('Local notification payload parse error: $e');
          }
        }
      },
    );

    // Register high-priority notification channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'dholera_general_channel',
      'General Notifications',
      description: 'Updates on Dholera SIR infrastructure and projects',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. Configure FCM Callbacks
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground / Background click listeners
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) print('App opened from notification: ${message.data}');
      _handleNotificationClick(message.data);
    });

    // Cold start click check
    unawaited(_fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) print('Initial notification message: ${message.data}');
        Future.delayed(const Duration(milliseconds: 1000), () {
          _handleNotificationClick(message.data);
        });
      }
    }));

    // 4. All normal app users receive published market insights.
    try {
      await _fcm.subscribeToTopic('investors');
    } catch (e) {
      if (kDebugMode) print('Subscribe to topic error: $e');
    }
    _fcm.onTokenRefresh.listen((_) => syncTokenWithBackend());

    // 5. Sync token if already logged in
    await syncTokenWithBackend();
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    if (kDebugMode) print('Handling notification click: $data');
    _dataStreamController.add(data);

    final nav = navigatorKey?.currentState;
    if (nav == null) {
      if (kDebugMode) print('NavigatorKey not ready yet for notification click');
      return;
    }

    final idStr = data['id']?.toString();
    final slug = data['slug']?.toString();
    final title = data['title']?.toString() ?? 'Intelligence Report';
    final imageUrl = data['imageUrl']?.toString();

    if (idStr != null && int.tryParse(idStr) != null) {
      final update = AppUpdate(
        id: int.parse(idStr),
        title: title,
        content: '',
        category: data['category']?.toString() ?? 'Industrial',
        published: true,
        publishedAt: DateTime.now(),
        createdAt: DateTime.now(),
        slug: slug,
        imageUrl: imageUrl,
      );
      nav.push(
        MaterialPageRoute(builder: (_) => UpdateDetailPage(update: update)),
      );
    } else {
      nav.push(
        MaterialPageRoute(builder: (_) => const UpdatesPage()),
      );
    }
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

      await http
          .post(
            Uri.parse('${ApiConfig.apiBaseUrl}/preferences/fcm-token'),
            headers: headers,
            body: jsonEncode({'fcmToken': fcmToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) print('FCM Token synced successfully');
    } catch (e) {
      if (kDebugMode) print('FCM Token sync failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) print('Foreground Message: ${message.notification?.title}');

    final data = {
      ...message.data,
      if (message.notification?.title != null)
        'title': message.notification!.title!,
    };
    _dataStreamController.add(data);

    _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'dholera_general_channel',
          'General Notifications',
          channelDescription:
              'Updates on Dholera SIR infrastructure and projects',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          color: Color(0xFFFF7A00),
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

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
