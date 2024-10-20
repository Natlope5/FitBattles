import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  String? id;
  String name;
  String type;
  DateTime startDate;
  DateTime endDate;
  List<String> participants;

  Challenge({
    this.id,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.participants,
  });

  // Convert a Challenge object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'participants': participants,
      description: 'Complete 10,000 steps each day for a week.',
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
    );
  }

  get description => null;
}