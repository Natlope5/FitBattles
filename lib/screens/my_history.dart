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
      'Friends Involved': ['Alice', 'Bob', 'Charlie'],
    };

    return Scaffold(
      appBar: AppBar(
          title: const Text('My History'),
          backgroundColor: Color(0xFF5D6C8A)
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
                children: historyData.entries.map((entry) {
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
                        ),
                      ),
                      subtitle: Text(
                        '${entry.value}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.teal[300],
                      ),
                    ),
                  );
                }).toList()
                  ..add(
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.group, color: Colors.blueAccent),
                        title: const Text(
                          'Friends Involved',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          (historyData['Friends Involved'] as List<String>?)
                              ?.join(', ') ??
                              'None',
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.teal[300],
                        ),
                      ),
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to get icons for different categories
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