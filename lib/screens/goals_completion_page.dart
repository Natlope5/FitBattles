import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class GoalCompletionPage extends StatefulWidget {
  final String userToken;

  const GoalCompletionPage({super.key, required this.userToken});

  @override
  GoalCompletionPageState createState() => GoalCompletionPageState();
}

class GoalCompletionPageState extends State<GoalCompletionPage> {
  List<Map<String, dynamic>> _completedGoals = [];
  int _completedGoalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCompletedGoals();
  }

  Future<void> _loadCompletedGoals() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Access Firestore
      final CollectionReference goalsCollection = FirebaseFirestore.instance.collection('goals');

      // Fetch completed goals
      final QuerySnapshot querySnapshot = await goalsCollection.where('isCompleted', isEqualTo: true).get();

      // Process the documents
      final List<Map<String, dynamic>> goals = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _completedGoals = goals;
          _completedGoalCount = _completedGoals.length;
        });
      }
    } catch (e) {
      // Handle error while loading goals
      if (mounted) {
        // Use the context directly here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading goals: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Goals Completed: $_completedGoalCount',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _completedGoals.length,
                itemBuilder: (context, index) {
                  final goal = _completedGoals[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(goal['name']),
                      subtitle: Text(
                          'Completed: ${goal['currentProgress']} / ${goal['amount']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
