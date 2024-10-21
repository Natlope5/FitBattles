import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  final String id;
  final String name;
  final String description;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participants;

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.participants,
  });

  // Factory constructor to create a Challenge object from Firestore data
  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    return Challenge(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      participants: List<String>.from(data['participants'] ?? []),
    );
  }
}
