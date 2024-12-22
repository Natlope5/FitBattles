import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CustomWorkoutPlanPage extends StatefulWidget {
  const CustomWorkoutPlanPage({super.key});

  @override
  CustomWorkoutPlanPageState createState() => CustomWorkoutPlanPageState();
}

class CustomWorkoutPlanPageState extends State<CustomWorkoutPlanPage> {
  final List<Map<String, dynamic>> _exercises = [];
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String? _selectedDay;
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final logger = Logger();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Workout Suggestions for Categories
  final Map<String, List<Map<String, String>>> _workoutSuggestions = {
    'Arms': [
      {
        'name': 'Bicep Curls',
        'description': 'Stand with feet shoulder-width apart. Curl the weights towards your shoulders, then slowly lower them back down.',
      },
      {
        'name': 'Tricep Dips',
        'description': 'Use a bench or step for support. Lower your body by bending your elbows, then push back up.',
      },
      {
        'name': 'Hammer Curls',
        'description': 'Hold dumbbells with a neutral grip and curl the weights towards your shoulders.',
      },
    ],
    'Chest': [
      {
        'name': 'Bench Press',
        'description': 'Lie on a bench and press a barbell or dumbbells upward.',
      },
      {
        'name': 'Push-Ups',
        'description': 'Lower your body until your chest almost touches the ground, then push yourself back up.',
      },
      {
        'name': 'Chest Fly',
        'description': 'Lie on a bench with dumbbells in both hands and extend arms wide, then bring them back together.',
      },
    ],
    'Abs': [
      {
        'name': 'Crunches',
        'description': 'Lie on your back with knees bent and lift your upper body towards your knees.',
      },
      {
        'name': 'Plank',
        'description': 'Hold a position similar to a push-up with your body in a straight line.',
      },
      {
        'name': 'Bicycle Crunches',
        'description': 'Lie on your back, pedal your legs in the air, and twist your torso to touch opposite elbows to knees.',
      },
    ],
    'Legs': [
      {
        'name': 'Squats',
        'description': 'Lower your hips as if sitting in a chair, keeping your knees behind your toes.',
      },
      {
        'name': 'Lunges',
        'description': 'Step forward into a lunge, lowering your hips until both knees are at 90-degree angles.',
      },
      {
        'name': 'Deadlifts',
        'description': 'With a barbell or dumbbells, hinge at the hips to lower the weights, then return to standing.',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadExercises();

    var initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final String? exercisesString = prefs.getString('exercises');
    if (exercisesString != null) {
      List<dynamic> exercisesList = jsonDecode(exercisesString);
      setState(() {
        _exercises.clear();
        _exercises.addAll(
            exercisesList.map((e) => Map<String, dynamic>.from(e)));
      });
    }
  }

  Future<void> _saveExercises() async {
    final prefs = await SharedPreferences.getInstance();
    String exercisesString = jsonEncode(_exercises);
    prefs.setString('exercises', exercisesString);
  }

  void _addExercise() {
    if (_exerciseNameController.text.isEmpty ||
        _setsController.text.isEmpty ||
        _repsController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _selectedDay == null) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    setState(() {
      _exercises.add({
        'name': _exerciseNameController.text,
        'sets': int.tryParse(_setsController.text) ?? 0,
        'reps': int.tryParse(_repsController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'day': _selectedDay,
      });
    });

    _showSnackBar('Exercise added successfully!');
    _saveExercises();
    _exerciseNameController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _selectedDay = null;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _deleteExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
    _saveExercises();
    _showSnackBar('Exercise deleted.');
  }

  void _shareWorkoutPlan() {
    final StringBuffer shareContent = StringBuffer("My Workout Plan:\n\n");
    for (var exercise in _exercises) {
      shareContent.writeln(
          "${exercise['day']}: ${exercise['name']} - ${exercise['sets']} sets x ${exercise['reps']} reps @ ${exercise['weight']} kg");
    }

    Share.share(shareContent.toString());
  }

  void _showSuggestionsDialog(String category, String description) {
    final suggestions = _workoutSuggestions[category] ?? [];
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('$category Workout Suggestions'),
            content: SizedBox(
              height: 200,
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(suggestions[index]['name']!),
                          subtitle: Text(suggestions[index]['description']!),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildCategoryCard(String title, String imagePath, String description) {
    return GestureDetector(
      onTap: () => _showSuggestionsDialog(title, description),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 60, width: 60),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Workout Plan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareWorkoutPlan,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section for adding custom exercises
            const Text(
              "Add Custom Exercise",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildExerciseForm(),
            const SizedBox(height: 20),

            // Section for displaying added exercises
            const Text(
              "Your Workout Plan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildWorkoutList(),
            const SizedBox(height: 20),

            // Section for workout suggestions
            const Text(
              "Workout Suggestions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                _buildCategoryCard(
                  'Arms',
                  'assets/images/arms.png',
                  '3 exercises targeting your biceps, triceps, and forearms.',
                ),
                _buildCategoryCard(
                  'Chest',
                  'assets/images/chest.png',
                  '3 exercises focusing on chest strength and growth.',
                ),
                _buildCategoryCard(
                  'Abs',
                  'assets/images/abs.png',
                  '3 exercises to engage your core muscles.',
                ),
                _buildCategoryCard(
                  'Legs',
                  'assets/images/legs.png',
                  '3 exercises for building leg strength and endurance.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseForm() {
    return Column(
      children: [
        // Exercise name input inside a Card
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _exerciseNameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Sets input inside a Card
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sets',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Reps input inside a Card
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Weight input inside a Card
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _weightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Day of the week dropdown inside a Card
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButton<String>(
              value: _selectedDay,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDay = newValue;
                });
              },
              hint: const Text('Select a Day'),
              isExpanded: true,
              items: _daysOfWeek
                  .map<DropdownMenuItem<String>>(
                    (String day) => DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                ),
              )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Add Exercise button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              ),
              onPressed: _addExercise,
              child: Text(
                'Add Exercise',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
    Widget _buildWorkoutList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        return ListTile(
          title: Text(exercise['name']),
          subtitle: Text(
              '${exercise['sets']} sets x ${exercise['reps']} reps @ ${exercise['weight']} kg'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteExercise(index),
          ),
        );
      },
    );
  }
}
