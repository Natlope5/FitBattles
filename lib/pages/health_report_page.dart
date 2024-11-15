import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthReportPage extends StatefulWidget {
  const HealthReportPage({super.key});

  @override
  _HealthReportPageState createState() => _HealthReportPageState();
}

class _HealthReportPageState extends State<HealthReportPage> {
  double totalCaloriesBurned = 0.0;
  Duration totalWorkoutTime = Duration.zero;
  double totalWaterIntake = 0.0;
  List<double> weeklyCalories = List.filled(7, 0.0); // Store daily calories burned
  List<String> weeklyDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Get the last 7 days of workout data
    QuerySnapshot workoutSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('timestamp', descending: true)
        .get();

    // Initialize date mapping with calories burned for each day of the week
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1)); // Start of Monday at midnight

    Map<int, double> dayCalories = {for (var i = 0; i < 7; i++) i: 0.0};

    double calories = 0.0;
    Duration workoutTime = Duration.zero;

    for (var doc in workoutSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      double dailyCalories = data['calories'] ?? 0.0;
      int durationMinutes = data['duration'] ?? 0;
      DateTime timestamp = (data['timestamp'] as Timestamp).toDate().toLocal(); // Convert to local time
      DateTime dateOnly = DateTime(timestamp.year, timestamp.month, timestamp.day); // Remove time component

      calories += dailyCalories;
      workoutTime += Duration(minutes: durationMinutes);

      int daysSinceMonday = dateOnly.difference(startOfWeek).inDays;
      if (daysSinceMonday >= 0 && daysSinceMonday < 7) {
        dayCalories[daysSinceMonday] = (dayCalories[daysSinceMonday] ?? 0.0) + dailyCalories;
      }
    }

    setState(() {
      totalCaloriesBurned = calories;
      totalWorkoutTime = workoutTime;
      weeklyCalories = List.generate(7, (i) => dayCalories[i] ?? 0.0);
    });

    await _fetchWaterIntakeData();
  }

  // Fetch water intake data
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
        title: const Text('Health Report'),
        backgroundColor: const Color(0xFF5D6C8A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricCard('Calories Burned', '${totalCaloriesBurned.toStringAsFixed(1)} kcal'),
                _buildMetricCard(
                  'Workout Time',
                  '${totalWorkoutTime.inHours}h ${totalWorkoutTime.inMinutes.remainder(60)}m',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Calories Burned Over Time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: _buildCaloriesChart(),
            ),
            const SizedBox(height: 40),
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

  Widget _buildCaloriesChart() {
    return BarChart(
      BarChartData(
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [BarChartRodData(toY: weeklyCalories[index])],
          );
        }),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                );
                return Text(weeklyDays[value.toInt()], style: style);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );
  }
}