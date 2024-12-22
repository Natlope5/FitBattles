import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class WorkoutTrackingPage extends StatefulWidget {
  const WorkoutTrackingPage({super.key});

  @override
  WorkoutTrackingPageState createState() => WorkoutTrackingPageState();
}

class WorkoutTrackingPageState extends State<WorkoutTrackingPage> with TickerProviderStateMixin {
  bool isWorkingOut = false;
  Duration workoutDuration = Duration.zero;
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String selectedWorkoutType = 'Weightlifting';
  String selectedIntensity = 'Moderate';
  double userWeight = 70.0;
  final Logger logger = Logger();
  final List<String> workoutTypes = [
    'Running', 'Weightlifting', 'Cycling', 'Swimming', 'Yoga', 'Walking'
  ];
  final List<String> workoutIntensities = ['Light', 'Moderate', 'Vigorous'];
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimation = CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  double estimateCaloriesBurned(String workoutType, String intensity, double durationInHours, double weightInKg) {
    Map<String, double> metValues = {
      'Running': 11.0, 'Weightlifting': 6.0, 'Cycling': 8.0,
      'Swimming': 7.0, 'Yoga': 3.0, 'Walking': 3.8,
    };
    double intensityMultiplier = intensity == 'Light' ? 0.75 : (intensity == 'Vigorous' ? 1.25 : 1.0);
    double met = metValues[workoutType] ?? 1.0;
    return met * weightInKg * durationInHours * intensityMultiplier;
  }

  int calculatePoints(double calories) {
    return (calories / 10).round();
  }

  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _saveWorkoutData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      double caloriesBurned = double.tryParse(_calorieController.text) ?? 0.0;
      if (caloriesBurned <= 0.0) {
        showSnackBar('Please enter valid calories burned');
        return;
      }
      int points = calculatePoints(caloriesBurned);
      Map<String, dynamic> workoutData = {
        'workoutType': selectedWorkoutType,
        'intensity': selectedIntensity,
        'duration': int.parse(_durationController.text),
        'calories': caloriesBurned,
        'points': points,
        'timestamp': Timestamp.now(),
      };
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('workouts').add(workoutData);
      showSnackBar('Workout data saved successfully!');
      logger.i('Workout data saved: $workoutData');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lastCalories', caloriesBurned);
      await prefs.setInt('lastPoints', points);
      _durationController.clear();
      _calorieController.clear();
    } catch (e) {
      showSnackBar('Error saving workout data: $e');
      logger.e('Error saving workout data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final List<String> workoutTips = [
      "Try increasing your reps to boost strength.",
      "Add 5 minutes of cardio to improve stamina.",
      "Focus on form for better results and avoid injuries.",
      "Challenge yourself with a new HIIT workout!",
      "Incorporate rest days for muscle recovery."
    ];
    String selectedTip = workoutTips[random.nextInt(workoutTips.length)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Track Your Workout',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildDropdownCard(
              label: 'Select Workout Type',
              value: selectedWorkoutType,
              items: workoutTypes,
              onChanged: (value) {
                setState(() {
                  selectedWorkoutType = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildDropdownCard(
              label: 'Select Workout Intensity',
              value: selectedIntensity,
              items: workoutIntensities,
              onChanged: (value) {
                setState(() {
                  selectedIntensity = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildInputCard(
              label: 'Workout Duration (minutes)',
              controller: _durationController,
              hintText: 'Enter duration in minutes',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildInputCard(
              label: 'Calories Burned',
              controller: _calorieController,
              hintText: 'Enter calories burned',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _buttonAnimation,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await _saveWorkoutData();
                      }
                    },
                    child: Text(
                      'Save Workout',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Workout Tip',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedTip,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCard({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
