import 'package:fitbattles/settings/ui/app_colors.dart';
import 'package:fitbattles/settings/ui/app_dimens.dart';
import 'package:fitbattles/settings/ui/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DistanceWorkoutPage extends StatefulWidget {
  const DistanceWorkoutPage({super.key});

  @override
  DistanceWorkoutPageState createState() => DistanceWorkoutPageState();
}

class DistanceWorkoutPageState extends State<DistanceWorkoutPage> {
  final TextEditingController _distanceController = TextEditingController();
  double _loggedDistance = 0.0;
  final double _preloadedDistance = 5.0; // Preloaded workout distance (in km)
  final List<double> _distanceHistory = []; // List to store distance logged history

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  void _logDistance() {
    final double? newDistance = double.tryParse(_distanceController.text);
    if (newDistance != null && newDistance > 0) {
      setState(() {
        _loggedDistance += newDistance;
        _distanceHistory.add(newDistance); // Add new distance to history
        _distanceController.clear(); // Clear the input field after logging
      });
      // Show feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.distanceLoggedMessage} $newDistance km')),
      );
    } else {
      // Show an error message if the input is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.invalidDistanceMessage)),
      );
    }
  }

  List<FlSpot> _generateChartData() {
    return List<FlSpot>.generate(
      _distanceHistory.length,
          (index) => FlSpot(index.toDouble(), _distanceHistory[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.distanceWorkoutTitle),
        backgroundColor: AppColors.appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.padding), // Use the padding constant
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              AppStrings.distanceWorkoutTitle,
              style: TextStyle(fontSize: AppDimens.textSizeTitle), // Use the title size constant
            ),
            const SizedBox(height: 20),

            // Preloaded workout section
            Text(
              '${AppStrings.preloadedWorkoutLabel} $_preloadedDistance km',
              style: TextStyle(
                fontSize: AppDimens.textSizeSubtitle,
                color: AppColors.preloadedWorkoutColor,
              ),
            ),
            const SizedBox(height: 20),

            // Input field for custom distance
            TextField(
              controller: _distanceController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppStrings.enterDistanceHint,
                hintText: 'e.g. 5',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Button to log the distance
            ElevatedButton(
              onPressed: _logDistance,
              child: const Text(AppStrings.logDistanceButton),
            ),
            const SizedBox(height: 20),

            // Display total logged distance
            Text(
              '${AppStrings.totalLoggedDistanceLabel} $_loggedDistance km',
              style: TextStyle(
                fontSize: AppDimens.textSizeSubtitle,
                color: AppColors.loggedDistanceColor,
              ),
            ),
            const SizedBox(height: 20),

            // Motivational message
            const Text(
              AppStrings.motivationalMessage,
              style: TextStyle(
                fontSize: AppDimens.textSizeSubtitle,
                color: AppColors.motivationalMessageColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Line chart for logged distances
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  minX: 0,
                  maxX: _distanceHistory.length.toDouble() - 1,
                  minY: 0,
                  maxY: (_loggedDistance + 5).toDouble(), // Add some margin
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateChartData(),
                      isCurved: true,
                      color: AppColors.loggedDistanceColor,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
