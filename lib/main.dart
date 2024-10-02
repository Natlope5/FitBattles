import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Assuming Firebase initialization
import 'package:fitbattles/screens/login_page.dart';
import 'package:fitbattles/challenges/distance_workout_page.dart';
import 'package:fitbattles/challenges/strength_workout_page.dart';
import 'package:fitbattles/challenges/leaderboard_page.dart';
import 'package:fitbattles/settings/visibility_settings_page.dart';
import 'package:fitbattles/challenges/create_challenge_page.dart';
import 'package:fitbattles/notifications/notifications_handler.dart';
import 'package:fitbattles/challenges/earned_points_page.dart';
import 'package:fitbattles/screens/friends_list_page.dart'; // Correctly importing the friends list page
import 'package:fitbattles/settings/my_history.dart'; // Correctly importing the My History page
import 'package:fitbattles/screens/workout_tracking_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure all widgets are initialized
  await Firebase.initializeApp(); // Initialize Firebase

  final notificationsHandler = NotificationsHandler(); // Create an instance of NotificationsHandler
  await notificationsHandler.init(); // Initialize notifications handler

  runApp(const MyApp()); // Run the main app
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitBattles', // App title
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5D6C8A)), // Theme color scheme
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black, // Body text color
          displayColor: Colors.black, // Display text color
        ),
      ),
      initialRoute: '/login', // Set the initial route to login page
      routes: {
        '/login': (context) => const MyLoginPage(title: ''), // Route to login page
        '/home': (context) => const HomePage(uid: '', email: ''), // Route to home page
        '/friendsSearch': (context) => const FriendsListPage(), // Route for Friends Search Page
        '/my_history': (context) => const MyHistoryPage(), // Route to my history page
        '/pointsInfo': (context) => const EarnedPointsPage(points: 1000, streakDays: 360), // Route to earned points page
        '/distanceWorkout': (context) => const DistanceWorkoutPage(), // Route to distance workout page
        '/strengthWorkout': (context) => const StrengthWorkoutPage(), // Route to strength workout page
        '/leaderboard': (context) => const LeaderboardPage(), // Route to leaderboard page
        '/settings': (context) => const VisibilitySettingsPage(), // Route to visibility settings page
        '/create_challenge': (context) => const CreateChallengePage(), // Route to create challenge page
        '/earnedPoints': (context) => const EarnedPointsPage(points: 1000, streakDays: 360), // Route to earned points page (duplicate)
        '/friendsList': (context) => const FriendsListPage(), // Route to friends list page
        '/workoutTracking': (context) => const WorkoutTrackingPage(),
      },
    );
  }
}

// Home page widget
class HomePage extends StatelessWidget {
  final String uid; // User ID
  final String email; // User email

  const HomePage({super.key, required this.uid, required this.email});

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
        color: const Color(0xFF5D6C8A), // Background color for the body
        child: Center(
          child: SingleChildScrollView( // Enable scrolling for the content
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20), // Space above the logo
                Image.asset(
                  'assets/logo.png', // Logo image
                  height: 150, // Height of the logo
                ),
                const SizedBox(height: 20), // Space below the logo
                const Text(
                  'Welcome to FitBattles!', // Welcome message
                  style: TextStyle(fontSize: 24, color: Color(0xFF85C83E)), // Style for welcome message
                ),
                const SizedBox(height: 20), // Space before user info
                Text('User ID: $uid', style: const TextStyle(fontSize: 16, color: Colors.white)), // Display user ID
                Text('Email: $email', style: const TextStyle(fontSize: 16, color: Colors.white)), // Display user email
                const SizedBox(height: 40), // Space before the button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/friendsSearch'); // Navigate to friends search page
                  },
                  child: const Text('Search Friends'), // Button text
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}