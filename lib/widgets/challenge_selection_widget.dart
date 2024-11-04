import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/challenges/challenge.dart';
import 'package:fitbattles/challenges/challenge_data.dart';
import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class ChallengeSelectionWidget extends StatefulWidget {
  const ChallengeSelectionWidget({super.key});

  @override
  ChallengeSelectionWidgetState createState() => ChallengeSelectionWidgetState();
}

class ChallengeSelectionWidgetState extends State<ChallengeSelectionWidget> {
  Challenge? selectedChallenge;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<Challenge>(
          hint: const Text('Select a Challenge'), // Hardcoded hint text
          value: selectedChallenge,
          onChanged: (Challenge? newValue) {
            setState(() {
              selectedChallenge = newValue;
            });
          },
          items: ChallengeData.challenges.map<DropdownMenuItem<Challenge>>((Challenge challenge) {
            return DropdownMenuItem<Challenge>(
              value: challenge,
              child: Text(challenge.name),
            );
          }).toList(),
        ),
        SizedBox(height: AppDimens.paddingMedium), // Add padding
        ElevatedButton(
          onPressed: () {
            if (selectedChallenge != null) {
              String opponentToken = "example_opponent_token"; // Replace with the actual FCM token of the opponent
              sendChallengeNotification(opponentToken, selectedChallenge!);
            } else {
              // Show a message if no challenge is selected
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(content: const Text('Please select a challenge')), // Hardcoded message
              );
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, AppDimens.buttonHeightMedium),
            backgroundColor: AppColors.primaryColor, // Use primary color from app colors
          ),
          child: const Text('Send Challenge'), // Hardcoded button text
        ),
      ],
    );
  }

  Future<void> sendChallengeNotification(String opponentToken, Challenge selectedChallenge) async {
    try {
      final challengeMessage = 'Challenge Sent'; // Hardcoded message for "Challenge Sent"
      final messageBody = 'You have been challenged to ${selectedChallenge.name}'; // Hardcoded message body

      await FirebaseFirestore.instance.collection('notifications').add({
        'to': opponentToken,
        'notification': {
          'title': 'Challenge Sent', // Hardcoded title
          'body': messageBody, // Use customized message body
        },
        'data': {
          'challengeId': selectedChallenge.id ?? '',
        },
      });

      // Use the GlobalKey to show the SnackBar
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(challengeMessage)), // Display hardcoded "Challenge Sent" message
      );

      logger.i('Challenge sent: ${selectedChallenge.name}'); // Log the success message
    } catch (e) {
      logger.e('Error sending notification: $e'); // Log the error message
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: const Text('Error loading leaderboard')), // Hardcoded error message
      );
    }
  }
}
