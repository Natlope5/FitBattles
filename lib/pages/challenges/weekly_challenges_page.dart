import 'package:flutter/material.dart';
import 'package:fitbattles/firebase/challenge_service.dart';

class WeeklyChallengesPage extends StatefulWidget {
  const WeeklyChallengesPage({super.key});

  @override
  WeeklyChallengesPageState createState() => WeeklyChallengesPageState();
}

class WeeklyChallengesPageState extends State<WeeklyChallengesPage> {
  final ChallengeService _challengeService = ChallengeService();
  Map<String, dynamic>? _challengeData;
  int _userProgress = 0;

  @override
  void initState() {
    super.initState();
    _fetchChallenge();
  }

  Future<void> _fetchChallenge() async {
    _challengeData = await _challengeService.getCurrentWeeklyChallenge();
    setState(() {}); // Refresh UI with new data
  }

  void _updateProgress() async {
    await _challengeService.updateUserChallengeProgress(_userProgress);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Challenge')),
      body: _challengeData == null
          ? const Center(child: Text('No challenge available'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _challengeData!['title'] ?? 'Weekly Challenge',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(_challengeData!['description'] ?? 'Complete this challenge!'),
            const SizedBox(height: 20),
            Text('Your Progress: $_userProgress'),
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
              child: const Text('Update Progress'),
            ),
          ],
        ),
      ),
    );
  }
}