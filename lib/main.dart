import 'package:firebase_core/firebase_core.dart';
import 'package:fitbattles/pages/points/earned_points_page.dart';
import 'package:fitbattles/pages/goals/add_goal_page.dart';
import 'package:fitbattles/pages/challenges/time_based_challenges_page.dart';
import 'package:fitbattles/pages/challenges/community_challenge.dart';
import 'package:fitbattles/pages/goals/current_goals_page.dart';
import 'package:fitbattles/pages/workouts/custom_workout_page.dart';
import 'package:fitbattles/pages/goals/goals_completion_page.dart';
import 'package:fitbattles/pages/badges_and_rewards_page.dart';
import 'package:fitbattles/pages/health_report_page.dart';
import 'package:fitbattles/pages/workouts/workout_suggestion_page.dart';
import 'package:fitbattles/pages/workouts/workout_tracking_page.dart';
import 'package:fitbattles/pages/friends_list_page.dart';
import 'package:fitbattles/pages/home_page.dart';
import 'package:fitbattles/pages/my_history_page.dart';
import 'package:fitbattles/pages/settings_page.dart';
import 'package:fitbattles/pages/user_profile_page.dart';
import 'package:fitbattles/settings/ui/theme_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:fitbattles/pages/challenges/create_challenge_page.dart';
import 'package:fitbattles/pages/points/leaderboard_page.dart';
import 'package:fitbattles/auth/login_page.dart';
import 'package:fitbattles/pages/challenges/user_challenges_page.dart';
import 'package:fitbattles/pages/workouts/workout_history_page.dart';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();
final Logger logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Firebase Messaging background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  logger.i("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up the background message handler for Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await localNotificationsPlugin.initialize(initializationSettings);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'FitBattles',
          theme: themeProvider.currentTheme,
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginPage(title: '', setLocale: (locale) {}),
            '/': (context) => UserProfilePage(heading: 'Create Profile'),
            '/home': (context) => HomePage(id: '', email: '', uid: ''),
            '/workoutTracking': (context) => const WorkoutTrackingPage(),
            '/friends': (context) => const FriendsListPage(),
            '/history': (context) => const MyHistoryPage(),
            '/workoutHistory': (context) => const WorkoutHistoryPage(),
            '/pointsInfo': (context) => EarnedPointsPage(userId: ''),
            '/leaderboard': (context) => const LeaderboardPage(),
            '/settings': (context) => const SettingsPage(heading: 'Settings'),
            '/create_challenge': (context) => CreateChallengePage(),
            '/user_challenges': (context) => UserChallengesPage(),
            '/addGoal': (context) => AddGoalPage(),
            '/currentGoals': (context) => CurrentGoalsPage(),
            '/goalHistory': (context) => GoalCompletionPage(),
            '/rewards': (context) => RewardsPage(),
            '/healthReport': (context) => const HealthReportPage(),
            '/scheduleChallenge': (context) => const CommunityChallengePage(),
            '/customWorkout': (context) => CustomWorkoutPlanPage(),
            '/timeBasedChallenges': (context) => TimeBasedChallengesPage(),
            '/workoutSuggestions': (context) => WorkoutSuggestionPage(),
          },
        );
      },
    );
  }
}
