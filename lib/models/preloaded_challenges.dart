import 'package:flutter/material.dart';
import 'package:fitbattles/challenges/challenge.dart' as challenges; // Alias for challenges
import 'package:fitbattles/challenges/challenge_data.dart';
import 'package:fitbattles/settings/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:fitbattles/settings/app_strings.dart';

class PreloadedChallengesPage extends StatefulWidget {
  const PreloadedChallengesPage({super.key});

  @override
  PreloadedChallengesPageState createState() => PreloadedChallengesPageState();
}

class PreloadedChallengesPageState extends State<PreloadedChallengesPage> {
  String? selectedChallengeId; // State to track the selected challenge
  final List<challenges.Challenge> preloadedChallenges = ChallengeData
      .challenges.cast<challenges.Challenge>(); // Use the predefined challenges
  bool _isStartingChallenge = false; // State to track if a challenge is starting

  @override
  Widget build(BuildContext context) {
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
                    ? Border.all(color: AppColors.selectedChallengeColor,
                    width: 2) // Use selected color
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withAlpha(128),
                    // Use shadow color
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
                      color: isSelected
                          ? AppColors.selectedChallengeColor
                          : AppColors.defaultTextColor, // Use selected color
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${AppStrings.challengeTypeLabel} ${challenge.type}',
                    style: const TextStyle(
                        fontSize: AppDimens.textSizeSubtitle),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${AppStrings.challengeDurationLabel} ${challenge.startDate
                        .toLocal().toString().split(' ')[0]} - ${challenge
                        .endDate.toLocal().toString().split(' ')[0]}',
                    // Format dates
                    style: const TextStyle(
                        fontSize: AppDimens.textSizeSubtitle),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showChallengeInfo(challenges.Challenge challenge) {
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
              Text('${AppStrings.challengeDurationLabel} ${challenge.startDate
                  .toLocal().toString().split(' ')[0]} - ${challenge.endDate
                  .toLocal().toString().split(' ')[0]}'),
              const SizedBox(height: 10),
              Text(challenge.description ?? ''),
              // Display challenge description if available
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(AppStrings
                  .backButtonLabel), // Use the localized back button text
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _startChallenge(challenge, (errorMessage) {
                  if (errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            errorMessage), // Display the error message if it exists
                      ),
                    );
                  }
                }); // Call start challenge logic
              },
              child: _isStartingChallenge
                  ? const CircularProgressIndicator()
                  : const Text(AppStrings
                  .startChallengeButtonLabel), // Use the localized start challenge button text
            ),
          ],
        );
      },
    );
  }

  Future<String?> _saveStartedChallengeToFirestore(
      challenges.Challenge challenge) async {
    try {
      final docRef = await FirebaseFirestore.instance.collection(
          'startedChallenges').add({
        'challengeId': challenge.id,
        'userId': 'exampleUserId', // Replace with actual user ID
        'startDate': DateTime.now(),
      });
      return docRef.id; // Return the document ID if successful
    } catch (e) {
      return 'Error starting challenge: $e'; // Return the error message
    }
  }

  void _startChallenge(challenges.Challenge challenge,
      Function(String?) onError) async {
    setState(() {
      _isStartingChallenge =
      true; // Set the state to indicate a challenge is starting
    });

    // Call the method to save the started challenge to Firestore
    String? result = await _saveStartedChallengeToFirestore(challenge);

    // Check if the widget is still mounted before using BuildContext
    if (!mounted) return;

    // Check if the result is a document ID or an error message
    if (result != null && result.isNotEmpty && !result.startsWith('Error')) {
      // Successfully started the challenge
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Challenge started successfully!'), // Success message
        ),
      );
    } else {
      // An error occurred
      onError(result); // Handle error
    }

    setState(() {
      _isStartingChallenge =
      false; // Reset the state after the challenge starts
    });
  }
}