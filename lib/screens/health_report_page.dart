import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthReportPage extends StatelessWidget {
  const HealthReportPage({super.key});

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
              'Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricCard('Calories Burned', '1200 kcal'),
                _buildMetricCard('Workout Time', '1h 30m'),
              ],
            ),
            const SizedBox(height: 20),

            // Graph Section
            const Text(
              'Calories Burned Over Time',
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
            _buildMetricDetail('Steps Taken', '10,000'),
            const SizedBox(height: 10),
            _buildMetricDetail('Heart Rate', '75 bpm'),
            const SizedBox(height: 10),
            _buildMetricDetail('Water Intake', '2.5L'),
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

  // fl_chart bar chart for calories burned over time
  Widget _buildCaloriesChart() {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 300)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 500)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 400)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 700)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 600)]),
          BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 800)]),
          BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 1000)]),
        ],
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hides the left axis titles
          ),
        ),
      ),
    );
  }
}