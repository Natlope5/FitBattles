import 'package:fitbattles/screens/workout_history_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hydration_page.dart';
import 'package:fitbattles/screens/goals_completion_page.dart';

class MyHistoryPage extends StatefulWidget {
  const MyHistoryPage({super.key});

  @override
  MyHistoryPageState createState() => MyHistoryPageState();
}

class MyHistoryPageState extends State<MyHistoryPage> {
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
          backgroundColor: Theme.of(context).dialogBackgroundColor, // Dynamic dialog background
          title: Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
          content: Text(content, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
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

  // Fetch and display water intake data
  Future<double> _fetchWaterIntake() async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('history')
        .doc('waterIntake')
        .get();

    if (documentSnapshot.exists) {
      return documentSnapshot.data()?['intake'] ?? 0.0; // Default to 0.0 if not found
    }
    return 0.0;
  }

  // Build the main UI of the History Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My History'),
        backgroundColor: Theme.of(context).primaryColor, // Dynamic app bar color
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
                color: Theme.of(context).textTheme.bodyLarge!.color, // Dynamic text color
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<double>(
                future: _fetchWaterIntake(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching water intake.'));
                  } else if (snapshot.hasData) {
                    final waterIntake = snapshot.data!;
                    return ListView(
                      children: _buildHistoryCards(waterIntake),
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
  List<Widget> _buildHistoryCards(double waterIntake) {
    final historyData = {
      'Points Won': 150,
      'Calories Lost': 1200,
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
        color: Theme.of(context).cardColor, // Dynamic card background color
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
              color: Theme.of(context).textTheme.bodyLarge!.color, // Dynamic text color
            ),
          ),
          subtitle: Text(
            entry.key == 'Friends Involved' || entry.key == 'Goals & Achievements'
                ? 'Tap to view'
                : '${entry.value}',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium!.color, // Dynamic subtitle text color
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.teal,
          ),
          onTap: () async {
            if (entry.key == 'Water Intake (liters)') {
              // Navigate to the HydrationPage
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
              // Navigate to the GoalCompletionPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalCompletionPage(userToken: '',),
                ),
              );
            } else if (entry.key == 'Workout Sessions') {
              // Navigate to the WorkoutTrackingPage
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
        return const Icon(Icons.local_drink, color: Colors.lightBlueAccent);
      case 'Workout Sessions':
        return const Icon(Icons.fitness_center, color: Colors.green);
      case 'Challenges Won':
        return const Icon(Icons.emoji_events, color: Colors.orangeAccent);
      case 'Challenges Lost':
        return const Icon(Icons.sentiment_dissatisfied, color: Colors.grey);
      case 'Challenges Tied':
        return const Icon(Icons.thumbs_up_down, color: Colors.blueGrey);
      case 'Goals & Achievements':
        return const Icon(Icons.flag, color: Colors.blueAccent); // Icon for Goals
      default:
        return const Icon(Icons.help_outline, color: Colors.teal);
    }
  }
}
