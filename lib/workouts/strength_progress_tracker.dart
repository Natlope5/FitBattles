// strength_progress_tracker.dart

/// Class representing a strength workout session with properties for repetitions, sets, and weight lifted.
class StrengthWorkout {
  final int reps; // The number of repetitions performed in each set.
  final int sets; // The number of sets completed.
  final double weight; // The weight used for the exercise, typically in kilograms or pounds.

  /// Constructor for initializing the StrengthWorkout with required parameters.
  /// Throws an ArgumentError if any parameter is invalid (non-positive).
  StrengthWorkout({required this.reps, required this.sets, required this.weight}) :
        assert(reps > 0, 'Reps must be a positive number.'),
        assert(sets > 0, 'Sets must be a positive number.'),
        assert(weight > 0, 'Weight must be a positive number.');

  /// Method to calculate the total volume of the workout, which is the product of reps, sets, and weight.
  double calculateVolume() {
    return reps * sets * weight; // Returns the calculated volume.
  }

  /// Returns a string representation of the StrengthWorkout.
  @override
  String toString() {
    return 'StrengthWorkout(reps: $reps, sets: $sets, weight: $weight, volume: ${calculateVolume()})';
  }
}
