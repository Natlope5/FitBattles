import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitbattles/challenges/distance_workout_page.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';
import 'package:fitbattles/challenges/strength_workout_page.dart';
import 'package:fitbattles/firebase/firebase_notifications_handler.dart';
import 'package:fitbattles/screens/friends_list_page.dart';
import 'package:fitbattles/screens/home_page.dart';
import 'package:fitbattles/screens/my_history.dart';
import 'package:fitbattles/screens/settings_page.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'challenges/create_challenge_page.dart';
import 'challenges/leaderboard_page.dart';
import 'auth/login_page.dart'; // Correct the import for auth-related files

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
            AppLocalizationsDelegate(), // Remove `const` here
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
            '/home': (context) => HomePage(id: '', email: '', uid: ''),
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
            '/create_challenge': (context) => CreateChallengePage(cameras: cameras, friends: [], friend: ''),
          },
        );
      },
    );
  }
}

class AppLocalizationsDelegate {
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize NotificationsHandler with proper values
  final notificationsHandler = NotificationsHandler(
    firebaseMessaging as GlobalKey<NavigatorState>, // Pass initialized instance
    localNotificationsPlugin: localNotificationsPlugin, // Pass initialized instance
    loggerInstance: logger, firebaseMessaging: null, // Pass initialized instance
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(cameras: await availableCameras()),
    ),
  );
}
