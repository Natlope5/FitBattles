import 'package:flutter/material.dart';
import 'package:fitbattles/challenges/challenge.dart' as challenges; // Alias for challenges
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:fitbattles/settings/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth to get the current user

import '../main.dart'; // Ensure logger is configured here

class StartedChallengesPage extends StatefulWidget {
  const StartedChallengesPage({super.key, required this.startedChallenge});

  final challenges.Challenge startedChallenge; // Property to hold the challenge

  @override
  StartedChallengesPageState createState() => StartedChallengesPageState();
}

class StartedChallengesPageState extends State<StartedChallengesPage> {
  final List<challenges.Challenge> startedChallenges = []; // State to hold the started challenges
  bool _isLoading = true; // State to track loading status

  @override
  void initState() {
    super.initState();
    _fetchStartedChallenges(); // Fetch started challenges when the page initializes
  }

  Future<void> _fetchStartedChallenges() async {
    setState(() {
      _isLoading = true; // Set loading state at the start
    });

    try {
      // Use FirebaseAuth to get the actual user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('startedChallenges')
            .where('userId', isEqualTo: userId) // Ensure this is allowed by your Firestore rules
            .get();

        List<challenges.Challenge> fetchedChallenges = [];

        for (var doc in querySnapshot.docs) {
          if (doc.data().containsKey('challengeId')) {
            final challengeId = doc['challengeId'];
            final challenge = await _getChallengeDetails(challengeId);
            if (challenge != null) {
              fetchedChallenges.add(challenge);
            } else {
              logger.e('Challenge with ID $challengeId not found.');
            }
          } else {
            logger.e('Document ${doc.id} does not contain a challengeId field');
          }
        }

        setState(() {
          startedChallenges.addAll(fetchedChallenges); // Add all challenges to the list at once
        });
      } else {
        logger.i('User is not authenticated');
      }
    } catch (e) {
      logger.e('Error fetching started challenges: $e'); // Ensure logger is initialized in your main.dart
    } finally {
      setState(() {
        _isLoading = false; // Update loading status
      });
    }
  }


  Future<challenges.Challenge?> _getChallengeDetails(String challengeId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('challenges').doc(challengeId).get();

      if (doc.exists) {
        final name = doc['name'] ?? '';
        final description = doc['description'] ?? '';
        final type = doc['type'] ?? '';

        // Check for empty fields and log the challengeId
        if (name.isEmpty || description.isEmpty || type.isEmpty) {
          logger.i(
              'Challenge fields cannot be empty: id = $challengeId, name = "$name", type = "$type", description = "$description"');
          return null; // Return null if any field is empty
        }

        return challenges.Challenge(
          id: challengeId,
          name: name,
          description: description,
          type: type,
          startDate: (doc['startDate'] as Timestamp).toDate(),
          endDate: (doc['endDate'] as Timestamp).toDate(),
          participants: [], opponentId: '', // Adjust this if you have participants data
        );
      }
    } catch (e) {
      logger.i('Error fetching challenge details: $e');
    }
    return null; // Return null if document doesn't exist or if an error occurs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.startedChallengesTitle),
        backgroundColor: AppColors.appBarColor,
      ),
      body: _isLoading
          ? Center(child: const CircularProgressIndicator())
          : startedChallenges.isEmpty
          ? Center(
        child: Text(
          AppStrings.noChallengesMessage,
          style: TextStyle(
            fontSize: AppDimens.textSizeTitle,
            color: AppColors.primaryTextColor,
          ),
        ),
      )
          : ListView.builder(
        itemCount: startedChallenges.length,
        itemBuilder: (context, index) {
          final challenge = startedChallenges[index];

          return GestureDetector(
            onTap: () {
              _showChallengeInfo(challenge);
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: AppDimens.marginVertical),
              padding: EdgeInsets.all(AppDimens.padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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
              Text('${AppStrings.challengeDurationLabel} ${challenge.startDate.toLocal().toString().split(' ')[0]} - ${challenge.endDate.toLocal().toString().split(' ')[0]}'),
              const SizedBox(height: 10),
              // Assuming there's a description attribute in the Challenge model
              Text(challenge.description),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(AppStrings.backButtonLabel),
            ),
          ],
        );
      },
    );
  }
}
