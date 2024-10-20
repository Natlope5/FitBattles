import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import '../firebase/firebase_auth.dart';
import '../firebase/firebase_messaging.dart';

class GoalCompletionPage extends StatefulWidget {
  const GoalCompletionPage({super.key, required this.userToken});

  final String userToken;

  @override
  GoalCompletionPageState createState() => GoalCompletionPageState();
}

class GoalCompletionPageState extends State<GoalCompletionPage> {
  List<Map<String, dynamic>> _goalHistory = [];
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _loadGoalHistoryFromFirestore();
  }

  Future<void> _loadGoalHistoryFromFirestore() async {
    try {
      final userId = _authService.getCurrentUserId();
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        setState(() {
          _goalHistory = List<Map<String, dynamic>>.from(doc['goalHistory']);
        });
      }
    } catch (e) {
      logger.i('Error loading goal history: $e');
    }
  }

  Future<void> _saveGoalHistoryToFirestore() async {
    try {
      final userId = _authService.getCurrentUserId();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'goalHistory': _goalHistory});
    } catch (e) {
      logger.i('Error saving goal history: $e');
    }
  }

  Widget _buildProgressChart(ThemeData themeData) {
    if (_goalHistory.isEmpty) {
      return const Center(child: Text('No goals to display progress.'));
    }

    return BarChart(
      BarChartData(
        barGroups: _goalHistory.asMap().entries.map((entry) {
          final int index = entry.key;
          final goal = entry.value;
          final double progressPercent = goal['amount'] > 0
              ? (goal['currentProgress'] / goal['amount']) * 100
              : 0.0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: progressPercent.clamp(0.0, 100.0),
                color: goal['currentProgress'] >= goal['amount']
                    ? Colors.green
                    : themeData.primaryColor,
                width: 15,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData themeData = themeProvider.isDarkMode
        ? ThemeData.dark()
        : ThemeData.light();

    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Goal Completion Progress'),
          backgroundColor: themeData.appBarTheme.backgroundColor,
          foregroundColor: themeData.appBarTheme.foregroundColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: _goalHistory.isEmpty
                    ? const Text('No goals completed yet.')
                    : _buildProgressChart(themeData),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveGoalHistoryToFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeData.buttonTheme.colorScheme?.primary,
                  foregroundColor: themeData.buttonTheme.colorScheme?.onPrimary,
                ),
                child: const Text('Save Goal History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
