import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  HydrationPageState createState() => HydrationPageState();
}

class HydrationPageState extends State<HydrationPage> {
  double _currentWaterIntake = 0.0;
  final double _dailyGoal = 3.0; // Daily water intake goal in liters
  List<Map<String, dynamic>> _waterLog = [];

  late FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _loadWaterIntakeFromFirestore();
    _loadWaterLogFromFirestore();
    _initializeNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration Tracker'),
        backgroundColor: const Color(0xFF5D6C8A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Your Daily Water Intake',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildProgressBar(),
            const SizedBox(height: 20),
            _buildWaterIntakeText(),
            const SizedBox(height: 20),
            _buildAddIntakeButton(),
            const SizedBox(height: 20),
            _buildLogSection(),
            const SizedBox(height: 20),
            _buildReminderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Text(
          'Daily Goal: $_dailyGoal liters',
          style: const TextStyle(fontSize: 18, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: _currentWaterIntake / _dailyGoal,
          minHeight: 20,
          backgroundColor: Colors.grey[300],
          color: Colors.lightBlueAccent,
        ),
      ],
    );
  }

  Widget _buildWaterIntakeText() {
    return Text(
      '${_currentWaterIntake.toStringAsFixed(1)} liters',
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAddIntakeButton() {
    return ElevatedButton(
      onPressed: _addWaterIntake,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      ),
      child: const Text('Add Water Intake'),
    );
  }

  Widget _buildReminderButton() {
    return ElevatedButton(
      onPressed: _scheduleWaterReminder,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      ),
      child: const Text('Set Water Intake Reminder'),
    );
  }

  Widget _buildLogSection() {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Water Intake Log',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearWaterLog,
                child: const Text(
                  'Clear Log',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          Expanded(
            child: _waterLog.isEmpty
                ? const Text('No log entries yet.')
                : ListView.builder(
              itemCount: _waterLog.length,
              itemBuilder: (context, index) {
                final logEntry = _waterLog[index];
                return ListTile(
                  title: Text('Added ${logEntry['amount']} liters'),
                  subtitle: Text(
                      'Time: ${(logEntry['timestamp'] as Timestamp).toDate()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addWaterIntake() async {
    double? addedIntake = await _showAddWaterDialog();

    if (addedIntake != null && addedIntake > 0) {
      setState(() {
        _currentWaterIntake += addedIntake;
      });
      await _saveWaterIntakeToFirestore();
      await _addToWaterLog(addedIntake);
      _showToast('Water intake updated!');
    }
  }

  // Initialize notifications
  void _initializeNotifications() {
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);
    _localNotificationsPlugin.initialize(initSettings);
  }

  // Schedule a periodic water reminder
  Future<void> _scheduleWaterReminder() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'water_reminder_channel',
      'Water Intake Reminder',
      channelDescription: 'Reminds you to drink water regularly',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.periodicallyShow(
      0,
      'Time to Hydrate!',
      'Don\'t forget to drink some water!',
      RepeatInterval.hourly,
      notificationDetails,
    );

    _showToast('Water reminder set!');
  }

  // Show a toast message
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  // Load water intake data from Firestore
  Future<void> _loadWaterIntakeFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc('user_id') // Replace with actual user ID
          .get();

      if (snapshot.exists) {
        setState(() {
          _currentWaterIntake = snapshot['waterIntake'] ?? 0.0;
        });
      }
    } catch (e) {
      _showToast('Failed to load water intake data.');
    }
  }

  // Load water log from Firestore
  Future<void> _loadWaterLogFromFirestore() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc('user_id') // Replace with actual user ID
          .collection('waterLog')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _waterLog = snapshot.docs
            .map((doc) => {
          'amount': doc['amount'],
          'timestamp': doc['timestamp'],
        })
            .toList();
      });
    } catch (e) {
      _showToast('Failed to load water log.');
    }
  }

  // Clear the water log
  Future<void> _clearWaterLog() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('user_id') // Replace with actual user ID
          .collection('waterLog')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      setState(() {
        _waterLog.clear();
      });

      _showToast('Water log cleared!');
    } catch (e) {
      _showToast('Failed to clear water log.');
    }
  }

  // Save water intake to Firestore
  Future<void> _saveWaterIntakeToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('user_id') // Replace with actual user ID
          .set({'waterIntake': _currentWaterIntake}, SetOptions(merge: true));
    } catch (e) {
      _showToast('Failed to save water intake.');
    }
  }

  // Add water intake to the log
  Future<void> _addToWaterLog(double addedIntake) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('user_id') // Replace with actual user ID
          .collection('waterLog')
          .add({
        'amount': addedIntake,
        'timestamp': Timestamp.now(),
      });

      _loadWaterLogFromFirestore(); // Refresh the log after adding entry
    } catch (e) {
      _showToast('Failed to add to water log.');
    }
  }

  // Dialog to input water intake
  Future<double?> _showAddWaterDialog() async {
    double addedIntake = 0.0;

    return showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Water Intake'),
          content: TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Liters'),
            onChanged: (value) {
              addedIntake = double.tryParse(value) ?? 0.0;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(addedIntake);
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
