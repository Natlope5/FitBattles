import 'package:intl/intl.dart';

class ChallengeService {
  // Define two sample challenges for even and odd weeks
  final List<Map<String, dynamic>> timeBasedChallenges = [
    {
      'title': 'Walk 10,000 Steps',
      'description': 'Complete a total of 10,000 steps this week!',
    },
    {
      'title': 'Run 5 Miles',
      'description': 'Complete a total of 5 miles running this week!',
    },
  ];

  // Define two sample challenges for even and odd months
  final List<Map<String, dynamic>> monthlyChallenges = [
    {
      'title': 'Cycle 100 Miles',
      'description': 'Complete a total of 100 miles cycling this month!',
    },
    {
      'title': 'Swim 5 Hours',
      'description': 'Accumulate 5 hours of swimming this month!',
    },
  ];

  // Get the current weekly challenge based on the device's week number
  Map<String, dynamic> getCurrentWeeklyChallenge() {
    int weekNumber = _getWeekOfYear();
    int challengeIndex = weekNumber % timeBasedChallenges.length;
    return timeBasedChallenges[challengeIndex];
  }

  // Get the next weekly challenge based on the device's week number
  Map<String, dynamic> getNextWeeklyChallenge() {
    int nextWeekNumber = _getWeekOfYear() + 1;
    int challengeIndex = nextWeekNumber % timeBasedChallenges.length;
    return timeBasedChallenges[challengeIndex];
  }

  // Get the current monthly challenge based on the device's month number
  Map<String, dynamic> getCurrentMonthlyChallenge() {
    int monthNumber = DateTime.now().month;
    int challengeIndex = monthNumber % monthlyChallenges.length;
    return monthlyChallenges[challengeIndex];
  }

  // Get the next monthly challenge based on the device's month number
  Map<String, dynamic> getNextMonthlyChallenge() {
    int nextMonthNumber = DateTime.now().month + 1;
    int challengeIndex = nextMonthNumber % monthlyChallenges.length;
    return monthlyChallenges[challengeIndex];
  }

  // Calculate the current week number
  int _getWeekOfYear() {
    DateTime now = DateTime.now();
    int dayOfYear = int.parse(DateFormat("D").format(now));
    return ((dayOfYear - now.weekday + 10) / 7).floor();
  }
}