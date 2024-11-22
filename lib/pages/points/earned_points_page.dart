import 'package:fitbattles/settings/ui/app_colors.dart';
import 'package:fitbattles/settings/ui/app_dimens.dart';
import 'package:fitbattles/settings/ui/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:fitbattles/widgets/earned_points_awards_section.dart';
import 'package:fitbattles/widgets/earned_points_stats_section.dart';
import 'package:fitbattles/services/firebase/points_service.dart';

class EarnedPointsPage extends StatelessWidget {
  final String userId;

  const EarnedPointsPage({super.key, required this.userId});

  static Future<Map<String, dynamic>> _fetchUserStatistics(String userId, PointsService pointsService) async {
    final totalPoints = await pointsService.calculateTotalPoints(userId);
    final pointsEarnedToday = await pointsService.calculatePointsEarnedToday(userId);
    final bestDayPoints = await pointsService.calculateBestDayPoints(userId);
    final streakDays = await pointsService.calculateStreakDays(userId);

    return {
      'totalPoints': totalPoints,
      'pointsEarnedToday': pointsEarnedToday,
      'bestDayPoints': bestDayPoints,
      'streakDays': streakDays,
    };
  }

  @override
  Widget build(BuildContext context) {
    PointsService pointsService = PointsService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.earnedPointsTitle),
        backgroundColor: AppColors.appBarColor,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserStatistics(userId, pointsService),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final totalPoints = snapshot.data?['totalPoints'] ?? 0;
          final pointsEarnedToday = snapshot.data?['pointsEarnedToday'] ?? 0;
          final bestDayPoints = snapshot.data?['bestDayPoints'] ?? 0;
          final streakDays = snapshot.data?['streakDays'] ?? 0;

          double progress = totalPoints / 1000; // Assuming 1000 points is the goal
          List<String> awards = _determineAwards(totalPoints);
          String rank = _determineRank(totalPoints);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                const Text(
                  AppStrings.earnedPointsTitle,
                  style: TextStyle(
                      fontSize: AppDimens.titleSize, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Text(
                  '$totalPoints ${AppStrings.pointsLabel}',
                  style: TextStyle(
                      fontSize: AppDimens.pointsSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.totalPointsColor),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
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
                const SizedBox(height: 15),

                if (progress < 1) ...[
                  const Text(
                    AppStrings.keepGoingMessage,
                    style: TextStyle(
                        fontSize: AppDimens.statsTextSize, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                ] else ...[
                  const Text(
                    AppStrings.congratulationsMessage,
                    style: TextStyle(
                        fontSize: AppDimens.statsTextSize, color: Colors.green),
                  ),
                  const SizedBox(height: 15),
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
                  totalChallengesCompleted: 0, // Placeholder if not tracked
                  pointsEarnedToday: pointsEarnedToday,
                  bestDayPoints: bestDayPoints,
                  streakDays: streakDays,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Determines the awards based on total points
  List<String> _determineAwards(int points) {
    List<String> awards = [];
    if (points >= 500) awards.add(AppStrings.bronzeTrophy);
    if (points >= 1000) awards.add(AppStrings.silverTrophy);
    if (points >= 2000) awards.add(AppStrings.goldTrophy);
    if (points >= 5000) awards.add(AppStrings.platinumTrophy);
    return awards;
  }

  // Determines the rank based on total points
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