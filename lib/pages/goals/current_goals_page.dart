import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CurrentGoalsPage extends StatelessWidget {
  const CurrentGoalsPage({super.key});

  // Notification plugin initialization
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Current Goals')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('goals')
            .where('isCompleted', isEqualTo: false) // Filter for incomplete goals
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No goals set.'));
          }

          final goals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goalData = goals[index];
              final double progress = goalData['currentProgress'];
              final double goalAmount = goalData['amount'];
              final String goalName = goalData['name'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(goalName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress: ${progress.toInt()} / ${goalAmount.toInt()}',
                      ),
                      const SizedBox(height: 8.0),
                      LinearProgressIndicator(
                        value: (progress / goalAmount).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _showUpdateProgressDialog(
                          context, goalData.id, progress, goalAmount, goalName);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUpdateProgressDialog(
      BuildContext context, String goalId, double currentProgress, double goalAmount, String goalName) {
    final TextEditingController progressController = TextEditingController(
      text: currentProgress.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Progress'),
          content: TextField(
            controller: progressController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'New Progress'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newProgress = double.tryParse(progressController.text);
                if (newProgress != null) {
                  final uid = FirebaseAuth.instance.currentUser!.uid;

                  // Store the navigator context before async operation
                  final navigator = Navigator.of(context);

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('goals')
                      .doc(goalId)
                      .update({
                    'currentProgress': newProgress,
                    'isCompleted': newProgress >= goalAmount,
                  });

                  // Notify the user
                  if (newProgress >= goalAmount) {
                    _showNotification('Goal Completed', 'Congratulations! You completed the "$goalName" goal.');
                  } else {
                    _showNotification('Progress Updated', 'Your progress for "$goalName" has been updated.');
                  }

                  navigator.pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
