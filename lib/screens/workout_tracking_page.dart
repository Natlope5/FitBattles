import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorkoutTrackingPage extends StatefulWidget {
  const WorkoutTrackingPage({super.key});

  @override
  WorkoutTrackingPageState createState() => WorkoutTrackingPageState();
}

class WorkoutTrackingPageState extends State<WorkoutTrackingPage> {
  bool isWorkingOut = false;
  Duration workoutDuration = Duration.zero;
  final TextEditingController _calorieController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<int> _calorieLogs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.workoutTrackerTitle), // Title from app_strings.dart
        backgroundColor: AppColors.appBarColor, // Color from app_colors.dart
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                AppStrings.workoutTypeStrength, // Title from app_strings.dart
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                _formatDuration(workoutDuration),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isWorkingOut) {
                          isWorkingOut = false;
                          // Stop the timer
                          workoutDuration = Duration.zero; // Reset duration
                        } else {
                          isWorkingOut = true;
                          // Start timer
                          _startTimer();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(isWorkingOut ? AppStrings.pause : AppStrings.start), // Button text from app_strings.dart
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        workoutDuration = Duration.zero; // Reset duration
                        isWorkingOut = false; // Stop the workout
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(AppStrings.stop), // Button text from app_strings.dart
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      AppStrings.enterCaloriesBurned, // Text from app_strings.dart
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _calorieController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: AppStrings.caloriesHint, // Hint from app_strings.dart
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.calorieValueError; // Error message from app_strings.dart
                        }
                        if (int.tryParse(value) == null) {
                          return AppStrings.validNumberError; // Error message from app_strings.dart
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final int calories = int.parse(_calorieController.text);
                          setState(() {
                            _calorieLogs.add(calories);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${AppStrings.caloriesLogged}: $calories')), // SnackBar message from app_strings.dart
                          );
                          _calorieController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(AppStrings.logCalories), // Button text from app_strings.dart
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${AppStrings.totalCaloriesBurned}: ${_calculateTotalCalories()}', // Text from app_strings.dart
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.caloriesLog, // Text from app_strings.dart
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _calorieLogs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${_calorieLogs[index]} ${AppStrings.calories}'), // Log entry from app_strings.dart
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _calorieLogs.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.calorieLogCleared)), // SnackBar message from app_strings.dart
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text(AppStrings.clearLog), // Button text from app_strings.dart
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.workoutIntensityModerate, // Text from app_strings.dart
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    // Start a timer to increment workoutDuration
    Future.delayed(const Duration(seconds: 1), () {
      if (isWorkingOut) {
        setState(() {
          workoutDuration += const Duration(seconds: 1);
        });
        _startTimer(); // Recursively call to continue the timer
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  int _calculateTotalCalories() {
    return _calorieLogs.fold(0, (sum, calories) => sum + calories);
  }
}
