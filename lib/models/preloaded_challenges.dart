import 'package:fitbattles/challenges/challenge.dart';
import 'package:flutter/material.dart';
import 'package:fitbattles/challenges/challenge_data.dart';
import 'package:fitbattles/settings/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:fitbattles/settings/app_strings.dart';
import 'package:fitbattles/screens/started_challenges_page.dart';
import 'package:fitbattles/challenges/challenge.dart' as challenges;
import '../main.dart';

class PreloadedChallengesPage extends StatefulWidget {
  const PreloadedChallengesPage({super.key});

  @override
  PreloadedChallengesPageState createState() => PreloadedChallengesPageState();
}

class PreloadedChallengesPageState extends State<PreloadedChallengesPage> {
  String? selectedChallengeId; // State to track the selected challenge
  List<Challenge> preloadedChallenges = []; // Start with an empty list
  bool _isStartingChallenge = false; // State to track if a challenge is starting

  @override
  void initState() {
    super.initState();
    _loadChallenges(); // Load challenges when the page is initialized
  }

  Future<void> _loadChallenges() async {
    List<Challenge> challenges = (await ChallengeData.fetchChallenges()).cast<Challenge>();
    setState(() {
      preloadedChallenges = challenges; // Update the challenges list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preloaded Challenges'),
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
                selectedChallengeId = challenge.id; // Update selected challenge
              });
              _showChallengeInfo(challenge); // Show challenge info when tapped
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: AppDimens.marginVertical),
              padding: EdgeInsets.all(AppDimens.padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: AppColors.selectedChallengeColor, width: 2) // Change border if selected
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withAlpha(128),
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
                      color: isSelected ? AppColors.selectedChallengeColor : AppColors.defaultTextColor, // Change text color if selected
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${AppStrings.challengeTypeLabel} ${challenge.type}',
                    style: const TextStyle(fontSize: AppDimens.textSizeSubtitle),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${AppStrings.challengeDurationLabel} ${challenge.startDate.toLocal().toString().split(' ')[0]} - ${challenge.endDate.toLocal().toString().split(' ')[0]}',
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
    // Ensure that challengeId is non-nullable
    String? challengeId = challenge.id; // Assuming challenge has a non-nullable id property

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
              Text(
                '${AppStrings.challengeDurationLabel} ${challenge.startDate.toLocal().toString().split(' ')[0]} - ${challenge.endDate.toLocal().toString().split(' ')[0]}',
              ),
              const SizedBox(height: 10),
              Text(challenge.description.isNotEmpty ? challenge.description : 'No description available'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(AppStrings.backButtonLabel),
            ),
            TextButton(
              onPressed: _isStartingChallenge
                  ? null
                  : () {
                // Start the challenge
                _startChallenge(challengeId!, (String id) {
                  // Navigate to StartedChallengesPage with the started challenge
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        // Here we are assuming you have a method to get started challenge by id
                        final startedChallenge = ChallengeData.getAllChallenges().firstWhere(
                              (ch) => ch.id == id,
                          orElse: () => challenges.Challenge(
                            id: id,
                            name: 'Challenge Not Found',
                            type: 'Unknown',
                            startDate: DateTime.now(),
                            endDate: DateTime.now().add(const Duration(days: 7)),
                            participants: [],
                            description: 'This challenge could not be found.', opponentId: '',
                          ),
                        );

                        return StartedChallengesPage(
                          startedChallenge: startedChallenge, // Pass the started challenge
                        );
                      },
                    ),
                  );
                });
              },
              child: _isStartingChallenge
                  ? const CircularProgressIndicator()
                  : const Text(AppStrings.startChallengeButtonLabel),
            ),
          ],
        );
      },
    );
  }

  void _startChallenge(String challengeId, Function(String) navigate) async {
    setState(() {
      _isStartingChallenge = true; // Update loading state
    });

    try {
      // Perform the Firestore operation to save the started challenge
      await FirebaseFirestore.instance.collection('startedChallenges').add({
        'challengeId': challengeId,
        'userId': 'exampleUserId', // Replace with actual user ID
        'startDate': DateTime.now(),
      });

      // Update the user profile to include the new challenge
      await FirebaseFirestore.instance.collection('users').doc('exampleUserId').update({
        'startedChallenges': FieldValue.arrayUnion([challengeId]), // Add challenge ID to the user's startedChallenges array
      });

      // Call the navigate function with the challengeId
      navigate(challengeId); // This can be the ID of the newly created challenge if needed
    } catch (e) {
      // Handle error appropriately
      logger.i('Error starting challenge: $e');
    } finally {
      setState(() {
        _isStartingChallenge = false; // Update loading state
      });
    }
  }
}
