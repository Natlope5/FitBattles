import 'package:fitbattles/challenges/challenge.dart';

class ChallengeData {
  // A static list of predefined challenges
  static final List<Challenge> challenges = [
    Challenge(
      name: '10,000 Steps Challenge',
      type: 'Fitness',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [],
    ),
    Challenge(
      name: 'Running Challenge',
      type: 'Fitness',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [],
    ),
    Challenge(
      name: 'Healthy Eating Challenge',
      type: 'Fitness',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      participants: [],
    ),
    Challenge(
      name: 'SitUp Challenge',
      type: 'Fitness',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      participants: [],
    ),
    Challenge(
      name: '100 Squat Challenge',
      type: 'Fitness',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      participants: [],
    ),
  ];
}
