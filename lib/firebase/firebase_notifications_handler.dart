import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationsHandler {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Logger logger = Logger();
  final GlobalKey<NavigatorState> navigatorKey; // Store navigatorKey

  NotificationsHandler(this.navigatorKey, {required FirebaseMessaging firebaseMessaging, required FlutterLocalNotificationsPlugin localNotificationsPlugin, required Logger loggerInstance}); // Constructor

  Future<void> init() async {
    await requestNotificationPermission(); // Request notification permission

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await _createNotificationChannel();
    await _scheduleHydrationNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });

    String? token = await firebaseMessaging.getToken();
    logger.i('FCM Token: $token');
  }

  // Request notification permissions for iOS
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i('User granted permission for notifications.');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      logger.i('User granted provisional permission for notifications.');
    } else {
      logger.w('User denied permission for notifications.');
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'hydration_channel',
      'Hydration Notifications',
      description: 'Reminds you to stay hydrated',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _scheduleHydrationNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'hydration_channel',
      'Hydration Notifications',
      channelDescription: 'Reminds you to stay hydrated',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Time to Hydrate!',
      'Don\'t forget to drink water!',
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 1)),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final String? route = data['route'];
    if (route != null) {
      logger.d('Navigating to route: $route');
      // Use the stored navigatorKey for navigation
      navigatorKey.currentState?.pushNamed(route);
    }
  }
}
