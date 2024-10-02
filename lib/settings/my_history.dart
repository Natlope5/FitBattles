import 'package:flutter/material.dart';

class MyHistoryPage extends StatelessWidget {
  const MyHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final historyData = {
      'Points Won': 150,
      'Calories Lost': 1200,
      'Water Intake (liters)': 2.5,
      'Workout Sessions': 20,
      'Challenges Won': 5,
      'Challenges Lost': 2,
      'Challenges Tied': 1,
      'Friends Involved': ['Alice', 'Bob', 'Charlie'], // Ensure this is not null
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('My History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: historyData.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 18),
              ),
            );
          }).toList()
            ..add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Friends Involved: ${(historyData['Friends Involved'] as List<String>?)?.join(', ') ?? 'None'}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
        ),
      ),
    );
  }
}