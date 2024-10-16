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
        title: const Text(AppStrings.workoutTrackerTitle), // Use a string from app_strings.dart
        backgroundColor: AppColors.appBarColor, // Use a color from app_colors.dart
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                AppStrings.workoutTypeStrength, // Use a string from app_strings.dart
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
                        isWorkingOut = !isWorkingOut;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(isWorkingOut ? AppStrings.pause : AppStrings.start), // Use strings from app_strings.dart
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        workoutDuration = Duration.zero;
                        isWorkingOut = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(AppStrings.stop), // Use a string from app_strings.dart
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
                      AppStrings.enterCaloriesBurned, // Use a string from app_strings.dart
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _calorieController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: AppStrings.caloriesHint, // Use a string from app_strings.dart
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.calorieValueError; // Use a string from app_strings.dart
                        }
                        if (int.tryParse(value) == null) {
                          return AppStrings.validNumberError; // Use a string from app_strings.dart
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
                            SnackBar(content: Text('${AppStrings.caloriesLogged}: $calories')), // Use a string from app_strings.dart
                          );
                          _calorieController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(AppStrings.logCalories), // Use a string from app_strings.dart
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${AppStrings.totalCaloriesBurned}: ${_calculateTotalCalories()}', // Use a string from app_strings.dart
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.caloriesLog, // Use a string from app_strings.dart
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _calorieLogs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${_calorieLogs[index]} ${AppStrings.calories}'), // Use a string from app_strings.dart
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
                    const SnackBar(content: Text(AppStrings.calorieLogCleared)), // Use a string from app_strings.dart
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text(AppStrings.clearLog), // Use a string from app_strings.dart
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.workoutIntensityModerate, // Use a string from app_strings.dart
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
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
