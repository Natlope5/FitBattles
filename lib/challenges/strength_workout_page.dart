import 'package:flutter/material.dart';
import 'package:fitbattles/l10n/app_localizations.dart'; // Import localization
import 'package:fl_chart/fl_chart.dart'; // Import FL Chart package

class StrengthWorkoutPage extends StatelessWidget {
  const StrengthWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context); // Access localized strings

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.strengthWorkoutTitle), // Use localized title
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
            Text(
              localizations.strengthWorkoutChallengesTitle as String, // Use localized challenges title
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              localizations.strengthWorkoutDescription, // Use localized description
              style: const TextStyle(fontSize: 18),
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
                              return Text('Push Ups', style: style);
                            case 1:
                              return Text('Squats', style: style);
                            case 2:
                              return Text('Sit Ups', style: style);
                            case 3:
                              return Text('Bench Press', style: style);
                            case 4:
                              return Text('Lunges', style: style);
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
                    content: Text(localizations.workoutStartedMessage), // Use localized message
                  ),
                );
              },
              child: Text(localizations.startWorkoutButton), // Use localized button text
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
