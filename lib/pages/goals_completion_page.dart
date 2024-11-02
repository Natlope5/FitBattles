import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GoalCompletionPage extends StatefulWidget {
  const GoalCompletionPage({super.key});

  @override
  _GoalCompletionPageState createState() => _GoalCompletionPageState();
}

class _GoalCompletionPageState extends State<GoalCompletionPage> {
  List<Map<String, dynamic>> _completedGoals = [];
  int _completedGoalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCompletedGoals();
  }

  Future<void> _loadCompletedGoals() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? savedGoals = prefs.getStringList('currentGoals');

    if (savedGoals != null) {
      final goals = savedGoals
          .map((goal) => jsonDecode(goal) as Map<String, dynamic>)
          .toList();

      setState(() {
        _completedGoals =
            goals.where((goal) => goal['isCompleted'] == true).toList();
        _completedGoalCount = _completedGoals.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Goals Completed: $_completedGoalCount',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _completedGoals.length,
                itemBuilder: (context, index) {
                  final goal = _completedGoals[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(goal['name']),
                      subtitle: Text(
                          'Completed: ${goal['currentProgress']} / ${goal['amount']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}