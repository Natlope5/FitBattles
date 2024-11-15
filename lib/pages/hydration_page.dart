import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  double _dailyGoal = 3.0; // Default daily water intake goal in liters
  List<Map<String, dynamic>> _waterLog = [
  ]; // List to store the log of water submissions

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize time zone data
    _initializeNotifications();
    _scheduleHourlyReminder();
    _loadWaterIntakeFromFirestore();
    _loadWaterLogFromFirestore();
    _loadDailyGoalFromFirestore(); // Load daily goal from Firestore if set
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration Tracker'),
        backgroundColor: const Color(0xFF5D6C8A),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _setWaterGoal,
          )
        ],
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
            // Button to reset progress bar
            ElevatedButton(
              onPressed: _resetWaterIntake,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 12),
              ),
              child: const Text('Reset Water Intake'),
            ),
          ],
        ),
      ),
    );
  }

  // Build the progress bar to visualize water intake
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
              ? Colors.green // Change color to green when goal is reached
              : Colors.lightBlueAccent,
        ),
      ],
    );
  }

  // Display the current water intake
  Widget _buildWaterIntakeText() {
    return Text(
      '${_currentWaterIntake.toStringAsFixed(1)} liters',
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }

  // Add water intake button
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

  // Build the log section to display water intake submissions
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

  // Reset the water intake (clear the progress bar)
  Future<void> _resetWaterIntake() async {
    setState(() {
      _currentWaterIntake = 0.0;
    });
    await _saveWaterIntakeToFirestore();
    _showToast('Water intake reset!');
  }

  // Show a dialog to enter the water intake value
  Future<void> _addWaterIntake() async {
    double? addedIntake = await _showAddWaterDialog();

    if (addedIntake != null && addedIntake > 0) {
      setState(() {
        _currentWaterIntake += addedIntake;
      });
      await _saveWaterIntakeToFirestore();
      await _addToWaterLog(addedIntake);
      if (_currentWaterIntake >= _dailyGoal) {
        _showToast('Congratulations! You have reached your daily goal!');
      }
    }
  }

  // Save water intake to Firestore
  Future<void> _saveWaterIntakeToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('history')
          .doc('water_intake')
          .set({'intake': _currentWaterIntake}, SetOptions(merge: true));
    } catch (e) {
      _showToast('Error saving data: $e');
    }
  }

  // Add a water intake entry to the log in Firestore
  Future<void> _addToWaterLog(double intake) async {
    try {
      await FirebaseFirestore.instance.collection('water_log').add({
        'amount': intake,
        'timestamp': Timestamp.now(),
      });
      _loadWaterLogFromFirestore();
    } catch (e) {
      _showToast('Error adding to log: $e');
    }
  }

  // Load the water intake log from Firestore
  Future<void> _loadWaterLogFromFirestore() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
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

  // Show toast messages
  void _showToast(String message) {
    Fluttertoast.showToast(msg: message);
  }

  // Load the current water intake from Firestore
  Future<void> _loadWaterIntakeFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('history')
          .doc('water_intake')
          .get();

      if (snapshot.exists) {
        setState(() {
          _currentWaterIntake = snapshot['intake'] ?? 0.0;
        });
      }
    } catch (e) {
      _showToast('Error loading water intake: $e');
    }
  }

  // Load the daily goal from Firestore
  Future<void> _loadDailyGoalFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('settings')
          .doc('user_settings')
          .get();

      if (snapshot.exists && snapshot['daily_goal'] != null) {
        setState(() {
          _dailyGoal = snapshot['daily_goal'];
        });
      }
    } catch (e) {
      _showToast('Error loading daily goal: $e');
    }
  }

  // Set a custom water intake goal
  Future<void> _setWaterGoal() async {
    double? newGoal = await _showSetGoalDialog();
    if (newGoal != null) {
      setState(() {
        _dailyGoal = newGoal;
      });
      await FirebaseFirestore.instance.collection('settings').doc(
          'user_settings').set(
        {'daily_goal': newGoal},
        SetOptions(merge: true),
      );
      _showToast('Water goal updated!');
    }
  }

  // Show a dialog to set a custom water intake goal
  Future<double?> _showSetGoalDialog() async {
    TextEditingController controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Set Your Daily Goal'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  hintText: 'Enter goal in liters'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(double.tryParse(controller.text));
                },
                child: const Text('Set Goal'),
              ),
            ],
          ),
    );
  }

  // Show a dialog to enter water intake amount
  Future<double?> _showAddWaterDialog() async {
    TextEditingController controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Enter Water Intake'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  hintText: 'Enter amount in liters'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(double.tryParse(controller.text));
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  // Clear the water intake log from Firestore
  Future<void> _clearWaterLog() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('water_log')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      _loadWaterLogFromFirestore();
      _showToast('Water log cleared!');
    } catch (e) {
      _showToast('Error clearing log: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

// Schedule hourly reminder notifications
  void _scheduleHourlyReminder() {
    _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Stay Hydrated!',
      'It\'s time to drink water and stay healthy!',
      _nextInstanceOfTheHour(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hydration_channel',
          'Hydration Notifications',
          channelDescription: 'Hourly hydration reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      // Specify the scheduling mode
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTheHour() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final int nextHour = now.hour + 1;
    return tz.TZDateTime(tz.local, now.year, now.month, now.day, nextHour);
  }
}
