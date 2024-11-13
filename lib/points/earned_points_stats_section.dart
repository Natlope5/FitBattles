import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:fitbattles/settings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Stats section widget for the EarnedPointsPage
class EarnedPointsStatsSection extends StatelessWidget {
  final int totalChallengesCompleted;
  final int pointsEarnedToday;
  final int bestDayPoints;
  final int streakDays;

  const EarnedPointsStatsSection({
    super.key,
    required this.totalChallengesCompleted,
    required this.pointsEarnedToday,
    required this.bestDayPoints,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.statisticsTitle,
          style: TextStyle(fontSize: AppDimens.statsTitleSize, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Total challenges completed
        Text(
          '${AppStrings.totalChallengesCompletedLabel}$totalChallengesCompleted',
          style: const TextStyle(fontSize: AppDimens.statsTextSize),
        ),
        const SizedBox(height: 5),

        // Points earned today
        Text(
          '${AppStrings.pointsEarnedTodayLabel}$pointsEarnedToday',
          style: const TextStyle(fontSize: AppDimens.statsTextSize),
        ),
        const SizedBox(height: 5),

        // Best day for points earned
        Text(
          '${AppStrings.bestDayLabel}$bestDayPoints points',
          style: const TextStyle(fontSize: AppDimens.statsTextSize),
        ),
        const SizedBox(height: 20),

        // Current streak
        Text(
          '${AppStrings.currentStreakLabel}$streakDays days',
          style: TextStyle(
            fontSize: AppDimens.statsTextSize,
            fontWeight: FontWeight.bold,
            color: streakDays > 0 ? AppColors.streakActiveColor : AppColors.streakInactiveColor,
          ),
        ),
        const SizedBox(height: 5),

        // Encouragement to maintain the streak
        const Text(
          AppStrings.maintainStreakMessage,
          style: TextStyle(fontSize: AppDimens.maintainStreakTextSize, color: Colors.grey),
        ),
      ],
    );
  }

  // Function to fetch stats from Firestore
  static Future<EarnedPointsStats> fetchStats(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      return EarnedPointsStats(
        totalChallengesCompleted: data?['totalChallengesCompleted'] ?? 0,
        pointsEarnedToday: data?['pointsEarnedToday'] ?? 0,
        bestDayPoints: data?['bestDayPoints'] ?? 0,
        streakDays: data?['streakDays'] ?? 0,
      );
    } else {
      return EarnedPointsStats(); // Return default stats if user does not exist
    }
  }
}

// Class to hold stats data
class EarnedPointsStats {
  final int totalChallengesCompleted;
  final int pointsEarnedToday;
  final int bestDayPoints;
  final int streakDays;

  EarnedPointsStats({
    this.totalChallengesCompleted = 0,
    this.pointsEarnedToday = 0,
    this.bestDayPoints = 0,
    this.streakDays = 0,
  });
}