import 'package:fitbattles/services/firebase/badge_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class UserChallengesPage extends StatefulWidget {
  const UserChallengesPage({super.key});

  @override
  UserChallengesPageState createState() => UserChallengesPageState();
}

class UserChallengesPageState extends State<UserChallengesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance for local notifications
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // Initialize local notifications
  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    _localNotificationsPlugin.initialize(initializationSettings);
  }

  // Show local notification
  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'challenge_notifications_channel',
      'Challenge Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }

  // Check notification settings and show a notification if enabled
  Future<void> _notifyChallengeCompleted() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final settingsDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('settings')
          .doc('notifications')
          .get();

      final settingsData = settingsDoc.data();
      if (settingsData != null
          && settingsData['challengeNotifications'] == true
          && settingsData['receiveNotifications'] == true) {
        await _showLocalNotification(
          "Challenge Completed!",
          "Congratulations on completing your challenge!",
        );
      }
    }
  }

  // Mark a challenge as completed and handle notifications
  Future<void> markChallengeAsCompleted(
      String challengeId, String collection) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore
          .collection(collection)
          .doc(challengeId)
          .update({'challengeCompleted': true});

      // Check for badge eligibility after marking challenge as completed
      await BadgeService()
          .awardPointsAndCheckBadges(currentUser.uid, 0, 'challengeCompleted');

      // Trigger a notification if enabled
      await _notifyChallengeCompleted();
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

          final userChallenges = userSnapshot.data?.docs ?? [];

          final communityChallenges = userChallenges
              .where((doc) =>
          (doc.data() as Map<String, dynamic>?)?['communityChallenge'] ==
              true)
              .toList();

          final normalChallenges = userChallenges
              .where((doc) =>
          (doc.data() as Map<String, dynamic>?)?['communityChallenge'] !=
              true)
              .toList();

          return ListView(
            children: [
              if (normalChallenges.isNotEmpty)
                _buildChallengeSection('Your Challenges', normalChallenges),
              if (communityChallenges.isNotEmpty)
                _buildChallengeSection(
                    'Community Challenges', communityChallenges),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChallengeSection(
      String title, List<QueryDocumentSnapshot> challenges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...challenges.map((challengeData) {
          final data = challengeData.data() as Map<String, dynamic>?;
          final bool isCompleted =
              data != null && data['challengeCompleted'] == true;

          return _buildChallengeTile(
            challengeData.id,
            data?['challengeName'] ?? 'Unnamed Challenge',
            isCompleted,
            data?['startDate'] != null
                ? (data!['startDate'] as Timestamp).toDate()
                : null,
            data?['endDate'] != null
                ? (data!['endDate'] as Timestamp).toDate()
                : null,
            'users/${_auth.currentUser!.uid}/challenges',
          );
        }),
      ],
    );
  }

  Widget _buildChallengeTile(
      String id,
      String name,
      bool isCompleted,
      DateTime? startDate,
      DateTime? endDate,
      String collection,
      ) {
    final dateText = startDate != null && endDate != null
        ? 'From: ${_formatDate(startDate)} To: ${_formatDate(endDate)}'
        : 'Dates: Not specified';

    return GestureDetector(
      onLongPress: () {
        _fetchAndShowChallengeDetails(name);
      },
      child: ListTile(
        title: Text(name),
        subtitle: Text(
            'Status: ${isCompleted ? "Completed" : "Pending"}\n$dateText'),
        trailing: isCompleted
            ? const Icon(Icons.check, color: Colors.green)
            : IconButton(
          icon: const Icon(Icons.check_box_outline_blank),
          onPressed: () {
            markChallengeAsCompleted(id, collection);
          },
        ),
      ),
    );
  }

  Future<void> _fetchAndShowChallengeDetails(String challengeName) async {
    try {
      final doc = await _firestore
          .collection('communityChallenges')
          .doc(challengeName)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final description = data?['description'] ?? 'No description provided';
        final goal = data?['goal'] ?? 'No goal provided';
        final intensity = data?['intensity']?.toString() ?? 'Not specified';

        _showChallengeDetailsDialog(challengeName, description, goal, intensity);
      } else {
        _showErrorDialog('Challenge details not found.');
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch challenge details.');
    }
  }

  void _showChallengeDetailsDialog(
      String name, String description, String goal, String intensity) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description:',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description),
                const SizedBox(height: 8),
                Text('Goal:',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(goal),
                const SizedBox(height: 8),
                Text('Intensity:',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(intensity),
                const SizedBox(height: 8),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}