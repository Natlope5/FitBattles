import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core for initialization
import 'package:fitbattles/auth/login_page.dart'; // Importing the login page for navigation
import 'package:fitbattles/challenges/distance_workout_page.dart';
import 'package:fitbattles/challenges/strength_workout_page.dart';
import 'package:fitbattles/challenges/leaderboard_page.dart';
import 'package:fitbattles/settings/visibility_settings_page.dart';
import 'package:fitbattles/challenges/create_challenge_page.dart';
import 'package:fitbattles/notifications/notifications_handler.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';
import 'package:fitbattles/screens/friends_list_page.dart';
import 'package:fitbattles/settings/my_history.dart';
import 'package:fitbattles/notifications/goal_notifications.dart';
import 'package:fitbattles/screens/home_page.dart'; // Ensure HomePage is imported

// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized before running the app
  await Firebase.initializeApp(); // Initialize Firebase

  final notificationsHandler = NotificationsHandler(); // Create an instance of NotificationsHandler
  await notificationsHandler.init(); // Initialize notification handling

  final goalNotifications = GoalNotifications(); // Create an instance of GoalNotifications
  await goalNotifications.init(); // Initialize goal notifications

  runApp(const MyApp()); // Run the main app widget
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor for MyApp

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide the debug banner
      title: 'FitBattles', // Title of the application
      theme: ThemeData(
        fontFamily: 'Inter', // Set the default font family to Inter
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5D6C8A)), // Custom color scheme
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black, // Set default text color to black
          displayColor: Colors.black,
        ),
      ),
      initialRoute: '/login', // Initial route to display on app launch
      routes: { // Define routes for navigation
        '/login': (context) => const LoginPage(title: 'Fitbattles'), // Updated reference to LoginPage
        '/home': (context) => const HomePage(uid: '', email: ''), // HomePage updated to pass parameters
        '/friendsSearch': (context) => const FriendsListPage(),
        '/my_history': (context) => const MyHistoryPage(),
        '/pointsInfo': (context) => const EarnedPointsPage(points: 1000, streakDays: 360),
        '/distanceWorkout': (context) => const DistanceWorkoutPage(),
        '/strengthWorkout': (context) => const StrengthWorkoutPage(),
        '/leaderboard': (context) => const LeaderboardPage(),
        '/settings': (context) => const VisibilitySettingsPage(),
        '/create_challenge': (context) => const CreateChallengePage(),
        '/earnedPoints': (context) => const EarnedPointsPage(points: 1000, streakDays: 360),
        '/friendsList': (context) => const FriendsListPage(),
      },
    );
  }
}
