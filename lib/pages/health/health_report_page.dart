import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'health_report_graph.dart'; // Import the reusable graph widget

class HealthReportPage extends StatefulWidget {
  const HealthReportPage({super.key});

  @override
  State<HealthReportPage> createState() => _HealthReportPageState();
}

class _HealthReportPageState extends State<HealthReportPage> {
  int totalCalories = 0;
  int totalWorkoutTime = 0; // in minutes
  double totalWaterIntake = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyWorkoutData();
  }

  Future<void> _fetchWeeklyWorkoutData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final workoutsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
        .get();

    int caloriesSum = 0;
    int durationSum = 0;

    for (var doc in workoutsSnapshot.docs) {
      final data = doc.data();
      final calories = (data['calories'] as num).toInt();
      final duration = (data['duration'] as num).toInt();

      caloriesSum += calories;
      durationSum += duration;
    }

    setState(() {
      totalCalories = caloriesSum;
      totalWorkoutTime = durationSum;
    });

    await _fetchWaterIntakeData();
  }

  Future<void> _fetchWaterIntakeData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot waterSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('water_log')
        .get();
    double waterIntake = 0.0;
    for (var doc in waterSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      waterIntake += data['amount'] ?? 0.0;
    }
    setState(() {
      totalWaterIntake = waterIntake;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Section
            const Text(
              'Weekly Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricCard('Calories Burned', '$totalCalories kcal'),
                _buildMetricCard('Workout Time', _formatDuration(totalWorkoutTime)),
              ],
            ),
            const SizedBox(height: 20),

            // Graph Section
            const Text(
              'Calories Burned Each Day',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const SizedBox(
              height: 200,
              child: HealthReportGraph(), // Replace the graph section with the reusable widget
            ),
            const SizedBox(height: 20),

            // Detailed Metrics Section
            const Text(
              'Detailed Metrics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildMetricDetail('Water Intake', '${totalWaterIntake.toStringAsFixed(1)} L'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  Widget _buildMetricDetail(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}