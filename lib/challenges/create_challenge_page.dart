import 'package:flutter/material.dart';

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

  // List to hold the participants' names
  final List<String> _participants = [];

  // Controller for the participant text field
  final TextEditingController _participantController = TextEditingController();

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
                      readOnly: true, // Make the text field read-only
                      decoration: InputDecoration(
                        labelText: _startDate == null
                            ? 'Start Date' // Placeholder if no date is selected
                            : 'Start Date: ${_startDate!.toLocal()}'.split(' ')[0], // Display selected date
                      ),
                      onTap: () async {
                        // Show date picker for start date
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _startDate = pickedDate; // Update the start date
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      readOnly: true, // Make the text field read-only
                      decoration: InputDecoration(
                        labelText: _endDate == null
                            ? 'End Date' // Placeholder if no date is selected
                            : 'End Date: ${_endDate!.toLocal()}'.split(' ')[0], // Display selected date
                      ),
                      onTap: () async {
                        // Show date picker for end date
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime.now(), // End date must be after start date
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _endDate = pickedDate; // Update the end date
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

  // Function to create the challenge
  void _createChallenge() {
    String challengeName = _challengeNameController.text; // Get the challenge name from the text field

    // Validate that all required fields are filled
    if (challengeName.isEmpty || _startDate == null || _endDate == null || _participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')), // Show error message
      );
      return; // Exit if validation fails
    }

    // Implement your logic to create the challenge
    // For example: Save to a database and notify participants

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Challenge "$challengeName" created! Participants: ${_participants.join(', ')}')),
    );

    // Optionally, navigate back or clear fields
    Navigator.pop(context); // Navigate back to the previous screen
  }
}
