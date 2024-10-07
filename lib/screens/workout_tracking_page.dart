import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer functionality

class WorkoutTrackingPage extends StatefulWidget {
  const WorkoutTrackingPage({super.key});

  @override
  WorkoutTrackingPageState createState() => WorkoutTrackingPageState();
}

class WorkoutTrackingPageState extends State<WorkoutTrackingPage> {
  Timer? _timer;
  Duration _duration = Duration.zero;
  bool _isTracking = false;

  void _startTimer() {
    if (_isTracking) return; // Prevent multiple timers

    _isTracking = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isTracking = false;
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTracking = false;
      _duration = Duration.zero; // Reset duration
    });
  }

  String get _formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_duration.inHours);
    final minutes = twoDigits(_duration.inMinutes.remainder(60));
    final seconds = twoDigits(_duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
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
            Center(
              child: Column(
                children: [
                  Text(
                    _formattedDuration,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
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
                  onPressed: _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF85C83E),
                  ),
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: _pauseTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: const Text('Pause'),
                ),
                ElevatedButton(
                  onPressed: _stopTimer,
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

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when the widget is disposed
    super.dispose();
  }
}
