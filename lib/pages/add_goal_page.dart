import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  AddGoalPageState createState() => AddGoalPageState();
}

class AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();

  Future<void> _saveGoal() async {
    final String goalName = _goalNameController.text;
    final double? goalAmount = double.tryParse(_goalAmountController.text);

    if (goalName.isNotEmpty && goalAmount != null) {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      Map<String, dynamic> newGoal = {
        'name': goalName,
        'amount': goalAmount,
        'currentProgress': 0.0,
        'isCompleted': false,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('goals')
          .add(newGoal);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal added successfully!')),
      );

      _goalNameController.clear();
      _goalAmountController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid goal name and amount.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Goal Name:', style: TextStyle(fontSize: 16)),
            TextField(controller: _goalNameController),
            const SizedBox(height: 16),
            const Text('Goal Amount:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _goalAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g., 10 (km, reps, etc.)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveGoal,
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }
}