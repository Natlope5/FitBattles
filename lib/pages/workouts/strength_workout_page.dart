import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class StrengthWorkoutPage extends StatelessWidget {
  const StrengthWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strength Workout'), // Hardcoded title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.fitness_center,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Challenges', // Hardcoded challenges title
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description of the strength workout challenges.', // Hardcoded description
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),

            // Bar chart representing workout sets
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: _getBarGroups(),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          );
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Push Ups', style: style);
                            case 1:
                              return const Text('Squats', style: style);
                            case 2:
                              return const Text('Sit Ups', style: style);
                            case 3:
                              return const Text('Bench Press', style: style);
                            case 4:
                              return const Text('Lunges', style: style);
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Workout has started!'), // Hardcoded message
                  ),
                );
                logger.i('Workout has started!'); // Log the action
              },
              child: const Text('Start Workout'), // Hardcoded button text
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to generate bar chart data
  List<BarChartGroupData> _getBarGroups() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [BarChartRodData(toY: 30, color: Colors.blue)], // Push Ups: 30 reps
      ),
      BarChartGroupData(
        x: 1,
        barRods: [BarChartRodData(toY: 45, color: Colors.green)], // Squats: 45 reps
      ),
      BarChartGroupData(
        x: 2,
        barRods: [BarChartRodData(toY: 24, color: Colors.red)], // Sit Ups: 24 reps
      ),
      BarChartGroupData(
        x: 3,
        barRods: [BarChartRodData(toY: 30, color: Colors.orange)], // Bench Press: 30 reps
      ),
      BarChartGroupData(
        x: 4,
        barRods: [BarChartRodData(toY: 36, color: Colors.purple)], // Lunges: 36 reps
      ),
    ];
  }
}
