import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserChallengesPage extends StatefulWidget {
  const UserChallengesPage({super.key});

  @override
  UserChallengesPageState createState() => UserChallengesPageState();
}

class UserChallengesPageState extends State<UserChallengesPage> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Challenges'),
        backgroundColor: const Color(0xFF5D6C8A),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('challenges')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final challenges = snapshot.data!.docs;

          if (challenges.isEmpty) {
            return const Center(child: Text('No challenges found.'));
          }

          return ListView.builder(
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return ListTile(
                title: Text(challenge['challengeName']),
                subtitle: Text(
                    'Type: ${challenge['challengeType']}\nStart: ${_formatDate(challenge['startDate'].toDate())}\nEnd: ${_formatDate(challenge['endDate'].toDate())}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _deleteChallenge(challenge.id);
                  },
                ),
                onTap: () {
                  // Optionally, navigate to a detailed view of the challenge
                  _showChallengeDetails(challenge);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Function to format DateTime to a readable string
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Function to delete a challenge
  Future<void> _deleteChallenge(String challengeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('challenges')
          .doc(challengeId)
          .delete();

      if (!mounted) return; // Ensure the widget is still mounted

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return; // Ensure the widget is still mounted

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting challenge: $e')),
      );
    }
  }

  // Function to show challenge details in a dialog
  void _showChallengeDetails(DocumentSnapshot challenge) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final participants = List<String>.from(challenge['participants']);
        return AlertDialog(
          title: Text(challenge['challengeName']),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Type: ${challenge['challengeType']}'),
                Text('Start Date: ${_formatDate(challenge['startDate'].toDate())}'),
                Text('End Date: ${_formatDate(challenge['endDate'].toDate())}'),
                const SizedBox(height: 10),
                const Text('Participants:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...participants.map((participant) => Text(participant)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}