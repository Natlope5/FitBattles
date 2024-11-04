import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutPlan {
  final String name;
  final List<Map<String, dynamic>> exercises;

  WorkoutPlan({required this.name, required this.exercises});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exercises': exercises,
    };
  }
}

Future<void> saveWorkoutPlan(WorkoutPlan workoutPlan) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workoutPlans')
        .add(workoutPlan.toMap());
  }
}
