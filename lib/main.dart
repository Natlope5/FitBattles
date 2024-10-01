import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core for initialization
import 'package:fitbattles/auth/login_page.dart'; // Importing various pages for navigation
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5D6C8A)), // Custom color scheme
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black, // Set default text color to black
          displayColor: Colors.black,
        ),
      ),
      initialRoute: '/login', // Initial route to display on app launch
      routes: { // Define routes for navigation
        '/login': (context) => const MyLoginPage(title: ''),
        '/home': (context) => const HomePage(uid: '', email: ''),
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

// Home page of the application
class HomePage extends StatelessWidget {
  final String uid; // User ID
  final String email; // User email

  const HomePage({super.key, required this.uid, required this.email}); // Constructor for HomePage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D6C8A), // App bar color
        title: const Text('Home'), // Title of the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Logout icon
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login'); // Navigate to login page
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF5D6C8A), // Background color for the main body
        child: Center(
          child: SingleChildScrollView( // Allows scrolling if content overflows
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the column contents
              children: <Widget>[
                const SizedBox(height: 20), // Spacer
                Image.asset(
                  'assets/logo.png', // Logo image
                  height: 150, // Height of the logo
                ),
                const SizedBox(height: 20), // Spacer
                const Text(
                  'Welcome to FitBattles!', // Welcome message
                  style: TextStyle(fontSize: 24, color: Color(0xFF85C83E)), // Style for welcome message
                ),
                const SizedBox(height: 20), // Spacer
                Text('User ID: $uid', style: const TextStyle(fontSize: 16, color: Colors.white)), // Display user ID
                Text('Email: $email', style: const TextStyle(fontSize: 16, color: Colors.white)), // Display user email
                const SizedBox(height: 40), // Spacer
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/friendsSearch'); // Navigate to friends search page
                  },
                  child: const Text('Search Friends'), // Button label
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
