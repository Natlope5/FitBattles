import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/challenges/challenge.dart';
import 'package:fitbattles/challenges/challenge_data.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
// Import your preloaded challenges

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
          hint: const Text('Select Challenge'),
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
        ElevatedButton(
          onPressed: () {
            if (selectedChallenge != null) {
              String opponentToken = "example_opponent_token"; // Replace with the actual FCM token of the opponent
              sendChallengeNotification(opponentToken, selectedChallenge!);
            }
          },
          child: const Text('Send Challenge'),
        ),
      ],
    );
  }

  Future<void> sendChallengeNotification(String opponentToken,
      Challenge selectedChallenge) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'to': opponentToken,
        'notification': {
          'title': 'Challenge Invitation',
          'body': 'You have been challenged to ${selectedChallenge.name}!',
        },
        'data': {
          'challengeId': selectedChallenge.id ?? '',
        },
      });

      // Use the GlobalKey to show the SnackBar
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Challenge sent: ${selectedChallenge.name}')),
      );

      logger.i('Challenge sent: ${selectedChallenge
          .name}'); // Log the success message
    } catch (e) {
      logger.e('Error sending notification: $e'); // Log the error message
    }
  }
}
