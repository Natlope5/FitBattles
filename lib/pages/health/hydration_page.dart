import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  HydrationPageState createState() => HydrationPageState();
}

class HydrationPageState extends State<HydrationPage> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  double _currentWaterIntake = 0.0;
  final double _dailyGoal = 3.0;
  List<Map<String, dynamic>> _waterLog = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize time zone data
    _initializeNotifications();
    _scheduleHourlyReminder();
    _loadWaterIntakeFromFirestore();
    _loadWaterLogFromFirestore();
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
          color: _currentWaterIntake >= _dailyGoal
              ? Colors.green
              : Colors.lightBlueAccent,
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

  Future<double?> _showAddWaterDialog() async {
    double intakeAmount = 0.0;

    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Water Intake'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter amount in liters',
            hintText: 'e.g. 0.5',
          ),
          onChanged: (value) {
            intakeAmount = double.tryParse(value) ?? 0.0;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(intakeAmount),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWaterIntakeToFirestore() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'currentWaterIntake': _currentWaterIntake}, SetOptions(merge: true));
    } catch (e) {
      _showToast('Error saving data: $e');
    }
  }

  Future<void> _addToWaterLog(double intake) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      Map<String, dynamic> waterLogEntry = {
        'amount': intake,
        'timestamp': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('water_log')
          .add(waterLogEntry);

      _loadWaterLogFromFirestore();
    } catch (e) {
      _showToast('Error adding to log: $e');
    }
  }

  Future<void> _loadWaterLogFromFirestore() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('water_log')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _waterLog = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      _showToast('Error loading log: $e');
    }
  }

  void _initializeNotifications() {
    const androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final initializationSettings =
    InitializationSettings(android: androidInitializationSettings);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _scheduleHourlyReminder() async {
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Hydration Reminder',
      'Time to drink water!',
      tz.TZDateTime.from(nextHour, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hydration_channel',
          'Hydration Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _clearWaterLog() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('water_log')
          .get();

      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
      setState(() {
        _waterLog.clear();
      });
      _showToast('Log cleared!');
    } catch (e) {
      _showToast('Error clearing log: $e');
    }
  }

  Future<void> _loadWaterIntakeFromFirestore() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          _currentWaterIntake =
              (snapshot.data() as Map<String, dynamic>)['currentWaterIntake']?.toDouble() ?? 0.0;
        });

      } else {
        setState(() {
          _currentWaterIntake = 0.0;
        });
      }
    } catch (e) {
      _showToast('Error fetching data: $e');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }
}