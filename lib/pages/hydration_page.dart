import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  HydrationPageState createState() => HydrationPageState();
}

class HydrationPageState extends State<HydrationPage> {
  double _currentWaterIntake = 0.0;
  final double _dailyGoal = 3.0; // Daily water intake goal in liters
  List<Map<String, dynamic>> _waterLog = [
  ]; // List to store the log of water submissions

  @override
  void initState() {
    super.initState();
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
            // Log section to display water intake submissions
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
          color: Colors.lightBlueAccent,
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

  // Show a dialog to enter the water intake value
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

  // Dialog to input water intake
  Future<double?> _showAddWaterDialog() async {
    double intakeAmount = 0.0;

    return showDialog<double>(
      context: context,
      builder: (context) =>
          AlertDialog(
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

  // Clear the water intake log
  Future<void> _clearWaterLog() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
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

  // Load the current water intake from Firestore
  Future<void> _loadWaterIntakeFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('history')
          .doc('water_intake')
          .get();

      if (snapshot.exists) {
        setState(() {
          _currentWaterIntake =
              (snapshot.data() as Map<String, dynamic>)['intake']?.toDouble() ??
                  0.0;
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

  // Show toast messages for feedback
  // Show toast messages for feedback
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
