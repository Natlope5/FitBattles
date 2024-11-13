class EarnedPointsStats {
  final int pointsEarned;
  final int pointsGoal;
  final int totalChallengesCompleted;
  final int pointsEarnedToday;
  final int bestDayPoints;
  final int streakDays;

  // Constructor
  EarnedPointsStats({
    required this.pointsEarned,
    required this.pointsGoal,
    required this.totalChallengesCompleted,
    required this.pointsEarnedToday,
    required this.bestDayPoints,
    required this.streakDays,
  });

  // Define the `fromMap` method to convert Firestore data (Map) to the class instance
  factory EarnedPointsStats.fromMap(Map<String, dynamic> data) {
    return EarnedPointsStats(
      pointsEarned: data['pointsEarned'] ?? 0,
      pointsGoal: data['pointsGoal'] ?? 0,
      totalChallengesCompleted: data['totalChallengesCompleted'] ?? 0,
      pointsEarnedToday: data['pointsEarnedToday'] ?? 0,
      bestDayPoints: data['bestDayPoints'] ?? 0,
      streakDays: data['streakDays'] ?? 0,
    );
  }

  // Optionally, you can add a toMap method to convert the object back to a map
  Map<String, dynamic> toMap() {
    return {
      'pointsEarned': pointsEarned,
      'pointsGoal': pointsGoal,
      'totalChallengesCompleted': totalChallengesCompleted,
      'pointsEarnedToday': pointsEarnedToday,
      'bestDayPoints': bestDayPoints,
      'streakDays': streakDays,
    };
  }
}


