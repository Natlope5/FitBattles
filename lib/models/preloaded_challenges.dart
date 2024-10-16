import 'package:flutter/material.dart';
import 'package:fitbattles/challenges/challenge.dart';
import 'package:fitbattles/challenges/challenge_data.dart'; // Ensure you import the ChallengeData
import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:fitbattles/settings/app_strings.dart';

class PreloadedChallengesPage extends StatefulWidget {
  const PreloadedChallengesPage({super.key});

  @override
  PreloadedChallengesPageState createState() => PreloadedChallengesPageState();
}

class PreloadedChallengesPageState extends State<PreloadedChallengesPage> {
  String? selectedChallengeId; // State to track the selected challenge

  @override
  Widget build(BuildContext context) {
    final List<Challenge> preloadedChallenges = ChallengeData.challenges; // Use ChallengeData for challenges

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.preloadedChallengesTitle),
        backgroundColor: AppColors.appBarColor,
      ),
      body: ListView.builder(
        itemCount: preloadedChallenges.length,
        itemBuilder: (context, index) {
          final challenge = preloadedChallenges[index];
          final isSelected = selectedChallengeId == challenge.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedChallengeId = challenge.id; // Update the selected challenge
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: AppDimens.marginVertical),
              padding: EdgeInsets.all(AppDimens.padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: AppColors.selectedChallengeColor, width: 2) // Use selected color
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withAlpha(128), // Use shadow color
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.name,
                    style: TextStyle(
                      fontSize: AppDimens.textSizeTitle,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.selectedChallengeColor : AppColors.defaultTextColor, // Use selected color
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${AppStrings.challengeTypeLabel} ${challenge.type}',
                    style: const TextStyle(fontSize: AppDimens.textSizeSubtitle),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${AppStrings.challengeDurationLabel} ${challenge.startDate} - ${challenge.endDate}',
                    style: const TextStyle(fontSize: AppDimens.textSizeSubtitle),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
