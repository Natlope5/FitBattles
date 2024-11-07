import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  AddGoalPageState createState() => AddGoalPageState();
}

class AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();

  Future<void> _saveGoal() async {
    final String goalName = _goalNameController.text;
    final double? goalAmount = double.tryParse(_goalAmountController.text);

    String message;

    if (goalName.isNotEmpty && goalAmount != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> goalHistory = prefs.getStringList('currentGoals') ?? [];

      // Add new goal to the list
      final newGoal = {
        'name': goalName,
        'amount': goalAmount,
        'currentProgress': 0.0,
        'isCompleted': false,
      };

      goalHistory.add(jsonEncode(newGoal));

      // Save back to SharedPreferences
      await prefs.setStringList('currentGoals', goalHistory);

      message = 'Goal added successfully!';

      // Clear inputs
      _goalNameController.clear();
      _goalAmountController.clear();
    } else {
      message = 'Please enter valid goal name and amount.';
    }

    // Ensure the widget is still mounted before accessing context
    if (!mounted) return;

    // Show the message in a snackbar after async operations are done
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Goal Name:', style: TextStyle(fontSize: 16)),
            TextField(controller: _goalNameController),
            const SizedBox(height: 16),
            const Text('Goal Amount:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _goalAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g., 10 (km, reps, etc.)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveGoal,
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }
}