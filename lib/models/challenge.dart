class Challenge {
  final String id;
  final String name;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participants;
  final String? description; // Add description field

  Challenge({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.participants,
    this.description, // Optional field
  });
}