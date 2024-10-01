import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class GoalNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Logger logger = Logger(); // Logger instance for debugging

  GoalNotifications() {
    _initializeNotifications();
  }

  Future<void> init() async {
    await _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings); // Removed onSelectNotification

    // Request permission for iOS
    await _firebaseMessaging.requestPermission();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotification(message.notification!);
      }
    });
  }

  Future<void> _showNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'goal_completion_channel',
      'Goal Completion Notifications',
      channelDescription: 'Notifications when a goal is completed',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: 'goal_completed',
    );
  }

  // Callback for when the notification is selected
  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      logger.d('Notification payload: $payload');
      // Handle navigation or any action based on the notification selection
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await GoalNotifications()._showNotification(message.notification!);
  }
}
