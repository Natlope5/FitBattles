import 'dart:convert'; // For encoding and decoding JSON
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For shared preferences

class CustomWorkoutPlanPage extends StatefulWidget {
  const CustomWorkoutPlanPage({super.key});

  @override
  CustomWorkoutPlanPageState createState() => CustomWorkoutPlanPageState();
}

class CustomWorkoutPlanPageState extends State<CustomWorkoutPlanPage>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _exercises = [];
  final TextEditingController _planNameController = TextEditingController();
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool _showAddExercise = false;
  final logger = Logger();
  List<String> logMessages = [];

  @override
  void dispose() {
    _planNameController.dispose();
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Function to add exercises
  void _addExercise() {
    if (_exerciseNameController.text.isEmpty ||
        _setsController.text.isEmpty ||
        _repsController.text.isEmpty ||
        _weightController.text.isEmpty) {
      logger.w("Exercise fields cannot be empty");
      setState(() {
        logMessages.add("Exercise fields cannot be empty");
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() {
      _exercises.add({
        'name': _exerciseNameController.text,
        'sets': int.tryParse(_setsController.text) ?? 0,
        'reps': int.tryParse(_repsController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
      });
      _exerciseNameController.clear();
      _setsController.clear();
      _repsController.clear();
      _weightController.clear();
      _showAddExercise = true;

      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _showAddExercise = false;
        });
      });
    });
  }

  // Function to save the workout plan to shared preferences
  void _saveWorkoutPlan() async {
    final messenger = ScaffoldMessenger.of(context);

    if (_planNameController.text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter a workout plan name.')),
      );
      return;
    }

    final workoutPlan = {
      'name': _planNameController.text,
      'exercises': _exercises,
    };

    try {
      // Get shared preferences instance
      final prefs = await SharedPreferences.getInstance();
      // Convert the workout plan to a JSON string
      String jsonPlan = json.encode(workoutPlan);
      // Save the workout plan string to shared preferences
      await prefs.setString('custom_workout_plan', jsonPlan);

      messenger.showSnackBar(
        const SnackBar(content: Text('Workout Plan Saved!')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to save workout plan: $error')),
      );
    }
  }

  // Function to load workout plan from shared preferences
  void _loadWorkoutPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonPlan = prefs.getString('custom_workout_plan');

    if (jsonPlan != null) {
      final planData = json.decode(jsonPlan);

      setState(() {
        _planNameController.text = planData['name'] ?? '';
        _exercises.clear();
        _exercises.addAll(
            List<Map<String, dynamic>>.from(planData['exercises']));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlan(); // Load the saved workout plan when the page is loaded
  }

  @override
  Widget build(BuildContext context) {
    // Check for current theme brightness
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Workout Plan"),
        backgroundColor: const Color(0xFF5D6C8A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _planNameController,
              decoration: InputDecoration(
                labelText: "Workout Plan Name",
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.black,
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showAddExercise = !_showAddExercise;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF85C83E),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Add Exercise",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.black : Colors.white,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _showAddExercise ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        children: [
                          TextField(
                            controller: _exerciseNameController,
                            decoration: const InputDecoration(
                              labelText: "Exercise Name",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.black,
                            ),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _setsController,
                                  decoration: const InputDecoration(
                                    labelText: "Sets",
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.black,
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _repsController,
                                  decoration: const InputDecoration(
                                    labelText: "Reps",
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.black,
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(
                                    labelText: "Weight (kg)",
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.black,
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _addExercise,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5D6C8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "Add Exercise",
                              style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.black),
            Text(
              "Exercises",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,  color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 10),
            ..._exercises.map((exercise) => ListTile(
              title: Text(
                exercise['name'],
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black, // Adjust text color
                ),
              ),
              subtitle: Text(
                "Sets: ${exercise['sets']}, Reps: ${exercise['reps']}, Weight: ${exercise['weight']} kg",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black, // Adjust subtitle color
                ),
              ),
            )),
            const Divider(color: Colors.black),
            ElevatedButton(
              onPressed: _saveWorkoutPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF85C83E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Save Workout Plan",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
