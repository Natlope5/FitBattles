import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Class to handle notifications using Firebase Cloud Messaging and local notifications
class NotificationsHandler {
  final FirebaseMessaging firebaseMessaging;
  final Logger logger;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationsHandler({
    required this.firebaseMessaging,  // Make sure it's 'this' and not 'firebaseMessaging'
    required this.logger,
    required this.flutterLocalNotificationsPlugin,
  });


  Future<void> init() async {
    // Initialize local notifications
    await _initializeLocalNotifications(); // Call the method to initialize local notifications

    // Request permissions for iOS notifications
    NotificationSettings settings = await firebaseMessaging.requestPermission();
    logger.i('User granted permission: ${settings.authorizationStatus}');

    // Get the FCM token for this device
    String? token = await firebaseMessaging.getToken();
    logger.i('FCM Token: $token');

    // Listen for incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message); // Show notification for incoming message
    });

    // Handle messages when the app is in the background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Use the logger from NotificationsHandler if needed
    Logger logger = Logger();
    logger.i('Handling a background message: ${message.messageId}');
    // Optionally show a local notification here if needed
  }

  void _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id', // Change this to a unique ID
      'your_channel_name', // Change this to a descriptive name
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      message.notification?.hashCode ?? 0, // Use a unique ID for each notification
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      platformChannelSpecifics,
      payload: message.data['route'], // Pass the route as payload
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final route = message.data['route'];
    if (route != null) {
      navigatorKey.currentState?.pushNamed(route);
    }
  }
}
