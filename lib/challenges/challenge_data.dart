import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitbattles/challenges/challenge.dart';
import 'package:fitbattles/settings/app_strings.dart';


import '../main.dart'; // Assuming this has the localized strings

class ChallengeData {
  // A static list of predefined challenges
  static final List<Challenge> challenges = [
    Challenge(
      id: '1',
      name: AppStrings.stepsChallenge, // Localized string
      type: AppStrings.fitnessChallenge, // Localized string
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [],
      description: AppStrings.stepsChallengeDescription, opponentId: '', // Localized description
    ),
    Challenge(
      id: '2',
      name: AppStrings.runningChallenge, // Localized string
      type: AppStrings.fitnessChallenge, // Localized string
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [],
      description: AppStrings.runningChallengeDescription, opponentId: '', // Localized description
    ),
    Challenge(
      id: '3',
      name: AppStrings.healthyEatingChallenge, // Localized string
      type: AppStrings.fitnessChallenge, // Localized string
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      participants: [],
      description: AppStrings.healthyEatingChallengeDescription, opponentId: '', // Localized description
    ),
    Challenge(
      id: '4',
      name: AppStrings.sitUpChallenge, // Localized string
      type: AppStrings.fitnessChallenge, // Localized string
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [],
      description: AppStrings.sitUpChallengeDescription, opponentId: '', // Localized description
    ),
    Challenge(
      id: '5',
      name: AppStrings.squatChallenge, // Localized string
      type: AppStrings.fitnessChallenge, // Localized string
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      participants: [],
      description: AppStrings.squatChallengeDescription, opponentId: '', // Localized description
    ),
  ];

  // Constructor to initialize a ChallengeData instance
  ChallengeData();

  // Static method to get all challenges
  static List<Challenge> getAllChallenges() {
    return challenges;
  }

  static Future<List<Challenge>> fetchChallenges() async {
    List<Challenge> challengesList = [];

    try {
      // Fetch challenges from Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('challenges').get();

      for (var doc in snapshot.docs) {
        challengesList.add(Challenge(
          id: doc.id, // Use the document ID
          name: doc['name'],
          description: doc['description'],
          type: doc['type'],
          startDate: (doc['startDate'] as Timestamp).toDate(),
          endDate: (doc['endDate'] as Timestamp).toDate(),
          participants: List<String>.from(doc['participants'] ?? []), opponentId: '',
        ));
      }
    } catch (e) {
      // Handle errors and possibly inform the user
      logger.i('Error fetching challenges: $e');
    }

    return challengesList;
  }
}
