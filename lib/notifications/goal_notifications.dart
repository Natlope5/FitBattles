import 'package:firebase_messaging/firebase_messaging.dart'; // Importing Firebase Messaging for push notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Importing Flutter Local Notifications for local notifications
import 'package:logger/logger.dart'; // Importing logger for logging messages

class GoalNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance; // Instance of FirebaseMessaging for handling FCM
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin(); // Instance for local notifications
  final Logger logger = Logger(); // Logger instance for debugging

  GoalNotifications() {
    _initializeNotifications(); // Initialize notifications when an instance is created
  }

  Future<void> init() async {
    await _initializeNotifications(); // Ensure notifications are initialized
  }

  Future<void> _initializeNotifications() async {
    // Initialize local notifications with Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings); // Initialize local notifications

    // Request permission for iOS notifications
    await _firebaseMessaging.requestPermission();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotification(message.notification!); // Show notification when message is received
      }
    });
  }

  // Function to show local notification
  Future<void> _showNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'goal_completion_channel', // Channel ID
      'Goal Completion Notifications', // Channel name
      channelDescription: 'Notifications when a goal is completed', // Channel description
      importance: Importance.max, // Maximum importance
      priority: Priority.high, // High priority
      showWhen: false, // Do not show time of notification
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotificationsPlugin.show(
      notification.hashCode, // Unique ID for the notification
      notification.title, // Notification title
      notification.body, // Notification body
      platformChannelSpecifics, // Notification details
      payload: 'goal_completed', // Optional payload for handling selection
    );
  }

  // Callback for when the notification is selected
  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      logger.d('Notification payload: $payload'); // Log the payload for debugging
      // Handle navigation or any action based on the notification selection
    }
  }

  // Static method for handling background messages
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await GoalNotifications()._showNotification(message.notification!); // Show notification when a background message is received
  }
}
