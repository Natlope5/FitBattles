import 'package:flutter/material.dart';

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  HydrationPageState createState() => HydrationPageState();
}

class HydrationPageState extends State<HydrationPage> {
  double _currentIntake = 0.0; // Current water intake in liters
  final double _goal = 3.0; // Daily goal in liters (can be customized)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration Tracker'),
        backgroundColor: const Color(0xFF5D6C8A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Your Water Intake',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Progress indicator for water intake
            _buildProgressIndicator(),
            const SizedBox(height: 20),
            // Display current water intake
            Text(
              '${_currentIntake.toStringAsFixed(1)} liters',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Button to add water intake
            ElevatedButton(
              onPressed: _addWaterIntake,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Button color
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('Add Water Intake'),
            ),
          ],
        ),
      ),
    );
  }

  // Build the progress indicator for hydration
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Text(
          'Daily Goal: $_goal liters',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        // Progress bar for water intake
        LinearProgressIndicator(
          value: _currentIntake / _goal,
          minHeight: 20,
          backgroundColor: Colors.grey[300],
          color: Colors.lightBlueAccent,
        ),
      ],
    );
  }

  // Function to add water intake
  Future<void> _addWaterIntake() async {
    double? newIntake = await _showAddWaterDialog();
    if (newIntake != null) {
      setState(() {
        _currentIntake += newIntake; // Update current intake
      });
    }
  }

  // Show dialog to add water intake
  Future<double?> _showAddWaterDialog() async {
    double intake = 0.0;
    return showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Water Intake'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter amount in liters',
              hintText: 'e.g. 0.5',
            ),
            onChanged: (value) {
              intake = double.tryParse(value) ?? 0.0;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(intake); // Return the intake amount
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
