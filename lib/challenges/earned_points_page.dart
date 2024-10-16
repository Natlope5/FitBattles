import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:fitbattles/settings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:fitbattles/points/earned_points_awards_section.dart';
import 'package:fitbattles/points/earned_points_stats_section.dart';

class EarnedPointsPage extends StatelessWidget {
  final int points;
  final int streakDays;
  final int totalChallengesCompleted;
  final int pointsEarnedToday;
  final int bestDayPoints;

  const EarnedPointsPage({
    super.key,
    required this.points,
    required this.streakDays,
    required this.totalChallengesCompleted,
    required this.pointsEarnedToday,
    required this.bestDayPoints,
  });

  @override
  Widget build(BuildContext context) {
    double progress = points / 1000;
    List<String> awards = _determineAwards(totalChallengesCompleted);
    String rank = _determineRank(points);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.earnedPointsTitle),
        backgroundColor: AppColors.appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              AppStrings.earnedPointsTitle,
              style: TextStyle(
                  fontSize: AppDimens.titleSize, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              '$points ${AppStrings.pointsLabel}',
              style: TextStyle(
                  fontSize: AppDimens.pointsSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.totalPointsColor),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                color: AppColors.progressColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${(progress * 100).toStringAsFixed(1)}${AppStrings.goalPercentageLabel}',
              style: const TextStyle(fontSize: AppDimens.statsTextSize),
            ),
            const SizedBox(height: 20),

            if (progress < 1) ...[
              const Text(
                AppStrings.keepGoingMessage,
                style: TextStyle(
                    fontSize: AppDimens.statsTextSize, color: Colors.grey),
              ),
              const SizedBox(height: 20),
            ] else ...[
              const Text(
                AppStrings.congratulationsMessage,
                style: TextStyle(
                    fontSize: AppDimens.statsTextSize, color: Colors.green),
              ),
              const SizedBox(height: 20),
            ],

            Text(
              '${AppStrings.yourRankLabel}$rank',
              style: const TextStyle(
                  fontSize: AppDimens.statsTitleSize,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Awards Section
            EarnedPointsAwardsSection(awards: awards),

            // Stats Section
            EarnedPointsStatsSection(
              totalChallengesCompleted: totalChallengesCompleted,
              pointsEarnedToday: pointsEarnedToday,
              bestDayPoints: bestDayPoints,
              streakDays: streakDays,
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.appBarColor,
                minimumSize: Size(double.infinity, AppDimens.buttonHeight),
              ),
              child: const Text(AppStrings.backToHomeButton),
            ),
          ],
        ),
      ),
    );
  }

  // Determines the awards based on completed challenges
  List<String> _determineAwards(int challengesCompleted) {
    List<String> awards = [];
    if (challengesCompleted >= 5) awards.add(AppStrings.bronzeTrophy);
    if (challengesCompleted >= 10) awards.add(AppStrings.silverTrophy);
    if (challengesCompleted >= 20) awards.add(AppStrings.goldTrophy);
    if (challengesCompleted >= 50) awards.add(AppStrings.platinumTrophy);
    return awards;
  }

  // Determines the rank based on earned points
  String _determineRank(int points) {
    if (points < 100) {
      return 'Novice';
    } else if (points < 500) {
      return 'Intermediate';
    } else if (points < 1000) {
      return 'Advanced';
    } else {
      return 'Master';
    }
  }
}
