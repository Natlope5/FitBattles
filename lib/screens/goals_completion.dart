import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart'; // Import Provider to use ThemeProvider
import 'package:fitbattles/settings/theme_provider.dart'; // Assuming ThemeProvider is defined in this file

class GoalCompletionPage extends StatefulWidget {
  const GoalCompletionPage({super.key, required this.userToken});

  final String userToken;

  @override
  GoalCompletionPageState createState() => GoalCompletionPageState();
}

class GoalCompletionPageState extends State<GoalCompletionPage> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final TextEditingController _progressController = TextEditingController(); // Controller for progress updates

  List<Map<String, dynamic>> _goalHistory = [];

  @override
  void initState() {
    super.initState();
    _loadGoalHistory();
  }

  Future<void> _loadGoalHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedGoals = prefs.getString('goalHistory');
    if (savedGoals != null) {
      setState(() {
        _goalHistory = List<Map<String, dynamic>>.from(jsonDecode(savedGoals));
      });
    }
  }

  Future<void> _saveGoalHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('goalHistory', jsonEncode(_goalHistory));
  }

  void _addGoal() {
    final String goalName = _goalNameController.text;
    final String goalAmount = _goalAmountController.text;

    if (goalName.isNotEmpty && goalAmount.isNotEmpty) {
      setState(() {
        _goalHistory.add({
          'name': goalName,
          'amount': double.tryParse(goalAmount) ?? 0.0,
          'currentProgress': 0.0,
        });
        _goalNameController.clear();
        _goalAmountController.clear();
      });
      _saveGoalHistory();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both goal name and amount.')),
      );
    }
  }

  void _clearGoalHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _goalHistory.clear();
    });
    await prefs.remove('goalHistory');
  }

  void _updateProgress(int index, double progress) {
    setState(() {
      _goalHistory[index]['currentProgress'] = progress;
    });
    _saveGoalHistory();
  }

  Widget _buildGoalList() {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access the ThemeProvider

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _goalHistory.length,
      itemBuilder: (context, index) {
        final goal = _goalHistory[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(
              goal['name'],
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black, // Adjust title color based on theme
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress: ${goal['currentProgress']} / ${goal['amount']}',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54, // Adjust subtitle color based on theme
                  ),
                ),
                TextField(
                  controller: _progressController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Update Progress',
                    labelStyle: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black, // Adjust label color based on theme
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        final double newProgress = double.tryParse(_progressController.text) ?? 0.0;
                        if (newProgress <= goal['amount']) {
                          _updateProgress(index, newProgress);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Progress cannot exceed the goal amount.')),
                          );
                        }
                        _progressController.clear();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressChart() {
    if (_goalHistory.isEmpty) {
      return const Center(
        child: Text('No goals to display progress.'),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: _goalHistory.asMap().entries.map((entry) {
          final int index = entry.key;
          final goal = entry.value;
          final double progressPercent = (goal['amount'] > 0)
              ? (goal['currentProgress'] / goal['amount']) * 100
              : 0.0; // Handle zero amount

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: progressPercent.clamp(0.0, 100.0), // Ensure valid range
                color: goal['currentProgress'] >= goal['amount']
                    ? Colors.green
                    : Colors.blue,
                width: 15,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (_goalHistory.length > value.toInt()) {
                  return Text(
                    _goalHistory[value.toInt()]['name'],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access the ThemeProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Completion'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Name Input
              const Text('Enter Goal Name:', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _goalNameController,
                decoration: const InputDecoration(
                  hintText: 'E.g., Run 5 kilometers',
                ),
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black, // Adjust input text color based on theme
                ),
              ),
              const SizedBox(height: 16),

              // Goal Amount Input
              const Text('Enter Goal Amount:', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _goalAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'E.g., 5.0',
                ),
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black, // Adjust input text color based on theme
                ),
              ),
              const SizedBox(height: 16),

              // Add Goal Button
              ElevatedButton(
                onPressed: _addGoal,
                child: const Text('Add Goal'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _clearGoalHistory,
                child: const Text('Clear Goals Log'),
              ),

              // Goals Log
              const Text('Goals Log:', style: TextStyle(fontSize: 18)),
              _buildGoalList(),

              const SizedBox(height: 32),

              // Progress Chart
              const Text('Goal Progress:', style: TextStyle(fontSize: 18)),
              SizedBox(
                height: 200,
                child: _buildProgressChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
