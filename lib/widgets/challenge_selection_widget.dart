import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/models/challenge.dart'; // Ensure you're using only this Challenge class
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
    final localizations = AppLocalizations.of(context); // Get localizations

    return Column(
      children: [
        DropdownButton<Challenge>(
          hint: Text(localizations.selectChallenge), // Localized string
          value: selectedChallenge,
          onChanged: (Challenge? newValue) {
            setState(() {
              selectedChallenge = newValue;
            });
          },
          items: ChallengeData.challenges.map<DropdownMenuItem<Challenge>>((Challenge challenge) {
            return DropdownMenuItem<Challenge>(
              value: challenge,
              child: Text(challenge.name), // Display the challenge name
            );
          }).toList(),
        ),
        SizedBox(height: AppDimens.paddingMedium), // Add padding
        ElevatedButton(
          onPressed: () {
            if (selectedChallenge != null) {
              String opponentToken = "example_opponent_token"; // Replace with actual opponent token
              sendChallengeNotification(opponentToken, selectedChallenge!, localizations);
            } else {
              // Show a message if no challenge is selected
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(localizations.selectChallenge), // Localized message
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, AppDimens.buttonHeightMedium),
            backgroundColor: AppColors.primaryColor, // Use primary color
          ),
          child: Text(localizations.sendChallenge), // Localized string
        ),
      ],
    );
  }

  Future<void> sendChallengeNotification(String opponentToken, Challenge selectedChallenge, AppLocalizations localizations) async {
    try {
      // Construct the challenge message using localization
      final challengeMessage = localizations.challengeSent; // Localized "Challenge Sent"
      final messageBody = '${localizations.replacePlaceholder} ${selectedChallenge.name}'; // Custom message body

      // Add the notification data to Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'to': opponentToken,
        'notification': {
          'title': localizations.sendChallenge, // Localized title
          'body': messageBody, // Custom message body
        },
        'data': {
          'challengeId': selectedChallenge.id,
        },
      });

      // Show success message using the GlobalKey
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(challengeMessage)), // Display localized "Challenge Sent"
      );

      logger.i('Challenge sent: ${selectedChallenge.name}'); // Log success message
    } catch (e) {
      logger.e('Error sending notification: $e'); // Log error

      // Show error message using the GlobalKey
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(localizations.errorSendingNotification)), // Display localized error message
      );
    }
  }
}
