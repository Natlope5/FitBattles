import 'package:camera/camera.dart';
import 'package:fitbattles/auth/login_page.dart';
import 'package:fitbattles/challenges/create_challenge_page.dart';
import 'package:fitbattles/challenges/distance_workout_page.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';
import 'package:fitbattles/challenges/leaderboard_page.dart';
import 'package:fitbattles/challenges/strength_workout_page.dart';
import 'package:fitbattles/screens/friends_list_page.dart';
import 'package:fitbattles/screens/home_page.dart';
import 'package:fitbattles/screens/my_history.dart';
import 'package:fitbattles/screens/settings_page.dart';
import 'package:fitbattles/screens/workout_tracking_page.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final Logger logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await requestPermissions();
    List<CameraDescription> cameras = await _initializeCameras();
    tz.initializeTimeZones();
    final NotificationsHandler notificationsHandler = NotificationsHandler();
    await notificationsHandler.init();

    runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(), // Ensure correct provider type
        child: MyApp(cameras: cameras, notificationsHandler: notificationsHandler),
      ),
    );
  } catch (e) {
    logger.e("Error during app initialization: $e");
  }
}

Future<void> requestPermissions() async {
  if (await Permission.camera.request().isDenied) {
    logger.e("Camera permission denied");
  }
  if (await Permission.notification.request().isDenied) {
    logger.e("Notification permission denied");
  }
}

Future<List<CameraDescription>> _initializeCameras() async {
  try {
    return await availableCameras();
  } catch (e) {
    logger.e("Error initializing cameras: $e");
    return [];
  }
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final NotificationsHandler notificationsHandler;

  const MyApp({super.key, required this.cameras, required this.notificationsHandler});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>( // Use ThemeProvider instead of ThemeNotifier
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'FitBattles',
          theme: themeProvider.currentTheme,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginPage(title: 'FitBattles'),
            '/home': (context) => const HomePage(id: '', email: '', uid: ''),
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
            '/settings': (context) => const SettingsPage(),
            '/create_challenge': (context) => CreateChallengePage(cameras: cameras, friends: const [], friend: ''),
            '/friendsList': (context) => const FriendsListPage(),
            '/workoutTracking': (context) => const WorkoutTrackingPage(),
          },
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

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await _createNotificationChannel();
    await scheduleHydrationNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message.data);
    });

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

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
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

  void handleNotificationTap(Map<String, dynamic> data) {
    final String? route = data['route'];
    if (route != null) {
      logger.d('Navigating to route: $route');
      navigatorKey.currentState?.pushNamed(route);
    }
  }
}
