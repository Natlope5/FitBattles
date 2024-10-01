import 'package:flutter/material.dart'; // Importing Flutter material package for UI components

class DistanceWorkoutPage extends StatelessWidget {
  const DistanceWorkoutPage({super.key}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distance Workout'), // Title of the app bar
      ),
      body: const Center( // Center widget to align content
        child: Text(
          'Distance Workout Page', // Text displayed in the center
          style: TextStyle(fontSize: 24), // Font size for the text
        ),
      ),
    );
  }
}
