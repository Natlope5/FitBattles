import 'dart:convert';
import 'dart:math';
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
  List<Map<String, dynamic>> _goalHistory = [];

  // Predefined goal recommendations
  final List<String> _recommendedGoals = [
    "Run 5 kilometers",
    "Drink 2 liters of water",
    "Complete 10,000 steps",
    "Lose 5 pounds",
    "Strength training for 1 hour",
  ];

  // Inspirational quotes
  final List<String> _quotes = [
    "The journey of a thousand miles begins with one step.",
    "Be the change you wish to see in the world.",
    "Peace comes from within. Do not seek it without.",
    "Every day is a new beginning.",
    "Believe in yourself and all that you are.",
  ];

  String _randomQuote = '';

  @override
  void initState() {
    super.initState();
    _loadGoalHistory(); // Load goal history on page load
    _generateRandomQuote(); // Display a random quote on page load
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
        });
        _goalNameController.clear();
        _goalAmountController.clear();
      });
      _saveGoalHistory(); // Save updated goal history
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both goal name and amount.')),
      );
    }
  }

  // Handle selecting a recommended goal
  void _selectRecommendedGoal(String goal) {
    _goalNameController.text = goal;
  }

  // Generate a random quote
  void _generateRandomQuote() {
    final random = Random();
    setState(() {
      _randomQuote = _quotes[random.nextInt(_quotes.length)];
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Inspirational quote section
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(), // Updated to use withValues
                    spreadRadius: 3,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Zen Thought of the Day',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.zenTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _randomQuote,
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: AppColors.zenTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
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
                  onPressed: () => _selectRecommendedGoal(goal),
                  backgroundColor: AppColors.buttonColor,
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Divider(),
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

            // Goal history section
            Expanded(
              child: _goalHistory.isEmpty
                  ? const Center(
                child: Text('No goals set yet.'),
              )
                  : ListView.builder(
                itemCount: _goalHistory.length,
                itemBuilder: (context, index) {
                  final goal = _goalHistory[index];
                  return ListTile(
                    title: Text(goal['name']),
                    subtitle: Text('Goal Amount: ${goal['amount']}'),
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
