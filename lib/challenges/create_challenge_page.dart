import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'challenge.dart'; // Import the Challenge model

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage(
      {super.key, required List<CameraDescription> cameras, required List friends, required String friend});

  @override
  CreateChallengePageState createState() => CreateChallengePageState();
}

class CreateChallengePageState extends State<CreateChallengePage> {
  final TextEditingController _challengeNameController = TextEditingController();
  String _challengeType = 'Steps';
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _participants = [];
  final TextEditingController _participantController = TextEditingController();

  @override
  void dispose() {
    _challengeNameController.dispose();
    _participantController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white, // Set background to white
      labelStyle: const TextStyle(color: Colors.black), // Set label text color to black
      contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0), // Add padding for more space inside
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.primaryColor),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Challenge'),
        backgroundColor: theme.primaryColor, // Ensure AppBar uses theme color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the start to prevent cutting off
            children: [
              const SizedBox(height: 50), // Adds extra space at the top to push everything down
              TextField(
                controller: _challengeNameController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Challenge Name',
                ),
                style: const TextStyle(color: Colors.black), // Set text color to black
                cursorColor: theme.primaryColor,
              ),
              const SizedBox(height: 32), // Large spacing before "Challenge Type" field
              DropdownButtonFormField<String>(
                value: _challengeType,
                items: <String>['Steps', 'Time', 'Distance'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: Colors.black)), // Set dropdown text color to black
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _challengeType = newValue!;
                  });
                },
                decoration: inputDecoration.copyWith(
                  labelText: 'Challenge Type',
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Ensure padding inside dropdown
                ),
                style: const TextStyle(color: Colors.black), // Set text color to black
                dropdownColor: Colors.white, // Ensure dropdown background is visible
              ),
              const SizedBox(height: 32), // Increased spacing between elements
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Start Date',
                      ),
                      style: const TextStyle(color: Colors.black), // Set text color to black
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
                            _startDateController.text = DateFormat('yyyy-MM-dd').format(_startDate!);
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
                      decoration: inputDecoration.copyWith(
                        labelText: 'End Date',
                      ),
                      style: const TextStyle(color: Colors.black), // Set text color to black
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? (_startDate ?? DateTime.now()),
                          firstDate: _startDate ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _endDate = pickedDate;
                            _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate!);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32), // Increased spacing between elements
              TextField(
                controller: _participantController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Add Participant',
                ),
                style: const TextStyle(color: Colors.black), // Set text color to black
                cursorColor: theme.primaryColor,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_participantController.text.isNotEmpty) {
                      _participants.add(_participantController.text);
                      _participantController.clear();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                ),
                child: const Text('Add Participant'),
              ),
              const SizedBox(height: 32), // Increased spacing between elements
              Wrap(
                children: _participants.map((participant) {
                  return Chip(
                    label: Text(participant),
                    onDeleted: () {
                      setState(() {
                        _participants.remove(participant);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32), // Increased spacing before final button
              ElevatedButton(
                onPressed: _createChallenge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                ),
                child: const Text('Create Challenge'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createChallenge() async {
    String challengeName = _challengeNameController.text.trim();

    if (challengeName.isEmpty || _startDate == null || _endDate == null || _participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    Challenge challenge = Challenge(
      name: challengeName,
      type: _challengeType,
      startDate: _startDate!,
      endDate: _endDate!,
      participants: _participants,
    );

    try {
      await FirebaseFirestore.instance.collection('challenges').add(challenge.toMap());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Challenge "${challenge.name}" created!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating challenge: $e')),
      );
    }
  }
}
