import 'package:intl/intl.dart';

class ChallengeService {
  // Define two sample challenges for even and odd weeks
  final List<Map<String, dynamic>> challenges = [
    {
      'title': 'Walk 10,000 Steps',
      'description': 'Complete a total of 10,000 steps this week!',
    },
    {
      'title': 'Run 5 Miles',
      'description': 'Complete a total of 5 miles running this week!',
    },
  ];

  // Get the current weekly challenge based on the device's week number
  Map<String, dynamic> getCurrentWeeklyChallenge() {
    int weekNumber = _getWeekOfYear();
    int challengeIndex = weekNumber % challenges.length;
    return challenges[challengeIndex];
  }

  // Get the next weekly challenge based on the device's week number
  Map<String, dynamic> getNextWeeklyChallenge() {
    int nextWeekNumber = _getWeekOfYear() + 1;
    int challengeIndex = nextWeekNumber % challenges.length;
    return challenges[challengeIndex];
  }

  // Calculate the current week number
  int _getWeekOfYear() {
    DateTime now = DateTime.now();
    int dayOfYear = int.parse(DateFormat("D").format(now));
    return ((dayOfYear - now.weekday + 10) / 7).floor();
  }
}