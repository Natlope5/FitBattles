import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:provider/provider.dart';
import 'package:fitbattles/settings/theme_provider.dart'; // Import your ThemeProvider

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  AddGoalPageState createState() => AddGoalPageState();
}

class AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveGoal() async {
    final String goalName = _goalNameController.text.trim();
    final double? goalAmount = double.tryParse(_goalAmountController.text.trim());

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

      try {
        // Save goal to Firestore
        DocumentReference docRef = await _firestore.collection('goals').add(newGoal);
        newGoal['id'] = docRef.id; // Save the document ID
        goalHistory.add(jsonEncode(newGoal));

        // Save back to SharedPreferences
        await prefs.setStringList('currentGoals', goalHistory);
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Goal added successfully!')),
        );
      } catch (error) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error adding goal: $error')),
        );
      }

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Goal'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goal Name:',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              TextField(
                controller: _goalNameController,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter goal name',
                  hintStyle: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Goal Amount:',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              TextField(
                controller: _goalAmountController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., 10 (km, reps, etc.)',
                  hintStyle: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveGoal, // No need to pass the key
                child: const Text('Save Goal'),
              ),
            ],
          ),
        ),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }
}
