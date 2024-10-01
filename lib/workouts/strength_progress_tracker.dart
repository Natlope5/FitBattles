// strength_progress_tracker.dart

// Class representing a strength workout session with properties for repetitions, sets, and weight lifted.
class StrengthWorkout {
  int reps; // The number of repetitions performed in each set.
  int sets; // The number of sets completed.
  double weight; // The weight used for the exercise, typically in kilograms or pounds.

  // Constructor for initializing the StrengthWorkout with required parameters.
  StrengthWorkout({required this.reps, required this.sets, required this.weight});

  // Method to calculate the total volume of the workout, which is the product of reps, sets, and weight.
  double calculateVolume() {
    return reps * sets * weight; // Returns the calculated volume.
  }
}
