import 'package:flutter/material.dart';
import 'package:fitbattles/firebase/challenge_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeBasedChallengesPage extends StatefulWidget {
  const TimeBasedChallengesPage({super.key});

  @override
  TimeBasedChallengesPageState createState() => TimeBasedChallengesPageState();
}

class TimeBasedChallengesPageState extends State<TimeBasedChallengesPage> {
  final ChallengeService _challengeService = ChallengeService();
  Map<String, dynamic>? _currentWeeklyChallenge;
  Map<String, dynamic>? _nextWeeklyChallenge;
  Map<String, dynamic>? _currentMonthlyChallenge;
  Map<String, dynamic>? _nextMonthlyChallenge;

  int _weeklyProgress = 0;
  int _monthlyProgress = 0;

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
    _loadUserProgress();
  }

  void _fetchChallenges() {
    _currentWeeklyChallenge = _challengeService.getCurrentWeeklyChallenge();
    _nextWeeklyChallenge = _challengeService.getNextWeeklyChallenge();
    _currentMonthlyChallenge = _challengeService.getCurrentMonthlyChallenge();
    _nextMonthlyChallenge = _challengeService.getNextMonthlyChallenge();
    setState(() {}); // Refresh UI with new data
  }

  // Load user progress from SharedPreferences for both weekly and monthly challenges
  Future<void> _loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weeklyProgress = prefs.getInt('weekly_challenge_progress') ?? 0;
      _monthlyProgress = prefs.getInt('monthly_challenge_progress') ?? 0;
    });
  }

  // Update weekly progress and save to SharedPreferences
  Future<void> _updateWeeklyProgress(int newProgress) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weeklyProgress = newProgress;
    });
    await prefs.setInt('weekly_challenge_progress', _weeklyProgress);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weekly progress saved locally')),
      );
    }
  }

  // Update monthly progress and save to SharedPreferences
  Future<void> _updateMonthlyProgress(int newProgress) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyProgress = newProgress;
    });
    await prefs.setInt('monthly_challenge_progress', _monthlyProgress);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly progress saved locally')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly & Monthly Challenges')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Challenge
            Text(
              'This Week\'s Challenge:',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _currentWeeklyChallenge?['title'] ?? 'Weekly Challenge',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(_currentWeeklyChallenge?['description'] ?? ''),
            const SizedBox(height: 20),
            Text('Weekly Progress: $_weeklyProgress%'),
            Slider(
              min: 0,
              max: 100,
              value: _weeklyProgress.toDouble(),
              onChanged: (value) {
                setState(() {
                  _weeklyProgress = value.toInt();
                });
              },
            ),
            ElevatedButton(
              onPressed: () => _updateWeeklyProgress(_weeklyProgress),
              child: const Text('Save Weekly Progress'),
            ),
            const SizedBox(height: 40),

            // Monthly Challenge
            Text(
              'This Month\'s Challenge:',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _currentMonthlyChallenge?['title'] ?? 'Monthly Challenge',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(_currentMonthlyChallenge?['description'] ?? ''),
            const SizedBox(height: 20),
            Text('Monthly Progress: $_monthlyProgress%'),
            Slider(
              min: 0,
              max: 100,
              value: _monthlyProgress.toDouble(),
              onChanged: (value) {
                setState(() {
                  _monthlyProgress = value.toInt();
                });
              },
            ),
            ElevatedButton(
              onPressed: () => _updateMonthlyProgress(_monthlyProgress),
              child: const Text('Save Monthly Progress'),
            ),
            const SizedBox(height: 40),

            // Next Week's Challenge
            Text(
              'Next Week\'s Challenge:',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              _nextWeeklyChallenge?['title'] ?? 'Upcoming Weekly Challenge',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),

            // Next Month's Challenge
            Text(
              'Next Month\'s Challenge:',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              _nextMonthlyChallenge?['title'] ?? 'Upcoming Monthly Challenge',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}