import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/challenges/challenge.dart';
import 'package:fitbattles/challenges/challenge_data.dart';
import 'package:fitbattles/l10n/app_localizations.dart'; // Import localization
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
    final localizations = AppLocalizations.of(
        context); // Localizations for text

    return Column(
      children: [
        DropdownButton<Challenge>(
          hint: Text(localizations.selectChallenge), // Use localized string
          value: selectedChallenge,
          onChanged: (Challenge? newValue) {
            setState(() {
              selectedChallenge = newValue;
            });
          },
          items: ChallengeData.challenges.map<DropdownMenuItem<Challenge>>((
              Challenge challenge) {
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
              sendChallengeNotification(opponentToken, selectedChallenge!,
                  localizations); // Pass localizations
            } else {
              // Show a message if no challenge is selected
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(content: Text(localizations
                    .selectChallenge)), // Inform user to select a challenge
              );
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, AppDimens.buttonHeightMedium),
            backgroundColor: AppColors
                .primaryColor, // Use primary color from app colors
          ),
          child: Text(localizations.sendChallenge), // Use localized string
        ),
      ],
    );
  }

  Future<void> sendChallengeNotification(String opponentToken,
      Challenge selectedChallenge, AppLocalizations localizations) async {
    try {
      final challengeMessage = localizations
          .challengeSent; // Get the localized string for "Challenge Sent"
      final messageBody = '${localizations
          .replacePlaceholder} ${selectedChallenge
          .name}'; // You can customize the message body

      await FirebaseFirestore.instance.collection('notifications').add({
        'to': opponentToken,
        'notification': {
          'title': localizations.sendChallenge, // Use localized title
          'body': messageBody, // Use customized message body
        },
        'data': {
          'challengeId': selectedChallenge.id ?? '',
        },
      });

      // Use the GlobalKey to show the SnackBar
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(
            challengeMessage)), // Display "Challenge Sent" localized message
      );

      logger.i('Challenge sent: ${selectedChallenge
          .name}'); // Log the success message
    } catch (e) {
      logger.e('Error sending notification: $e'); // Log the error message
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(
            localizations.errorLoadingLeaderboard)), // Show error message
      );
    }
  }
}