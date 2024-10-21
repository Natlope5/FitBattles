import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  String? id;
  String name;
  String type;
  DateTime startDate;
  DateTime endDate;
  List<String> participants;
  String description;
  String opponentId; // Add opponentId property

  Challenge({
    this.id,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.participants,
    required this.description,
    required this.opponentId, // Add opponentId to the constructor
  }) {
    // Validate required fields
    if (name.isEmpty || type.isEmpty || description.isEmpty || opponentId.isEmpty) {
      throw ArgumentError('Name, type, description, and opponentId cannot be empty');
    }
  }

  // Convert a Challenge object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'participants': participants,
      'description': description,
      'opponentId': opponentId, // Include opponentId in the map
    };
  }

  // Create a Challenge object from a Firestore document
  factory Challenge.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Challenge(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      participants: List<String>.from(data['participants'] ?? []),
      description: data['description'] ?? '',
      opponentId: data['opponentId'] ?? '', // Retrieve opponentId from Firestore
    );
  }

  @override
  String toString() {
    return 'Challenge(id: $id, name: $name, type: $type, startDate: $startDate, endDate: $endDate, participants: $participants, description: $description, opponentId: $opponentId)'; // Include opponentId in toString
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Challenge) return false;
    return id == other.id &&
        name == other.name &&
        type == other.type &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        participants == other.participants &&
        description == other.description &&
        opponentId == other.opponentId; // Include opponentId in equality check
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    type.hashCode ^
    startDate.hashCode ^
    endDate.hashCode ^
    participants.hashCode ^
    description.hashCode ^
    opponentId.hashCode; // Include opponentId in hashCode
  }
}

// Separate class to manage a collection of challenges (optional)
class ChallengeManager {
  final List<Challenge> _challenges = [];

  // Method to add a Challenge to the list
  void addChallenge(Challenge challenge) {
    _challenges.add(challenge);
  }

  // Method to retrieve all challenges
  List<Challenge> get challenges => _challenges;

  // Retrieve a challenge by ID
  Challenge? getChallengeById(String id) {
    return _challenges.firstWhere(
          (challenge) => challenge.id == id,
      orElse: () => Challenge(
        id: '',
        name: 'Unknown',
        type: 'Unknown',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 1)),
        participants: [],
        description: 'No challenge found.',
        opponentId: '', // Default value for opponentId
      ),
    );
  }
}
