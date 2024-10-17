import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:fitbattles/settings/app_strings.dart'; // Import your strings file
import 'package:flutter/material.dart'; // Import this for BuildContext and navigatorKey

class GoalNotificationsHandler {
  final FirebaseMessaging firebaseMessaging;
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;
  final Logger loggerInstance;

  GoalNotificationsHandler({
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
        'goal_notifications_channel',
        AppStrings.goalNotificationChannel, // Use string from AppStrings
        channelDescription: AppStrings.goalNotificationChannelDescription, // Use string from AppStrings
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        sound: RawResourceAndroidNotificationSound('sound'), // Correct sound file name
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      await localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: 'goal_notification', // Adjust payload as needed
      );

      loggerInstance.i('${AppStrings.goalNotificationDisplayed} ${notification.title}'); // Use string from AppStrings
    } catch (e) {
      loggerInstance.e('${AppStrings.errorShowingGoalNotification}: $e'); // Use string from AppStrings
    }
  }

  void _setupNotificationListeners() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      loggerInstance.d('${AppStrings.notificationTapped} ${message.data}'); // Use string from AppStrings
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
      // Implement navigation logic here
      navigatorKey.currentState?.pushNamed('/goalDetails'); // Update with actual route
    }
  }

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final loggerInstance = Logger();
    final notificationsHandler = GoalNotificationsHandler(
      firebaseMessaging: FirebaseMessaging.instance,
      localNotificationsPlugin: localNotificationsPlugin,
      loggerInstance: loggerInstance,
    );

    try {
      if (message.notification != null) {
        await notificationsHandler.showNotification(message.notification!);
      }
      loggerInstance.i('${AppStrings.backgroundMessageHandled} ${message.notification?.title}'); // Use string from AppStrings
    } catch (e) {
      loggerInstance.e('${AppStrings.errorShowingBackgroundMessage}: $e'); // Updated error message
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap-hdpi/logo_image.png');

      const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

      await localNotificationsPlugin.initialize(initializationSettings);
      await firebaseMessaging.requestPermission();

      loggerInstance.i(AppStrings.goalNotificationsInitializedSuccessfully); // Use string from AppStrings
    } catch (e) {
      loggerInstance.e('${AppStrings.failedToInitializeGoalNotifications}: $e'); // Use string from AppStrings
    }
  }
}

// Ensure you define your navigatorKey in your main.dart or a relevant file
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

