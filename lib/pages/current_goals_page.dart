import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CurrentGoalsPage extends StatefulWidget {
  const CurrentGoalsPage({super.key});

  @override
  _CurrentGoalsPageState createState() => _CurrentGoalsPageState();
}

class _CurrentGoalsPageState extends State<CurrentGoalsPage> {
  List<Map<String, dynamic>> _currentGoals = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentGoals();
  }

  Future<void> _loadCurrentGoals() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? savedGoals = prefs.getStringList('currentGoals');

    if (savedGoals != null) {
      setState(() {
        _currentGoals = savedGoals
            .map((goal) => jsonDecode(goal) as Map<String, dynamic>) // Ensure the correct type
            .toList();
      });
    }
  }

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
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(goal['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress: ${goal['currentProgress']} / ${goal['amount']}',
                  ),
                  Slider(
                    value: goal['currentProgress'],
                    min: 0,
                    max: goal['amount'],
                    onChanged: (value) {
                      _updateProgress(index, value);
                    },
                  ),
                ],
              ),
              trailing: goal['isCompleted']
                  ? const Icon(Icons.check, color: Colors.green)
                  : const Icon(Icons.pending, color: Colors.orange),
            ),
          );
        },
      ),
    );
  }
}