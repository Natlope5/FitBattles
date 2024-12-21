import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitbattles/main.dart'; // for logger
import 'package:fitbattles/pages/goals/goals_completion_page.dart';
import 'package:fitbattles/pages/workouts/workout_history_page.dart';
import 'package:provider/provider.dart';

import 'hydration_page.dart';
import 'package:fitbattles/settings/ui/theme_provider.dart';

// Data class to hold history data
class HistoryData {
  final double waterIntake;
  final double totalCaloriesBurned;

  HistoryData({required this.waterIntake, required this.totalCaloriesBurned});
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  // Fetch total calories burned
  Future<double> _fetchTotalCaloriesBurned() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .get();

      double totalCalories = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double calories =
        data['calories'] != null ? (data['calories'] as num).toDouble() : 0.0;
        totalCalories += calories;
      }

      await _saveTotalCaloriesAsPoints(totalCalories);
      return totalCalories;
    } catch (e) {
      logger.i('Error fetching total calories burned: $e');
      return 0.0;
    }
  }

  Future<void> _saveTotalCaloriesAsPoints(double totalCalories) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'points': totalCalories,
      });
    } catch (e) {
      logger.i('Error saving points: $e');
    }
  }

  // Fetch water intake
  Future<double> _fetchWaterIntake() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('water_log')
          .get();

      double totalWaterIntake = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double intake =
        data['amount'] != null ? (data['amount'] as num).toDouble() : 0.0;
        totalWaterIntake += intake;
      }

      return totalWaterIntake;
    } catch (e) {
      logger.i('Error fetching water intake: $e');
      return 0.0;
    }
  }

  // Fetch both water intake & total cals
  Future<HistoryData> _fetchHistoryData() async {
    final double waterIntake = await _fetchWaterIntake();
    final double totalCaloriesBurned = await _fetchTotalCaloriesBurned();
    return HistoryData(
      waterIntake: waterIntake,
      totalCaloriesBurned: totalCaloriesBurned,
    );
  }

  // For "other" categories (placeholder example).
  Future<Map<String, dynamic>> _fetchData(String category) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('history')
          .doc(category)
          .get();

      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>;
      } else {
        return {'message': 'No data found for $category.'};
      }
    } catch (e) {
      return {'message': 'Error fetching data: $e'};
    }
  }

  // For "Friends Involved" (placeholder example).
  Future<List<String>> _fetchFriendsData() async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('friends')
          .doc('friendList')
          .get();

      if (documentSnapshot.exists) {
        return List<String>.from(documentSnapshot.data()?['friends'] ?? []);
      } else {
        return ['No friends data found.'];
      }
    } catch (e) {
      return ['Error fetching friends data: $e'];
    }
  }

  // Helper to show the detail dialog (modal).
  // If `morePage` is provided, show a "More" button leading to that route.
  void _showHistoryDetailDialog({
    required String title,
    required String content,
    Widget? morePage,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            if (morePage != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF85C83E), // Standard green
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => morePage),
                  );
                },
                child: const Text('More'),
              ),
          ],
        );
      },
    );
  }

  // Build the main UI (no separate Scaffold!)
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // The same gradient or color used by FriendsList/Home
    final bgDecoration = !isDark
        ? const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFE7E9EF), Color(0xFF2C96CF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    )
        : const BoxDecoration(
      color: Color(0xFF1F1F1F),
    );

    return Container(
      decoration: bgDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header similar to Friends List
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'History',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Body content with FutureBuilder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.transparent : Colors.white.withOpacity(0.8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: FutureBuilder<HistoryData>(
                future: _fetchHistoryData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data.'));
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return _buildHistoryList(data, isDark);
                  } else {
                    return const Center(child: Text('No data available.'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the list of "history cards" with the new styling
  Widget _buildHistoryList(HistoryData data, bool isDark) {
    final historyData = {
      'Points Won': 150,
      'Calories Lost': data.totalCaloriesBurned,
      'Water Intake (liters)': data.waterIntake,
      'Workout Sessions': 20,
      'Challenges Won': 5,
      'Challenges Lost': 2,
      'Challenges Tied': 1,
      'Friends Involved': null, // We'll fetch on tap
      'Goals & Achievements': null,
    };

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: historyData.entries.map((entry) {
        // The string displayed in subtitle
        String subtitle = entry.value == null
            ? 'Tap to view'
            : '${entry.value}';
        // For 'Friends Involved' or 'Goals & Achievements', also show 'Tap to view'
        if (entry.key == 'Friends Involved' || entry.key == 'Goals & Achievements') {
          subtitle = 'Tap to view';
        }

        return Card(
          color: isDark ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _getIconForCategory(entry.key),
            title: Text(
              entry.key,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward,
              color: Colors.lightGreen, // Match HomePage arrow color
            ),
            onTap: () => _handleItemTap(entry.key),
          ),
        );
      }).toList(),
    );
  }

  // Helper to handle taps on each item
  Future<void> _handleItemTap(String key) async {
    if (key == 'Water Intake (liters)') {
      // Instead of navigating directly, show the modal
      _showHistoryDetailDialog(
        title: 'Water Intake',
        content: 'Here is your water intake data.\nWould you like more details?',
        morePage: const HydrationPage(), // pass the page to navigate to
      );
    } else if (key == 'Friends Involved') {
      final friendsList = await _fetchFriendsData();
      _showHistoryDetailDialog(
        title: 'Friends Involved',
        content: friendsList.join(', '),
      );
    } else if (key == 'Goals & Achievements') {
      _showHistoryDetailDialog(
        title: 'Goals & Achievements',
        content: 'View your achievements. Want to see more?',
        morePage: GoalCompletionPage(),
      );
    } else if (key == 'Workout Sessions') {
      _showHistoryDetailDialog(
        title: 'Workout Sessions',
        content: 'Number of total workouts: 20.\nMore details?',
        morePage: const WorkoutHistoryPage(),
      );
    } else {
      // For other categories, e.g. Points Won, Calories Lost, etc.
      final data = await _fetchData(key);
      _showHistoryDetailDialog(
        title: key,
        content: data.toString(),
      );
    }
  }

  // Icon for each category
  Widget _getIconForCategory(String category) {
    switch (category) {
      case 'Points Won':
        return const Icon(Icons.star, color: Colors.amber);
      case 'Calories Lost':
        return const Icon(Icons.local_fire_department, color: Colors.redAccent);
      case 'Water Intake (liters)':
        return const Icon(Icons.local_drink, color: Colors.blue);
      case 'Workout Sessions':
        return const Icon(Icons.fitness_center, color: Colors.green);
      case 'Challenges Won':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Challenges Lost':
        return const Icon(Icons.cancel, color: Colors.red);
      case 'Challenges Tied':
        return const Icon(Icons.exposure, color: Colors.grey);
      case 'Friends Involved':
        return const Icon(Icons.people, color: Colors.teal);
      case 'Goals & Achievements':
        return const Icon(Icons.emoji_events, color: Colors.orange);
      default:
        return const Icon(Icons.help, color: Colors.black);
    }
  }
}
