import 'package:camera/camera.dart';
import 'package:fitbattles/screens/workout_tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitbattles/auth/login_page.dart';
import 'package:fitbattles/challenges/distance_workout_page.dart';
import 'package:fitbattles/challenges/strength_workout_page.dart';
import 'package:fitbattles/challenges/leaderboard_page.dart';
import 'package:fitbattles/screens/my_history.dart';
import 'package:fitbattles/challenges/create_challenge_page.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';
import 'package:fitbattles/screens/home_page.dart';
import 'package:fitbattles/screens/friends_list_page.dart';
import 'package:fitbattles/screens/settings_page.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Request permissions for notifications and camera
  await requestPermissions();

  // Initialize camera
  List<CameraDescription> cameras;
  try {
    cameras = await availableCameras();
  } catch (e) {
    // Handle camera initialization error
    logger.e("Error initializing cameras: $e");
    cameras = [];
  }

  // Initialize timezones
  tz.initializeTimeZones();

  // Initialize notifications
  final notificationsHandler = NotificationsHandler();
  await notificationsHandler.init();

  // Run the app after all initializations are done
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(
        notificationsHandler: notificationsHandler, // Pass the notificationsHandler
        cameras: cameras, // Pass the cameras
      ),
    ),
  );
}

// Request necessary permissions
Future<void> requestPermissions() async {
  // Request camera permission
  await Permission.camera.request();

  // Request notification permission for Android 13 and above
  if (await Permission.notification.request().isGranted) {
    // Handle permission granted case
  } else {
    logger.d("Notification permission denied");
  }
}

class MyApp extends StatelessWidget {
  final NotificationsHandler notificationsHandler;
  final List<CameraDescription> cameras;

  // Correct constructor without unnecessary parameters
  const MyApp({super.key, required this.notificationsHandler, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FitBattles',
          theme: themeProvider.themeData, // Apply the current theme
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginPage(title: 'FitBattles'),
            '/home': (context) => const HomePage(id: '', email: '', uid: '',),
            '/friendsSearch': (context) => const FriendsListPage(),
            '/history': (context) => const MyHistoryPage(),
            '/pointsInfo': (context) => const EarnedPointsPage(
              points: 1000,
              streakDays: 360,
              totalChallengesCompleted: 0,
              pointsEarnedToday: 0,
              bestDayPoints: 0,
            ),
            '/distanceWorkout': (context) => const DistanceWorkoutPage(),
            '/strengthWorkout': (context) => const StrengthWorkoutPage(),
            '/leaderboard': (context) => const LeaderboardPage(),
            '/settings': (context) => const SettingsPage(), // Added route for SettingsPage
            '/create_challenge': (context) => CreateChallengePage(cameras: cameras, friends: const [], friend: ''),
            '/friendsList': (context) => const FriendsListPage(),
            '/workoutTracking': (context) => const WorkoutTrackingPage(),
          },
          navigatorKey: notificationsHandler.navigatorKey, // Add navigator key to handle notification taps
        );
      },
    );
  }
}

// NotificationsHandler class
class NotificationsHandler {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final Logger logger = Logger();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // Navigator key for navigation

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _createNotificationChannel();
    await scheduleHydrationNotification();

    // Listen for notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message.data);
    });

    // Log device token
    String? token = await firebaseMessaging.getToken();
    logger.i('FCM Token: $token');
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'hydration_channel',
      'Hydration Notifications',
      description: 'Reminds you to stay hydrated',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleHydrationNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'hydration_channel',
      'Hydration Notifications',
      channelDescription: 'Reminds you to stay hydrated',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

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

  void handleNotificationTap(Map<String, dynamic> data) {
    final String? route = data['route'];
    if (route != null) {
      logger.d('Navigating to route: $route');
      navigatorKey.currentState?.pushNamed(route); // Navigate to the route
    }
  }
}
