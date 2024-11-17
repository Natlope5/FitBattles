import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart'; // For permission handling

import '../../main.dart';
import '../../firebase/badge_service.dart';

class UserChallengesPage extends StatefulWidget {
  const UserChallengesPage({super.key});

  @override
  State<UserChallengesPage> createState() => _UserChallengesPageState();
}

class _UserChallengesPageState extends State<UserChallengesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize notification plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Initialize the time zone database
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permission for notifications
    _requestNotificationPermission();
  }

  // Request notification permissions
  Future<void> _requestNotificationPermission() async {
    final permissionStatus = await Permission.notification.request();
    if (permissionStatus.isGranted) {
      logger.i("Notification permission granted.");
    } else {
      logger.i("Notification permission denied.");
    }
  }

  // Schedule a notification
  Future<void> _scheduleNotification(DateTime dateTime, String message) async {
    final scheduledTime = tz.TZDateTime.from(dateTime, tz.local);

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'challenge_channel',
      'Challenge Notifications',
      channelDescription: 'Notifications related to challenges',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    try {
      logger.i("Scheduling notification for: $scheduledTime");
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0, // notification ID
        'Challenge Reminder', // notification title
        message, // notification message
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact, // Use exact schedule mode
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time, // Match only time for scheduling
      );
      logger.i("Notification scheduled successfully.");
    } catch (e) {
      logger.i("Error scheduling notification: $e");
    }
  }

  // Mark a challenge as completed
  Future<void> markChallengeAsCompleted(String challengeId, bool isCommunityChallenge) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final challengeCollection = isCommunityChallenge
          ? _firestore.collection('communityChallenges')
          : _firestore.collection('users').doc(currentUser.uid).collection('challenges');

      await challengeCollection.doc(challengeId).update({'challengeCompleted': true});

      // Check for badge eligibility after marking challenge as completed
      await BadgeService().awardPointsAndCheckBadges(currentUser.uid, 0, 'challengeCompleted');

      // Schedule a notification when the challenge is completed
      DateTime completionDate = DateTime.now().add(Duration(seconds: 10)); // Example: notify after 10 seconds
      await _scheduleNotification(completionDate, 'You have completed the challenge!');

      // Optionally, you can show a confirmation SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Challenge completed!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Challenges')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section for user-specific challenges
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Your Challenges',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
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
                  return const Center(child: Text('No personal challenges found.'));
                }

                final userChallenges = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userChallenges.length,
                  itemBuilder: (context, index) {
                    final challengeData = userChallenges[index];
                    final data = challengeData.data() as Map<String, dynamic>?;

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
                          markChallengeAsCompleted(challengeData.id, false);
                        },
                      ),
                    );
                  },
                );
              },
            ),

            // Divider between sections
            const Divider(),

            // Section for community challenges
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Community Challenges',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('communityChallenges').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No community challenges found.'));
                }

                final communityChallenges = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: communityChallenges.length,
                  itemBuilder: (context, index) {
                    final challengeData = communityChallenges[index];
                    final data = challengeData.data() as Map<String, dynamic>?;

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
                          markChallengeAsCompleted(challengeData.id, true);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
