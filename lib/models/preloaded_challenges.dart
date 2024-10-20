import 'package:flutter/material.dart';
import 'package:fitbattles/challenges/challenge.dart';
import 'package:fitbattles/challenges/challenge_data.dart';
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
    final List<Challenge> preloadedChallenges = ChallengeData.challenges.cast<Challenge>(); // Use ChallengeData for challenges

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
              _showChallengeInfo(challenge); // Show challenge info when tapped
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

  void _showChallengeInfo(Challenge challenge) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(challenge.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${AppStrings.challengeTypeLabel} ${challenge.type}'),
              const SizedBox(height: 5),
              Text('${AppStrings.challengeDurationLabel} ${challenge.startDate} - ${challenge.endDate}'),
              const SizedBox(height: 10),
              Text(challenge.description ?? ''), // Display challenge description if available
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(AppStrings.backButtonLabel), // Use the localized back button text
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _startChallenge(challenge); // Call start challenge logic
              },
              child: const Text(AppStrings.startChallengeButtonLabel), // Use the localized start challenge button text
            ),
          ],
        );
      },
    );
  }

  void _startChallenge(Challenge challenge) {
    // Your logic to start the challenge goes here

    // For demonstration, show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppStrings.challengeStartedMessage} ${challenge.name}'), // Localized success message
      ),
    );
  }
}
