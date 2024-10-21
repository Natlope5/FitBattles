import 'package:fitbattles/screens/started_challenges_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fitbattles/screens/home_page.dart'; // Example import for HomePage
import 'package:fitbattles/auth/login_page.dart';
import 'package:fitbattles/auth/signup_profile_page.dart';
import 'package:fitbattles/challenges/challenge.dart' as challenges;
import 'package:fitbattles/challenges/create_challenge_page.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';
import 'package:fitbattles/challenges/leaderboard_page.dart';
import 'package:fitbattles/challenges/distance_workout_page.dart';
import 'package:fitbattles/challenges/user_challenges_page.dart';
import 'package:fitbattles/screens/add_goal_page.dart';
import 'package:fitbattles/screens/current_goals_page.dart';
import 'package:fitbattles/screens/friends_list_page.dart';
import 'package:fitbattles/screens/goals_completion_page.dart';
import 'package:fitbattles/screens/my_history.dart';
import 'package:fitbattles/screens/settings_page.dart';
import 'package:fitbattles/screens/workout_history_page.dart';
import 'package:fitbattles/screens/workout_tracking_page.dart';
import 'package:fitbattles/workouts/strength_workout_page.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:intl/intl.dart'; // To handle date formatting

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();
final Logger logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeHome = '/home';
  static const String routeWorkoutTracking = '/workoutTracking';
  static const String routeFriends = '/friends';
  static const String routeHistory = '/history';
  static const String routeWorkoutHistory = '/workoutHistory';
  static const String routePointsInfo = '/pointsInfo';
  static const String routeDistanceWorkout = '/distanceWorkout';
  static const String routeStrengthWorkout = '/strengthWorkout';
  static const String routeLeaderboard = '/leaderboard';
  static const String routeSettings = '/settings';
  static const String routeCreateChallenge = '/create_challenge';
  static const String routeUserChallenges = '/user_challenges';
  static const String routeAddGoal = '/addGoal';
  static const String routeCurrentGoals = '/currentGoals';
  static const String routeGoalHistory = '/goalHistory';
  static const String routeStartedChallenges = '/started_challenges';
  static const String routeStartGoals = '/startedgoals';
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'FitBattles',
          theme: themeProvider.currentTheme,
          localizationsDelegates: const [
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
          initialRoute: routeLogin,
          routes: {
            routeLogin: (context) => LoginPage(title: '', setLocale: (locale) {}),
            routeSignup: (context) => const SignupProfilePage(heading: 'Sign up Profile'),
            routeHome: (context) => HomePage(id: '', email: '', name: '', bio: '', uid: '',),
            routeWorkoutTracking: (context) => const WorkoutTrackingPage(),
            routeFriends: (context) => const FriendsListPage(),
            routeHistory: (context) => const MyHistoryPage(),
            routeWorkoutHistory: (context) => const WorkoutHistoryPage(),
            routePointsInfo: (context) => const EarnedPointsPage(
              points: 1000,
              streakDays: 360,
              totalChallengesCompleted: 0,
              pointsEarnedToday: 0,
              bestDayPoints: 0,
              userId: '',
            ),
            routeDistanceWorkout: (context) => const DistanceWorkoutPage(),
            routeStrengthWorkout: (context) => const StrengthWorkoutPage(),
            routeLeaderboard: (context) => const LeaderboardPage(),
            routeSettings: (context) => const SettingsPage(heading: 'Settings Page'),
            routeCreateChallenge: (context) => CreateChallengePage(),
            routeUserChallenges: (context) => const UserChallengesPage(),
            routeAddGoal: (context) => AddGoalPage(),
            routeCurrentGoals: (context) => CurrentGoalsPage(),
            routeGoalHistory: (context) => GoalCompletionPage(userToken: ''),
            routeStartedChallenges: (context) => StartedChallengesPage(
              startedChallenge: challenges.Challenge(
                name: "Running Challenge",
                type: "Distance",
                // Use DateTime.parse to convert date strings into DateTime
                startDate: DateFormat('MM/dd/yy').parse("10/21/22"),
                endDate: DateFormat('MM/dd/yy').parse("10/28/22"),
                participants: [],
                description: "This is a fun running challenge!", opponentId: '',
              ),
            ),
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
