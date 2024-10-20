import 'package:fitbattles/models/challenge.dart'; // Assuming the Challenge model is in this path
import 'package:fitbattles/settings/app_strings.dart'; // Assuming this has the localized strings

class ChallengeData {
  // A static list of predefined challenges
  static final List<Challenge> challenges = [
    Challenge(
      id: '1', // Unique ID for each challenge
      name: AppStrings.stepsChallenge, // Localized string
      type: AppStrings.fitnessChallenge, // Localized string
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [], // Empty participants initially
      description: 'Complete 10,000 steps each day for a week.', // Optional description
    ),
    Challenge(
      id: '2',
      name: AppStrings.runningChallenge, // Localized string
      type: AppStrings.fitnessChallenge, // Localized string
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [],
      description: 'Run at least 5 kilometers each day for a week.',
    ),
    Challenge(
      id: '3',
      name: AppStrings.healthyEatingChallenge, // Localized string
      type: AppStrings.fitnessChallenge, // Localized string
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      participants: [],
      description: 'Follow a healthy meal plan for 30 days.',
    ),
    Challenge(
      id: '4',
      name: AppStrings.sitUpChallenge, // Localized string
      type: AppStrings.fitnessChallenge, // Localized string
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [],
      description: 'Perform 100 sit-ups daily for a week.',
    ),
    Challenge(
      id: '5',
      name: AppStrings.squatChallenge, // Localized string
      type: AppStrings.fitnessChallenge, // Localized string
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      participants: [],
      description: 'Perform 100 squats daily for 30 days.',
    ),
  ];
}
