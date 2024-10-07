import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class NotificationsHandler {
  final FirebaseMessaging firebaseMessaging;
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;
  final Logger loggerInstance;

  NotificationsHandler({
    required this.firebaseMessaging,
    required this.localNotificationsPlugin,
    required this.loggerInstance,
  });

  Future<void> init() async {
    await _initializeNotifications();
    _setupNotificationListeners();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> showNotification(RemoteNotification notification) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'general_notifications_channel',
        'General Notifications',
        channelDescription: 'General notifications for the app',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        sound: RawResourceAndroidNotificationSound('your_sound_file'), // Ensure this sound file exists
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      await localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: 'general_notification',
      );

      loggerInstance.i('Notification displayed: ${notification.title}');
    } catch (e) {
      loggerInstance.e('Error showing notification: $e');
    }
  }

  void _setupNotificationListeners() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      loggerInstance.d('Notification tapped: ${message.data}');
      String? payload = message.data['payload'];
      if (payload != null) {
        handleNotificationAction(payload);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(message.notification!);
      }
    });
  }

  void handleNotificationAction(String payload) {
    if (payload == 'goal_completed') {
      loggerInstance.d('Navigating to goal completion details.');
      // Implement navigation logic
    }
  }

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Initialize dependencies for background handler
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final loggerInstance = Logger();
    final notificationsHandler = NotificationsHandler(
      firebaseMessaging: FirebaseMessaging.instance,
      localNotificationsPlugin: localNotificationsPlugin,
      loggerInstance: loggerInstance,
    );

    try {
      if (message.notification != null) {
        await notificationsHandler.showNotification(message.notification!);
      }
      loggerInstance.i('Background message handled: ${message.notification?.title}');
    } catch (e) {
      loggerInstance.e('Error handling background message: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

      await localNotificationsPlugin.initialize(initializationSettings);
      await firebaseMessaging.requestPermission();

      loggerInstance.i('Notifications initialized successfully.');
    } catch (e) {
      loggerInstance.e('Failed to initialize notifications: $e');
    }
  }
}

