import 'package:flutter/material.dart';
import 'package:fitbattles/firebase/challenge_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeeklyChallengesPage extends StatefulWidget {
  const WeeklyChallengesPage({super.key});

  @override
  WeeklyChallengesPageState createState() => WeeklyChallengesPageState();
}

class WeeklyChallengesPageState extends State<WeeklyChallengesPage> {
  final ChallengeService _challengeService = ChallengeService();
  Map<String, dynamic>? _currentChallenge;
  Map<String, dynamic>? _nextChallenge;
  int _userProgress = 0;

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
    _loadUserProgress();
  }

  void _fetchChallenges() {
    _currentChallenge = _challengeService.getCurrentWeeklyChallenge();
    _nextChallenge = _challengeService.getNextWeeklyChallenge();
    setState(() {}); // Refresh UI with new data
  }

  Future<void> _loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userProgress = prefs.getInt('weekly_challenge_progress') ?? 0;
    });
  }

  Future<void> _updateProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weekly_challenge_progress', _userProgress);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Challenge')),
      body: _currentChallenge == null
          ? const Center(child: Text('No current challenge available'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week\'s Challenge:',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _currentChallenge!['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(_currentChallenge!['description']),
            const SizedBox(height: 20),
            Text('Your Progress: $_userProgress%'),
            Slider(
              min: 0,
              max: 100,
              value: _userProgress.toDouble(),
              onChanged: (value) {
                setState(() {
                  _userProgress = value.toInt();
                });
              },
            ),
            ElevatedButton(
              onPressed: _updateProgress,
              child: const Text('Save Progress'),
            ),
            const SizedBox(height: 40),
            Text(
              'Next Week\'s Challenge:',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _nextChallenge!['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}