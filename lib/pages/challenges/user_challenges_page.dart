import 'package:fitbattles/firebase/badge_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserChallengesPage extends StatefulWidget {
  const UserChallengesPage({super.key});

  @override
  UserChallengesPageState createState() => UserChallengesPageState();
}

class UserChallengesPageState extends State<UserChallengesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mark a challenge as completed
  Future<void> markChallengeAsCompleted(String challengeId, String collection) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore
          .collection(collection)
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
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<QuerySnapshot>(
            future: _firestore.collection('communityChallenges').get(),
            builder: (context, communitySnapshot) {
              if (communitySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData && !communitySnapshot.hasData) {
                return const Center(child: Text('No challenges found.'));
              }

              final userChallenges = userSnapshot.data?.docs ?? [];
              final communityChallenges = communitySnapshot.data?.docs ?? [];

              return ListView(
                children: [
                  // Section for user-specific challenges
                  if (userChallenges.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Your Challenges',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...userChallenges.map((challengeData) {
                          final data = challengeData.data() as Map<String, dynamic>?;
                          final bool isCompleted = data != null && data['challengeCompleted'] == true;

                          return _buildChallengeTile(
                            challengeData.id,
                            data?['challengeName'] ?? 'Unnamed Challenge',
                            isCompleted,
                            'users/${_auth.currentUser!.uid}/challenges',
                          );
                        }),
                      ],
                    ),

                  // Section for community challenges
                  if (communityChallenges.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Community Challenges',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...communityChallenges.map((challengeData) {
                          final data = challengeData.data() as Map<String, dynamic>?;
                          final bool isCompleted = data != null && data['challengeCompleted'] == true;

                          return _buildChallengeTile(
                            challengeData.id,
                            data?['name'] ?? 'Community Challenge',
                            isCompleted,
                            'communityChallenges',
                          );
                        })
                      ],
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChallengeTile(String id, String name, bool isCompleted, String collection) {
    return ListTile(
      title: Text(name),
      subtitle: Text('Status: ${isCompleted ? "Completed" : "Pending"}'),
      trailing: isCompleted
          ? const Icon(Icons.check, color: Colors.green)
          : IconButton(
        icon: const Icon(Icons.check_box_outline_blank),
        onPressed: () {
          markChallengeAsCompleted(id, collection);
        },
      ),
    );
  }
}

