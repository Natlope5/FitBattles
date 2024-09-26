import 'package:flutter/material.dart';

class StrengthWorkoutPage extends StatelessWidget {
  const StrengthWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strength Workout'),
      ),
      body: const Center(
        child: Text(
          'Strength Workout Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
