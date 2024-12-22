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
  final List<String> goalSuggestions = [
    'Lose 10 pounds',
    'Run 5 miles',
    'Read 5 books',
    'Drink 8 glasses of water a day',
  ];

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

  void _selectGoalSuggestion(String suggestion) {
    _goalNameController.text = suggestion;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Goal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set Your Goal",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildGoalForm(),
            const SizedBox(height: 20),
            const Text(
              "Goal Suggestions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSuggestionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _goalNameController,
              decoration: const InputDecoration(
                labelText: 'Goal Name',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _goalAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Goal Amount',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              ),
              onPressed: _saveGoal,
              child: Text(
                'Add Goal',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: goalSuggestions.map((goal) {
        return GestureDetector(
          onTap: () => _selectGoalSuggestion(goal),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  goal,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
