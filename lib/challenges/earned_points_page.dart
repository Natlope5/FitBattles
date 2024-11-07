import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:fitbattles/settings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:fitbattles/points/earned_points_awards_section.dart';
import 'package:fitbattles/points/earned_points_stats_section.dart';
import 'package:fitbattles/settings/points_service.dart';

class EarnedPointsPage extends StatelessWidget {
  final String userId;

  const EarnedPointsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    PointsService pointsService = PointsService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.earnedPointsTitle),
        backgroundColor: AppColors.appBarColor,
      ),
      body: FutureBuilder<int>(
        future: pointsService.calculateTotalPoints(userId), // Get the total points
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final totalPoints = snapshot.data ?? 0;
          double progress = totalPoints / 1000; // Assuming 1000 points is the goal
          List<String> awards = _determineAwards(totalPoints);
          String rank = _determineRank(totalPoints);

          return Padding(
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
                  '$totalPoints ${AppStrings.pointsLabel}',
                  style: TextStyle(
                      fontSize: AppDimens.pointsSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.totalPointsColor),
                ),
                const SizedBox(height: 20),
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
                  totalChallengesCompleted: (snapshot.data ?? 0), // Adjust if needed
                  pointsEarnedToday: 0, // You can add logic here if needed
                  bestDayPoints: 0, // You can add logic here if needed
                  streakDays: 0, // You can add logic here if needed
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