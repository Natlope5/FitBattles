import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitbattles/challenges/distance_workout_page.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';
import 'package:fitbattles/screens/workout_tracking_page.dart';
import 'package:fitbattles/workouts/strength_workout_page.dart';
import 'package:fitbattles/screens/friends_list_page.dart';
import 'package:fitbattles/screens/home_page.dart';
import 'package:fitbattles/screens/my_history.dart';
import 'package:fitbattles/screens/settings_page.dart';
import 'package:fitbattles/screens/user_profile_page.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:fitbattles/challenges/create_challenge_page.dart';
import 'package:fitbattles/challenges/leaderboard_page.dart';
import 'package:fitbattles/auth/login_page.dart';
import 'package:fitbattles/challenges/user_challenges_page.dart';
import 'package:fitbattles/screens/workout_history_page.dart';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();
final Logger logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'FitBattles',
          theme: themeProvider.currentTheme,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', ''),
            Locale('fr', ''),
            Locale('de', ''),
            Locale('zh', ''),
          ],
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginPage(title: '', setLocale: (locale) {}),
            '/': (context) => UserProfilePage(heading: 'Create Profile'),
            '/home': (context) => HomePage(id: '', email: '', uid: ''),
            '/workoutTracking': (context) => const WorkoutTrackingPage(),

            '/friends': (context) => const FriendsListPage(),
            '/history': (context) => const MyHistoryPage(),
            '/workoutHistory': (context) => const WorkoutHistoryPage(),
            '/pointsInfo': (context) => const EarnedPointsPage(
              points: 1000,
              streakDays: 360,
              totalChallengesCompleted: 0,
              pointsEarnedToday: 0,
              bestDayPoints: 0, userId: '',
            ),
            '/distanceWorkout': (context) => const DistanceWorkoutPage(),
            '/strengthWorkout': (context) => const StrengthWorkoutPage(),
            '/leaderboard': (context) => const LeaderboardPage(),
            '/settings': (context) => const SettingsPage(),
            '/create_challenge': (context) => CreateChallengePage(),
            '/user_challenges': (context) => const UserChallengesPage(),
          },
        );
      },
    );
  }
}

class NotificationsHandler {
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;

  NotificationsHandler({required this.localNotificationsPlugin});

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('your_image'); // Ensure app_icon exists in drawable

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await localNotificationsPlugin.initialize(initializationSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', // Your channel ID
      'your_channel_name', // Your channel name
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await localNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'Default Title', // Default Title if null
      message.notification?.body ?? 'Default Body',   // Default Body if null
      platformChannelSpecifics,
      payload: message.data['payload'] ?? '', // Handle payload safely
    );
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    // Handle background notification data here if needed
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize NotificationsHandler with proper values
  final notificationsHandler = NotificationsHandler(localNotificationsPlugin: localNotificationsPlugin);
  await notificationsHandler.initializeNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Provide ThemeProvider for the whole app
      child: MyApp(cameras: await availableCameras()),
    ),
  );
}
