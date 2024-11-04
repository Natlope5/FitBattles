import 'package:fitbattles/settings/workout_plan.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

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

  // Dispose controllers to free resources
  @override
  void dispose() {
    _planNameController.dispose();
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _addExercise() {
    // Validation for empty input
    if (_exerciseNameController.text.isEmpty ||
        _setsController.text.isEmpty ||
        _repsController.text.isEmpty ||
        _weightController.text.isEmpty) {
      logger.w("Exercise fields cannot be empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // Add exercise to list
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

  void _saveWorkoutPlan() {
    final messenger = ScaffoldMessenger.of(context);

    if (_planNameController.text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter a workout plan name.')),
      );
      return;
    }

    final workoutPlan = WorkoutPlan(
      name: _planNameController.text,
      exercises: _exercises,
    );

    saveWorkoutPlan(workoutPlan).then((_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Workout Plan Saved!')),
      );
    }).catchError((error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to save workout plan: $error')),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
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
                labelStyle: TextStyle(color: const Color(0xFF85C83E)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Add Exercise",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
                              fillColor: Colors.white,
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
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _repsController,
                                  decoration: const InputDecoration(
                                    labelText: "Reps",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(
                                    labelText: "Weight (kg)",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
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
                            child: const Text("Add Exercise", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.grey),
            const Text(
              "Exercises",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._exercises.map((exercise) => ListTile(
              title: Text(exercise['name']),
              subtitle: Text(
                  "Sets: ${exercise['sets']}, Reps: ${exercise['reps']}, Weight: ${exercise['weight']} kg"),
            )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveWorkoutPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D6C8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text(
                "Save Workout Plan",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
    );
  }
}
