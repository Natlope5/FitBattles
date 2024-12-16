import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HealthReportGraph extends StatefulWidget {
  const HealthReportGraph({super.key});

  @override
  _HealthReportGraphState createState() => _HealthReportGraphState();
}

class _HealthReportGraphState extends State<HealthReportGraph> {
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

    final startOfWeek =
    DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final workoutsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
        .get();

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
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final day = DateFormat.E().format(timestamp); // Get day abbreviation

      if (caloriesByDay.containsKey(day)) {
        caloriesByDay[day] = (caloriesByDay[day] ?? 0) + calories;
      }
    }

    setState(() {
      dailyCalories = caloriesByDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: dailyCalories.entries.map((entry) {
          final dayIndex = _dayToIndex(entry.key);
          return BarChartGroupData(
            x: dayIndex,
            barRods: [BarChartRodData(toY: entry.value)],
          );
        }).toList(),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Remove top numbers
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Remove left numbers
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50, // Reserve space for 4-digit numbers
              interval: 100, // Adjust interval as needed
              getTitlesWidget: (value, meta) {
                if (value % 100 == 0) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, _) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(days[value.toInt()], style: const TextStyle(fontSize: 12));
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 100, // Align grid lines with intervals
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.5), // Gridline color
            strokeWidth: 1, // Gridline thickness
          ),
          drawVerticalLine: false,
        ),
      ),
    );
  }

  int _dayToIndex(String day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.indexOf(day);
  }
}