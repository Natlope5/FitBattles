import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HealthReportPage extends StatefulWidget {
  const HealthReportPage({super.key});

  @override
  State<HealthReportPage> createState() => _HealthReportPageState();
}

class _HealthReportPageState extends State<HealthReportPage> {
  int totalCalories = 0;
  int totalWorkoutTime = 0; // in minutes
  double totalWaterIntake = 0.0;
  Map<String, double> dailyCalories = {
    'Mon': 0,
    'Tue': 0,
    'Wed': 0,
    'Thu': 0,
    'Fri': 0,
    'Sat': 0,
    'Sun': 0,
  };

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
    Map<String, double> caloriesByDay = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    for (var doc in workoutsSnapshot.docs) {
      final data = doc.data();
      final calories = (data['calories'] as num).toDouble();
      final duration = (data['duration'] as num).toInt();
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final day = DateFormat.E().format(timestamp); // Get day abbreviation

      caloriesSum += calories.toInt();
      durationSum += duration;
      if (caloriesByDay.containsKey(day)) {
        caloriesByDay[day] = (caloriesByDay[day] ?? 0) + calories;
      }
    }

    setState(() {
      totalCalories = caloriesSum;
      totalWorkoutTime = durationSum;
      dailyCalories = caloriesByDay;
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
            SizedBox(
              height: 200,
              child: _buildCaloriesChart(), // fl_chart bar chart for calories
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

  // Helper method to build metric cards
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

  // Helper method to format duration in hours and minutes
  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  // Helper method to build detailed metrics
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
        barGroups: dailyCalories.entries.map((entry) {
          final dayIndex = _dayToIndex(entry.key);
          return BarChartGroupData(
            x: dayIndex,
            barRods: [BarChartRodData(toY: entry.value)],
          );
        }).toList(),
        borderData: FlBorderData(
          show: false, // Hide all borders around the graph
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide the top titles
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide the left titles
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, // Show numbers on the right side
              interval: 100, // Set intervals to increments of 100
              getTitlesWidget: (value, meta) {
                if (value % 100 == 0) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  );
                }
                return const SizedBox.shrink(); // Hide other values
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, // Show days of the week on the bottom
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(color: Colors.black, fontSize: 14);
                switch (value.toInt()) {
                  case 0:
                    return Text('Mon', style: style);
                  case 1:
                    return Text('Tue', style: style);
                  case 2:
                    return Text('Wed', style: style);
                  case 3:
                    return Text('Thu', style: style);
                  case 4:
                    return Text('Fri', style: style);
                  case 5:
                    return Text('Sat', style: style);
                  case 6:
                    return Text('Sun', style: style);
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: 100, // Align horizontal lines with increments of 100
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.5), // Customize horizontal line color
            strokeWidth: 1, // Customize horizontal line thickness
          ),
        ),
      ),
    );
  }

  int _dayToIndex(String day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.indexOf(day);
  }
}