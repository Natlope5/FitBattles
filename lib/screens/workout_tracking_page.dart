import 'package:flutter/material.dart';

class WorkoutTrackingPage extends StatelessWidget
{
  const WorkoutTrackingPage({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracking'),
        backgroundColor: const Color(0xFF5D6C8A), // Same color as your theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Workout type and description
            const Text(
              'Strength Workout',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Workout focusing on building strength through various exercises.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Timer display
            const Center(
              child: Column(
                children: [
                  Text(
                    '00:00:00',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Duration',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Start, Pause, Stop buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement start logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF85C83E),
                  ),
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement pause logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: const Text('Pause'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement stop logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress details, e.g., sets, reps
            const Text(
              'Sets: 3/5',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              'Reps: 10/12',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}