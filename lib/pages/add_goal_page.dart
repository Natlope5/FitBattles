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

    if (goalName.isNotEmpty && goalAmount != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> goalHistory = prefs.getStringList('currentGoals') ?? [];

      final newGoal = {
        'name': goalName,
        'amount': goalAmount,
        'currentProgress': 0.0,
        'isCompleted': false,
      };

      goalHistory.add(jsonEncode(newGoal));
      await prefs.setStringList('currentGoals', goalHistory);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal added successfully!')),
        );
      }

      _goalNameController.clear();
      _goalAmountController.clear();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid goal name and amount.')),
        );
      }
    }
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
              decoration: const InputDecoration(hintText: 'Enter a number'),
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
