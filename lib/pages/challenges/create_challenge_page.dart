import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// This widget represents the page for creating a new challenge.
class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key});

  @override
  CreateChallengePageState createState() => CreateChallengePageState();
}

// This is the state class for CreateChallengePage. It holds the state of the page.
class CreateChallengePageState extends State<CreateChallengePage> {
  // Controller for the challenge name text field
  final TextEditingController _challengeNameController = TextEditingController();

  // Default type of challenge (e.g., Steps, Time, Distance)
  String _challengeType = 'Steps';

  // Variables to hold the start and end dates for the challenge
  DateTime? _startDate;
  DateTime? _endDate;

  // Controllers for start and end date TextFields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // List to hold the participants' names
  final List<String> _participants = [];

  // Controller for the participant text field
  final TextEditingController _participantController = TextEditingController();

  // Function to show SnackBar safely
  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar for the page
      appBar: AppBar(
        title: const Text('Create a Challenge'),
      ),
      // Padding for the body content
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Text field for the challenge name
              TextField(
                controller: _challengeNameController,
                decoration: const InputDecoration(labelText: 'Challenge Name'),
              ),
              const SizedBox(height: 16),

              // Dropdown for selecting challenge type
              DropdownButtonFormField<String>(
                value: _challengeType,
                items: <String>['Steps', 'Time', 'Distance'] // Challenge types
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
                onChanged: (String? newValue) {
                  // Update the challenge type when a new value is selected
                  setState(() {
                    _challengeType = newValue!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Challenge Type'),
              ),
              const SizedBox(height: 16),

              // Row for selecting start and end dates
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _startDate = pickedDate;
                            _startDateController.text = '${pickedDate.toLocal()}'.split(' ')[0];
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _endDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _endDate = pickedDate;
                            _endDateController.text = '${pickedDate.toLocal()}'.split(' ')[0];
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Text field for adding participants
              TextField(
                controller: _participantController,
                decoration: const InputDecoration(labelText: 'Add Participant'),
              ),
              // Button to add participant to the list
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_participantController.text.isNotEmpty) {
                      _participants.add(_participantController.text); // Add participant
                      _participantController.clear(); // Clear the text field
                    }
                  });
                },
                child: const Text('Add Participant'),
              ),
              const SizedBox(height: 16),

              // Display the list of participants as Chips
              Wrap(
                children: _participants.map((participant) {
                  return Chip(
                    label: Text(participant), // Display participant name
                    onDeleted: () {
                      setState(() {
                        _participants.remove(participant); // Remove participant from the list
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Button to create the challenge
              ElevatedButton(
                onPressed: () {
                  // Handle the logic to create the challenge here
                  _createChallenge();
                },
                child: const Text('Create Challenge'),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Function to create the challenge and save it to Firestore
  Future<void> _createChallenge() async {
    String challengeName = _challengeNameController.text; // Get the challenge name from the text field

    // Validate that all required fields are filled
    if (challengeName.isEmpty || _startDate == null || _endDate == null || _participants.isEmpty) {
      showSnackBar('Please fill all fields.');
      return; // Exit if validation fails
    }

    // Show a loading indicator
    showSnackBar('Creating challenge...');

    // Prepare the success message beforehand
    String successMessage = 'Challenge "$challengeName" created! Participants: ${_participants.join(', ')}';

    try {
      // Get the current user ID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Prepare the challenge data
      Map<String, dynamic> challengeData = {
        'challengeName': challengeName,
        'challengeType': _challengeType,
        'startDate': _startDate,
        'endDate': _endDate,
        'participants': _participants,
        'timestamp': Timestamp.now(),
      };

      // Save the challenge data to Firestore under the user's 'challenges' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('challenges')
          .add(challengeData);

      if (!mounted) return; // Check if the widget is still mounted

      // Show success message
      showSnackBar(successMessage);

      // Optionally, navigate back or clear fields
      Navigator.pop(context); // Navigate back to the previous screen
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted

      // Handle errors
      showSnackBar('Error creating challenge: $e');
    }
  }
}