import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/api_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initialize({
    void Function(Map<String, dynamic> data)? onTap,
  }) async {
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
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );

    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        await showNotification(
          message.notification!.title ?? 'Notification',
          message.notification!.body ?? 'You have a new notification',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (onTap != null) onTap(message.data);
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null && onTap != null) {
      onTap(initialMessage.data);
    }
  }

  // Background-isolate safe, minimal init for local notifications
  static Future<void> initializeLocalOnly() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Called by the background handler
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? 'You have a new notification';

    // Persist to in-app notifications list
    await ApiService.addNotification(
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: body,
        timestamp: DateTime.now(),
        isRead: false,
        bookingId: message.data['bookingId'],
      ),
    );

    // Optionally show a local notification for data-only messages
    await showNotification(title, body);
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'booking_channel',
          'Booking Notifications',
          channelDescription: 'Notifications for booking updates',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, title, body, platformChannelSpecifics,
    );
  }
}