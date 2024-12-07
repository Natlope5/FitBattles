import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CaloriesPage extends StatefulWidget {
  const CaloriesPage({super.key});

  @override
  State<CaloriesPage> createState() => _CaloriesPageState();
}

class _CaloriesPageState extends State<CaloriesPage> {
  // List to store activity data (name, calories, and icon)
  final List<Map<String, dynamic>> _activities = [
    {'name': 'Yoga', 'calories': '500 KCal', 'icon': Icons.self_improvement},
    {'name': 'Aerobics', 'calories': '300 KCal', 'icon': Icons.fitness_center},
    {'name': 'Weight Lifting', 'calories': '400 KCal', 'icon': Icons.directions_run},
    {'name': 'Dance', 'calories': '350 KCal', 'icon': Icons.directions_bike},
  ];

  // Function to add a new activity
  void _addActivity() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Activity Name'),
              ),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(labelText: 'Calories Burned'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), // Close dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _activities.add({
                    'name': nameController.text,
                    'calories': '${caloriesController.text} KCal',
                    'icon': Icons.fitness_center, // Default icon
                  });
                });
                Navigator.pop(ctx); // Close dialog
              },
              child: const Text('Add'),
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
        backgroundColor: const Color(0xFF5D6C8A),
        title: Text(
          _formattedDate(),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.fitness_center, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // Dynamic Graph Section
          Expanded(
            flex: 6,
            child: Container(
              color: const Color(0xFF5D6C8A),
              child: Lottie.asset(
                'assets/animations/graph2.json',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Dynamic Activities Section
          Expanded(
            flex: 5,
            child: ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return ListTile(
                  leading: Icon(activity['icon'], color: const Color(0xFF5D6C8A)),
                  title: Text(
                    activity['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    activity['calories'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF85C83E),
        onPressed: _addActivity, // Trigger add activity dialog
        child: const Icon(Icons.add),
      ),
    );
  }

  // Display today's date dynamically
  String _formattedDate() {
    final now = DateTime.now();
    return '${now.day} ${_monthName(now.month)}';
  }

  // Helper function to format month name
  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
