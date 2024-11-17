import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../settings/badge_service.dart';

class UserChallengesPage extends StatefulWidget {
  const UserChallengesPage({super.key});

  @override
  State<UserChallengesPage> createState() => _UserChallengesPageState();
}

class _UserChallengesPageState extends State<UserChallengesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mark a challenge as completed
  Future<void> markChallengeAsCompleted(String challengeId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('challenges')
          .doc(challengeId)
          .update({'challengeCompleted': true});

      // Check for badge eligibility after marking challenge as completed
      await BadgeService().awardPointsAndCheckBadges(currentUser.uid, 0, 'challengeCompleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Challenges')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('challenges')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No challenges found.'));
          }

          final challenges = snapshot.data!.docs;

          return ListView.builder(
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challengeData = challenges[index];
              final data = challengeData.data() as Map<String, dynamic>?;

              // Safely check if 'challengeCompleted' exists and set default to false if missing
              final bool isCompleted = data != null && data.containsKey('challengeCompleted')
                  ? data['challengeCompleted']
                  : false;

              return ListTile(
                title: Text(data?['challengeName'] ?? 'Unnamed Challenge'),
                subtitle: Text('Status: ${isCompleted ? "Completed" : "Pending"}'),
                trailing: isCompleted
                    ? const Icon(Icons.check, color: Colors.green)
                    : IconButton(
                  icon: const Icon(Icons.check_box_outline_blank),
                  onPressed: () {
                    markChallengeAsCompleted(challengeData.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}