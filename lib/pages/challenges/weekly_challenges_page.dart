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
    _fetchChallengeData();
  }

  Future<void> _fetchChallengeData() async {
    final challenge = await _challengeService.getCurrentWeeklyChallenge();
    final userProgress = await _challengeService.getUserChallengeProgress();

    setState(() {
      _challengeData = challenge;
      _userProgress = userProgress;
    });
  }

  void _updateProgress(int progress) async {
    setState(() {
      _userProgress = progress;
    });
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _updateProgress(_userProgress),
              child: const Text('Update Progress'),
            ),
          ],
        ),
      ),
    );
  }
}