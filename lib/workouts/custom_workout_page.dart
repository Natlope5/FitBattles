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

  // Animation flag
  bool _showAddExercise = false;

  // Initialize logger
  final logger = Logger();

  void _addExercise() {
    setState(() {
      _exercises.add({
        'name': _exerciseNameController.text,
        'sets': int.tryParse(_setsController.text) ?? 0,
        'reps': int.tryParse(_repsController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
      });

      // Clear the input fields
      _exerciseNameController.clear();
      _setsController.clear();
      _repsController.clear();
      _weightController.clear();

      // Show the added exercise animatedly
      _showAddExercise = true;
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _showAddExercise = false;
        });
      });
    });
  }

  void _saveWorkoutPlan() {
    logger.i("Workout plan saved with name: ${_planNameController.text}");
    // Save functionality can be implemented here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Workout Plan"),
        backgroundColor: const Color(0xFF5D6C8A), // Your preferred app color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Workout Plan Name Field
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

            // Animated Expandable Container for Adding Exercises
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
                      ? Colors.grey[800]?.withValues()
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Add Exercise",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                              backgroundColor: const Color(0xFF5D6C8A), // Match your theme
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

            // List of Exercises with Animated Slide
            const Text(
              "Exercises",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._exercises.map((exercise) => ListTile(
              title: Text(exercise['name'], style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                  "Sets: ${exercise['sets']}, Reps: ${exercise['reps']}, Weight: ${exercise['weight']} kg",
                  style: const TextStyle(color: Colors.grey)),
            )),
            const SizedBox(height: 20),

            // Save Workout Plan Button
            ElevatedButton(
              onPressed: _saveWorkoutPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D6C8A), // Match your theme
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
          : Colors.white, // Dark mode background
    );
  }
}
