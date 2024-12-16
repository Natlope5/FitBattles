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

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

  @override
  Widget build(BuildContext context) {
    // Check the current theme (light or dark)
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Workout Plan"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C9B9), Color(0xFF8A2BE2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareWorkoutPlan,
            tooltip: 'Share Workout Plan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C9B9), Color(0xFF8A2BE2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day of Week Dropdown
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedDay,
                    hint: Text(isDarkMode ? "Select a day" : "Select a day"),
                    items: _daysOfWeek.map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 8),
                            Text(day),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDay = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "Workout Day",
                      labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Exercise Name Input
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _exerciseNameController,
                    decoration: InputDecoration(
                      labelText: "Exercise Name",
                      labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ),
              // Sets, Reps, and Weight Input Fields
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _setsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Sets",
                          labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Reps",
                          labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Weight (kg)",
                          labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Add Exercise Button
              ElevatedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add Exercise",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C9B9),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Exercises List with AnimatedContainer for transitions
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.black.withValues()  // Use withValues for opacity
                            : Colors.black.withValues(), // Use withValues for opacity
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(
                          "${_exercises[index]['name']}",
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        subtitle: Text(
                          "${_exercises[index]['day']} - ${_exercises[index]['sets']} sets x ${_exercises[index]['reps']} reps @ ${_exercises[index]['weight']} kg",
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        trailing: IconButton(
                            color: Colors.blue,
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteExercise(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
