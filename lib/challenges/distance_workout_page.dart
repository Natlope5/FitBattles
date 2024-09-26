import 'package:flutter/material.dart';

class DistanceWorkoutPage extends StatelessWidget {
  const DistanceWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distance Workout'),
      ),
      body: const Center(
        child: Text(
          'Distance Workout Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
