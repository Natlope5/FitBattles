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

  // ValueNotifier to track notification toggle state
  static final ValueNotifier<bool> notificationsEnabled = ValueNotifier<bool>(true);

  Stream<double> _calculateOverallProgress(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .where('isCompleted', isEqualTo: false) // Only track incomplete goals
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0; // If no goals, progress is 0%

      double totalProgress = 0.0;
      double totalGoalAmount = 0.0;

      for (var goal in snapshot.docs) {
        totalProgress += goal['currentProgress'] as double;
        totalGoalAmount += goal['amount'] as double;
      }

      return totalGoalAmount > 0
          ? (totalProgress / totalGoalAmount) * 100
          : 0.0; // Return progress as a percentage
    });
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Goals'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: notificationsEnabled,
            builder: (context, value, child) {
              return Switch(
                value: value,
                onChanged: (newValue) {
                  notificationsEnabled.value = newValue;
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
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
                              valueColor:
                              const AlwaysStoppedAnimation(Colors.blue),
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
          ),
          const Spacer(), // Pushes the goal progress card to the bottom
          StreamBuilder<double>(
            stream: _calculateOverallProgress(uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final progress = snapshot.data!;
              final progressText = progress == 0.0
                  ? 'No active goals yet. Start one today!'
                  : "You're ${progress.toStringAsFixed(1)}% towards your goals.";

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.green[50],
                  child: ListTile(
                    title: const Text('Keep Going!'),
                    subtitle: Text(progressText),
                    leading: const Icon(Icons.directions_run, color: Colors.green),
                    trailing: const Icon(Icons.info_outline),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showUpdateProgressDialog(
      BuildContext context,
      String goalId,
      double currentProgress,
      double goalAmount,
      String goalName,
      ) {
    final TextEditingController progressController = TextEditingController(
      text: currentProgress.toInt().toString(),
    );

    // Capture the navigator instance before the async operation
    final navigator = Navigator.of(context);

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
              onPressed: () => navigator.pop(), // Use captured navigator instance
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newProgress = double.tryParse(progressController.text);
                if (newProgress != null) {
                  final uid = FirebaseAuth.instance.currentUser!.uid;

                  // Perform the async operation
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
                    _showNotification(
                      'Goal Completed',
                      'Congratulations! You completed the "$goalName" goal.',
                    );
                  } else {
                    _showNotification(
                      'Progress Updated',
                      'Your progress for "$goalName" has been updated.',
                    );
                  }

                  // Close the dialog after the async operation
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
    if (notificationsEnabled.value) {
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
}
