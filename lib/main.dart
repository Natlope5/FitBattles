import 'package:firebase_core/firebase_core.dart';
import 'package:fitbattles/challenges/distance_workout_page.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';
import 'package:fitbattles/pages/add_goal_page.dart';
import 'package:fitbattles/pages/challenges/time_based_challenges_page.dart';
import 'package:fitbattles/pages/community_challenge.dart';
import 'package:fitbattles/pages/current_goals_page.dart';
import 'package:fitbattles/workouts/custom_workout_page.dart';
import 'package:fitbattles/pages/goals_completion_page.dart';
import 'package:fitbattles/pages/badges_and_rewards_page.dart';
import 'package:fitbattles/pages/health_report_page.dart';
import 'package:fitbattles/pages/workout_tracking_page.dart';
import 'package:fitbattles/workouts/strength_workout_page.dart';
import 'package:fitbattles/pages/friends_list_page.dart';
import 'package:fitbattles/pages/home_page.dart';
import 'package:fitbattles/pages/my_history_page.dart';
import 'package:fitbattles/pages/settings_page.dart';
import 'package:fitbattles/pages/user_profile_page.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:fitbattles/challenges/create_challenge_page.dart';
import 'package:fitbattles/challenges/leaderboard_page.dart';
import 'package:fitbattles/auth/login_page.dart';
import 'package:fitbattles/challenges/user_challenges_page.dart';
import 'package:fitbattles/pages/workout_history_page.dart';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();
final Logger logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
            '/settings': (context) => const SettingsPage(heading: 'Settings',),
            '/create_challenge': (context) => CreateChallengePage(),
            '/user_challenges': (context) => const UserChallengesPage(),
            '/addGoal': (context) => AddGoalPage(),
            '/currentGoals': (context) => CurrentGoalsPage(),
            '/goalHistory': (context) => GoalCompletionPage(),
            '/rewards': (context) => RewardsPage(),
            '/healthReport': (context) => const HealthReportPage(),
            '/scheduleChallenge': (context) => const CommunityChallengePage(),
            '/customWorkout': (context) => CustomWorkoutPlanPage(),
            '/timeBasedChallenges': (context) => TimeBasedChallengesPage(),
          },
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}