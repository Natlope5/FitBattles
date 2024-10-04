import 'package:flutter/material.dart';

class WorkoutTrackingPage extends StatefulWidget {
  const WorkoutTrackingPage({super.key});

  @override
  _WorkoutTrackingPageState createState() => _WorkoutTrackingPageState();
}

class _WorkoutTrackingPageState extends State<WorkoutTrackingPage> {
  final _formKey = GlobalKey<FormState>(); // Form key to validate input

  String workoutType = 'Strength'; // Default workout type
  int sets = 0; // Number of sets
  int reps = 0; // Number of reps
  String workoutNotes = ''; // Notes or comments about the workout

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout Details'),
        backgroundColor: const Color(0xFF5D6C8A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown to select workout type
              DropdownButtonFormField<String>(
                value: workoutType,
                onChanged: (String? newValue) {
                  setState(() {
                    workoutType = newValue!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Workout Type'),
                items: <String>['Strength', 'Cardio', 'Flexibility', 'Endurance']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Input field for sets
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Sets',
                ),
                onChanged: (value) {
                  setState(() {
                    sets = int.tryParse(value) ?? 0;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of sets';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input field for reps
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Reps',
                ),
                onChanged: (value) {
                  setState(() {
                    reps = int.tryParse(value) ?? 0;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of reps';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
















              // Input field for workout notes
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Workout Notes',
                ),
                onChanged: (value) {
                  setState(() {
                    workoutNotes = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, process the input data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Workout Logged Successfully')),
                      );
                      // You can now save the data to Firebase or process it further
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF85C83E), // Same button style
                  ),
                  child: const Text('Log Workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}