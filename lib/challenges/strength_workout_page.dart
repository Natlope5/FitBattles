import 'package:flutter/material.dart'; // Importing the Flutter Material package for UI components

// This widget represents a page for strength workouts.
class StrengthWorkoutPage extends StatelessWidget {
  const StrengthWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strength Workout'), // Title of the AppBar
      ),
      body: const Center( // Center widget to align its child within the body
        child: Text(
          'Strength Workout Page', // Text to display on the page
          style: TextStyle(fontSize: 24), // Styling for the text (font size)
        ),
      ),
    );
  }
}
