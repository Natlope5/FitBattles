import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart'; // Import Provider to use ThemeProvider
import 'package:fitbattles/settings/theme_provider.dart'; // Assuming ThemeProvider is defined in this file

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  AddGoalPageState createState() => AddGoalPageState();
}

class AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> _saveGoal() async {
    final String goalName = _goalNameController.text;
    final double? goalAmount = double.tryParse(_goalAmountController.text);

    if (goalName.isNotEmpty && goalAmount != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? goalHistory = prefs.getStringList('currentGoals') ?? [];

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

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Goal added successfully!')),
      );

      // Clear inputs
      _goalNameController.clear();
      _goalAmountController.clear();
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Please enter valid goal name and amount.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access the ThemeProvider

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Add New Goal')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goal Name:',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black, // Adjust text color based on theme
                ),
              ),
              TextField(
                controller: _goalNameController,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black, // Adjust input text color based on theme
                ),
                decoration: InputDecoration(
                  hintText: 'Enter goal name',
                  hintStyle: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white60 : Colors.black54, // Adjust hint text color based on theme
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Goal Amount:',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black, // Adjust text color based on theme
                ),
              ),
              TextField(
                controller: _goalAmountController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black, // Adjust input text color based on theme
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., 10 (km, reps, etc.)',
                  hintStyle: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white60 : Colors.black54, // Adjust hint text color based on theme
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveGoal,
                child: const Text('Save Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
