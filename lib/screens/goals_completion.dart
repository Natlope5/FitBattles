import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color primary = Color(0xFF5D6C8A);
  static const Color buttonColor = Color(0xFF85C83E);
  static const Color background = Color(0xFFEFEFEF);
  static const Color zenTextColor = Color(0xFF6D8299);
}

class GoalCompletionPage extends StatefulWidget {
  const GoalCompletionPage({super.key, required String userToken});

  @override
  GoalCompletionPageState createState() => GoalCompletionPageState();
}

class GoalCompletionPageState extends State<GoalCompletionPage> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final TextEditingController _currentProgressController = TextEditingController();
  List<Map<String, dynamic>> _goalHistory = [];

  // Predefined goal recommendations
  final List<String> _recommendedGoals = [
    "Run 5 kilometers",
    "Drink 2 liters of water",
    "Complete 10,000 steps",
    "Lose 5 pounds",
    "Strength training for 1 hour",
  ];

  @override
  void initState() {
    super.initState();
    _loadGoalHistory(); // Load goal history on page load
  }

  // Save goals to local storage
  Future<void> _saveGoalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('goalHistory', jsonEncode(_goalHistory));
  }

  // Load goals from local storage
  Future<void> _loadGoalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGoals = prefs.getString('goalHistory');
    if (savedGoals != null) {
      setState(() {
        _goalHistory = List<Map<String, dynamic>>.from(jsonDecode(savedGoals));
      });
    }
  }

  // Clear goal history
  Future<void> _clearGoalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('goalHistory');
    setState(() {
      _goalHistory.clear();
    });
  }

  // Add a new goal
  void _addGoal() {
    final String goalName = _goalNameController.text;
    final String goalAmount = _goalAmountController.text;
    if (goalName.isNotEmpty && goalAmount.isNotEmpty) {
      setState(() {
        _goalHistory.add({
          'name': goalName,
          'amount': double.tryParse(goalAmount) ?? 0.0,
          'currentProgress': 0.0, // Initialize current progress
        });
        _goalNameController.clear();
        _goalAmountController.clear();
        _currentProgressController.clear(); // Clear progress controller
      });
      _saveGoalHistory(); // Save updated goal history
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both goal name and amount.')),
      );
    }
  }

  // Update progress for a specific goal
  void _updateProgress(int index) {
    final currentProgress = double.tryParse(_currentProgressController.text) ?? 0.0;
    setState(() {
      if (currentProgress + _goalHistory[index]['currentProgress'] <= _goalHistory[index]['amount']) {
        _goalHistory[index]['currentProgress'] += currentProgress;
        _currentProgressController.clear(); // Clear input after updating
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress exceeds goal amount.')),
        );
      }
    });
    _saveGoalHistory(); // Save updated goal history
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Completion'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearGoalHistory, // Clear the goal history
          ),
        ],
      ),
      body: SingleChildScrollView( // Make the entire content scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
          children: [
            // Set a New Goal section
            const Text(
              'Set a New Goal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _goalNameController,
              decoration: const InputDecoration(
                labelText: 'Goal Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _goalAmountController,
              decoration: const InputDecoration(
                labelText: 'Goal Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _currentProgressController,
              decoration: const InputDecoration(
                labelText: 'Current Progress',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              ),
              child: const Text('Add Goal'),
            ),
            const SizedBox(height: 20),
            const Divider(),

            // Goal recommendation section
            const Text(
              'Goal Recommendations',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _recommendedGoals.map((goal) {
                return ActionChip(
                  label: Text(goal),
                  onPressed: () => _goalNameController.text = goal,
                  backgroundColor: AppColors.buttonColor,
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Divider(),

            // Goal history section
            const Text(
              'Goal Achievements',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _goalHistory.isEmpty
                ? const Center(child: Text('No goals set yet.'))
                : ListView.builder(
              shrinkWrap: true, // To prevent overflow
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling for inner list
              itemCount: _goalHistory.length,
              itemBuilder: (context, index) {
                final goal = _goalHistory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(goal['name']),
                    subtitle: Text('Goal Amount: ${goal['amount']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Progress: ${goal['currentProgress'].toStringAsFixed(1)} / ${goal['amount']}'),
                        SizedBox(
                          height: 10,
                          child: LinearProgressIndicator(
                            value: goal['currentProgress'] / goal['amount'],
                            backgroundColor: Colors.grey[300],
                            color: AppColors.buttonColor,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _updateProgress(index), // Update progress on tap
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
