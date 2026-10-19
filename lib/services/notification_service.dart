import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Function(Map<String, dynamic>)? onNotificationTapped;

  static Future<void> initialize(
      {Function(Map<String, dynamic>)? onTap}) async {
    onNotificationTapped = onTap;

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!);
            onNotificationTapped?.call(data);
          } catch (e) {
            print('Error parsing notification payload: $e');
          }
        }
      },
    );

    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission granted: ${settings.authorizationStatus}');

    // Get FCM token in the background. Some devices can temporarily report
    // SERVICE_NOT_AVAILABLE or wait for Play Services; app startup must continue.
    _firebaseMessaging.getToken().then((token) async {
      print('FCM Token: $token');

      // Save token to your server
      if (token != null) {
        await saveFCMToken(token);
      }
    }).catchError((e) {
      print('Unable to fetch FCM token during startup: $e');
    });

    // Handle notifications
    FirebaseMessaging.onMessage.listen(handleForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('FCM Token refreshed: $newToken');
      await saveFCMToken(newToken);
    });

    // Configure for iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Handle notification when app is in foreground
  static Future<void> handleForegroundNotification(
      RemoteMessage message) async {
    print('Foreground notification received: ${message.notification?.title}');
    print('Notification data: ${message.data}');

    // Show local notification
    await showNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? message.data['body'] ?? '',
      payload: jsonEncode(message.data),
    );

    // Handle specific notification types
    if (message.data['type'] == 'in_pass_created') {
      print(
          'In pass created notification received: ${message.data['visitor_code']}');
      // You can trigger any UI updates here
    }
  }

  // Background message handler (must be static or top-level)
  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print('Background notification received: ${message.notification?.title}');
    print('Background data: ${message.data}');

    // Show notification
    await showNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? message.data['body'] ?? '',
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'gate_security_channel',
      'Gate Security Notifications',
      channelDescription: 'Notifications for gate security updates',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
      colorized: true,
      color: Colors.blue,
      ledColor: Colors.blue,
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
      threadIdentifier: 'gate_security_thread',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<void> saveFCMToken(String token) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Get user ID
      int? userId = prefs.getInt('session_user_id') ??
          prefs.getInt('user_id') ??
          prefs.getInt('id');

      if (userId == null) {
        String? userJson = prefs.getString('userData');
        if (userJson != null) {
          Map<String, dynamic> userData = jsonDecode(userJson);
          dynamic idFromJson = userData['id'] ?? userData['user_id'];

          if (idFromJson is String) {
            userId = int.tryParse(idFromJson);
          } else if (idFromJson is int) {
            userId = idFromJson;
          }
        }
      }

      if (userId != null) {
        // Save token to server using Admin SDK endpoint
        var response = await ApiService.postMethod3('/save_fcm_token', {
          'user_id': userId,
          'user_type': 'gate_security',
          'token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        });

        print('FCM token saved response: $response');

        if (response['success'] == true) {
          print('FCM token saved successfully to server');
        } else {
          print('Failed to save FCM token: ${response['message']}');
        }
      } else {
        print('No user ID found for saving FCM token');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');

    // Handle notification tap
    onNotificationTapped?.call(message.data);

    if (message.data['type'] == 'in_pass_created') {
      print(
          'Navigate to scanner with visitor code: ${message.data['visitor_code']}');
      // You can navigate to the scanner tab here
    }
  }

  // Send notification using Firebase Admin SDK via your backend
  static Future<Map<String, dynamic>> sendAdminNotification({
    required String title,
    required String body,
    required String type,
    String? visitorCode,
    List<String>? tokens,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('session_user_id') ??
          prefs.getInt('user_id') ??
          prefs.getInt('id');

      if (userId == null) {
        String? userJson = prefs.getString('userData');
        if (userJson != null) {
          Map<String, dynamic> userData = jsonDecode(userJson);
          dynamic idFromJson = userData['id'] ?? userData['user_id'];

          if (idFromJson is String) {
            userId = int.tryParse(idFromJson);
          } else if (idFromJson is int) {
            userId = idFromJson;
          }
        }
      }

      var response = await ApiService.postMethod3('/send_admin_notification', {
        'user_id': userId ?? 0,
        'title': title,
        'body': body,
        'type': type,
        'visitor_code': visitorCode,
        'tokens': tokens,
        'additional_data': additionalData,
      });

      return response;
    } catch (e) {
      print('Error sending admin notification: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
