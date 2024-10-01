import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitbattles/auth/login_page.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final notificationsHandler = NotificationsHandler();
  await notificationsHandler.init();

  final goalNotifications = GoalNotifications();
  await goalNotifications.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Debug banner removed
      title: 'FitBattles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5D6C8A)),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),
      initialRoute: '/login',
      routes: {
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

class HomePage extends StatelessWidget {
  final String uid;
  final String email;

  const HomePage({super.key, required this.uid, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D6C8A),
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF5D6C8A),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Image.asset(
                  'assets/logo.png',
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to FitBattles!',
                  style: TextStyle(fontSize: 24, color: Color(0xFF85C83E)),
                ),
                const SizedBox(height: 20),
                Text('User ID: $uid', style: const TextStyle(fontSize: 16, color: Colors.white)),
                Text('Email: $email', style: const TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/friendsSearch');
                  },
                  child: const Text('Search Friends'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
