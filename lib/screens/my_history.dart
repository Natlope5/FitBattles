import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHistoryPage extends StatefulWidget {
  const MyHistoryPage({super.key});

  @override
  MyHistoryPageState createState() => MyHistoryPageState();
}

class MyHistoryPageState extends State<MyHistoryPage> {
  Future<Map<String, dynamic>> _fetchData(String category) async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('history') // Ensure you have a collection named 'history'
        .doc(category) // Assuming the document ID matches the category
        .get();

    if (documentSnapshot.exists) {
      return documentSnapshot.data() as Map<String, dynamic>;
    } else {
      return {'message': 'No data found for $category.'};
    }
  }

  Future<List<String>> _fetchFriendsData() async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('friends') // Ensure you have a collection named 'friends'
        .doc('friendList') // Assuming the document ID is 'friendList'
        .get();

    if (documentSnapshot.exists) {
      return List<String>.from(documentSnapshot.data()?['friends'] ?? []);
    } else {
      return ['No friends data found.'];
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context, // Only use context here for the dialog
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

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D6C8A),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _buildHistoryCards(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHistoryCards() {
    final historyData = {
      'Points Won': 150,
      'Calories Lost': 1200,
      'Water Intake (liters)': 2.5,
      'Workout Sessions': 20,
      'Challenges Won': 5,
      'Challenges Lost': 2,
      'Challenges Tied': 1,
      'Friends Involved': [],
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Set title text color to black
            ),
          ),
          subtitle: Text(
            entry.key == 'Friends Involved'
                ? 'Tap to fetch friends data'
                : '${entry.value}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black, // Set subtitle text color to black
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.teal,
          ),
          onTap: () async {
            if (entry.key == 'Friends Involved') {
              final friendsList = await _fetchFriendsData();
              _showDialog('Friends Involved', friendsList.join(', '));
            } else {
              final data = await _fetchData(entry.key);
              _showDialog(entry.key, data.toString());
            }
          },
        ),
      );
    }).toList();
  }


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
      default:
        return const Icon(Icons.help_outline, color: Colors.teal);
    }
  }
}
