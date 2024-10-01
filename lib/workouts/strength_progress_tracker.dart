// strength_progress_tracker.dart
class StrengthWorkout {
  int reps;
  int sets;
  double weight;

  StrengthWorkout({required this.reps, required this.sets, required this.weight});

  double calculateVolume() {
    return reps * sets * weight;
  }
}
