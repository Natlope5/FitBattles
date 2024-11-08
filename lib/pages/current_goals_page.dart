import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CurrentGoalsPage extends StatefulWidget {
  const CurrentGoalsPage({super.key});

  @override
  CurrentGoalsPageState createState() => CurrentGoalsPageState();
}

class CurrentGoalsPageState extends State<CurrentGoalsPage> {
  List<Map<String, dynamic>> _currentGoals = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentGoals();
  }

  // Load goals from SharedPreferences
  Future<void> _loadCurrentGoals() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? savedGoals = prefs.getStringList('currentGoals');

    if (savedGoals != null) {
      setState(() {
        _currentGoals = savedGoals
            .map((goal) => jsonDecode(goal) as Map<String, dynamic>) // Decode and cast to the correct type
            .toList();
      });
    }
  }

  // Update the progress of a goal
  Future<void> _updateProgress(int index, double progress) async {
    setState(() {
      _currentGoals[index]['currentProgress'] = progress;
      if (progress >= _currentGoals[index]['amount']) {
        _currentGoals[index]['isCompleted'] = true;
      }
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> updatedGoals =
    _currentGoals.map((goal) => jsonEncode(goal)).toList();
    await prefs.setStringList('currentGoals', updatedGoals);
  }

  // Delete a goal
  Future<void> _deleteGoal(int index) async {
    setState(() {
      _currentGoals.removeAt(index); // Remove the goal from the list
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> updatedGoals =
    _currentGoals.map((goal) => jsonEncode(goal)).toList();
    await prefs.setStringList('currentGoals', updatedGoals); // Update SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Current Goals')),
      body: _currentGoals.isEmpty
          ? const Center(child: Text('No goals set.'))
          : ListView.builder(
        itemCount: _currentGoals.length,
        itemBuilder: (context, index) {
          final goal = _currentGoals[index];

          // Ensure the goal data is properly initialized and handled
          double currentProgress = goal['currentProgress']?.toDouble() ?? 0.0;
          double amount = goal['amount']?.toDouble() ?? 0.0;

          // Clamp the value of currentProgress to be within the range of 0 and the amount
          currentProgress = currentProgress.clamp(0.0, amount);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(goal['name'] ?? 'Unknown Goal'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress: $currentProgress / $amount',
                  ),
                  Slider(
                    value: currentProgress,
                    min: 0,
                    max: amount,
                    onChanged: (value) {
                      _updateProgress(index, value);
                    },
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Delete button (garbage can icon)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteGoal(index),
                  ),
                  // Icon for completion status
                  goal['isCompleted'] == true
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.pending, color: Colors.orange),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
