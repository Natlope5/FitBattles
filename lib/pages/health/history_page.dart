import 'package:fitbattles/pages/workouts/workout_history_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';
import 'hydration_page.dart';
import 'package:fitbattles/pages/goals/goals_completion_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHistoryPage extends StatefulWidget {
  const MyHistoryPage({super.key});

  @override
  MyHistoryPageState createState() => MyHistoryPageState();
}

// Data class to hold history data
class HistoryData {
  final double waterIntake;
  final double totalCaloriesBurned;

  HistoryData({required this.waterIntake, required this.totalCaloriesBurned});
}

class MyHistoryPageState extends State<MyHistoryPage> {
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
        double calories = data['calories'] != null ? (data['calories'] as num).toDouble() : 0.0;
        totalCalories += calories;
      }

      await _saveTotalCaloriesAsPoints(totalCalories);
      return totalCalories;
    } catch (e) {
      logger.i('Error fetching total calories burned: $e');
      return 0.0;
    }
  }

  // Fetch both water intake and total calories burned
  Future<HistoryData> _fetchHistoryData() async {
    final double waterIntake = await _fetchWaterIntake();
    final double totalCaloriesBurned = await _fetchTotalCaloriesBurned();
    return HistoryData(
      waterIntake: waterIntake,
      totalCaloriesBurned: totalCaloriesBurned,
    );
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

  // Fetch water intake from the user's water_log sub-collection
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
        double intake = data['amount'] != null ? (data['amount'] as num).toDouble() : 0.0;
        totalWaterIntake += intake;
      }

      return totalWaterIntake;
    } catch (e) {
      logger.i('Error fetching water intake: $e');
      return 0.0;
    }
  }

  // Fetch data for a specific category
  Future<Map<String, dynamic>> _fetchData(String category) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('history') // Ensure you have a collection named 'history'
          .doc(category) // Assuming the document ID matches the category
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

  // Fetch friends data
  Future<List<String>> _fetchFriendsData() async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('friends') // Ensure you have a collection named 'friends'
          .doc('friendList') // Assuming the document ID is 'friendList'
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

  // Show dialog for detailed information
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Build the main UI of the History Page
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My History'),
        backgroundColor: const Color(0xFF5D6C8A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF5D6C8A),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<HistoryData>(
                future: _fetchHistoryData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data.'));
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return ListView(
                      children: _buildHistoryCards(data.waterIntake, data.totalCaloriesBurned, isDarkMode),
                    );
                  } else {
                    return const Center(child: Text('No data available.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the history cards dynamically
  List<Widget> _buildHistoryCards(double waterIntake, double totalCaloriesBurned, bool isDarkMode) {
    final historyData = {
      'Points Won': 150,
      'Calories Lost': totalCaloriesBurned,
      'Water Intake (liters)': waterIntake,
      'Workout Sessions': 20,
      'Challenges Won': 5,
      'Challenges Lost': 2,
      'Challenges Tied': 1,
      'Friends Involved': [], // This will be fetched on tap
      'Goals & Achievements': 'View your achievements',
    };

    return historyData.entries.map((entry) {
      return Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: _getIconForCategory(entry.key),
          title: Text(
            entry.key,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            entry.key == 'Friends Involved' || entry.key == 'Goals & Achievements'
                ? 'Tap to view'
                : '${entry.value}',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.teal,
          ),
          onTap: () async {
            if (entry.key == 'Water Intake (liters)') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HydrationPage(),
                ),
              );
            } else if (entry.key == 'Friends Involved') {
              final friendsList = await _fetchFriendsData();
              _showDialog('Friends Involved', friendsList.join(', '));
            } else if (entry.key == 'Goals & Achievements') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalCompletionPage(),
                ),
              );
            } else if (entry.key == 'Workout Sessions') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutHistoryPage(),
                ),
              );
            } else {
              final data = await _fetchData(entry.key);
              _showDialog(entry.key, data.toString());
            }
          },
        ),
      );
    }).toList();
  }

  // Get icon for each category
  Icon _getIconForCategory(String category) {
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