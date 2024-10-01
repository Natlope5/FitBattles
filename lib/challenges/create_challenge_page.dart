import 'package:flutter/material.dart'; // Importing Flutter material package for UI components

// This widget represents the page for creating a new challenge.
class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key}); // Constructor

  @override
  CreateChallengePageState createState() => CreateChallengePageState(); // Creating the state for CreateChallengePage
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
        title: const Text('Create a Challenge'), // Title of the app bar
      ),
      // Padding for the body content
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: SingleChildScrollView( // Allow scrolling for the content
          child: Column(
            children: [
              // Text field for the challenge name
              TextField(
                controller: _challengeNameController, // Controller for challenge name
                decoration: const InputDecoration(labelText: 'Challenge Name'), // Label for text field
              ),
              const SizedBox(height: 16), // Space between elements

              // Dropdown for selecting challenge type
              DropdownButtonFormField<String>(
                value: _challengeType, // Current challenge type
                items: <String>['Steps', 'Time', 'Distance'] // Challenge types
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value), // Display challenge type
                ))
                    .toList(),
                onChanged: (String? newValue) {
                  // Update the challenge type when a new value is selected
                  setState(() {
                    _challengeType = newValue!; // Set new challenge type
                  });
                },
                decoration: const InputDecoration(labelText: 'Challenge Type'), // Label for dropdown
              ),
              const SizedBox(height: 16), // Space between elements

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
                          initialDate: _startDate ?? DateTime.now(), // Default date is today
                          firstDate: DateTime.now(), // Start date can't be before today
                          lastDate: DateTime(2100), // Limit to a reasonable future date
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _startDate = pickedDate; // Update the start date
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16), // Space between elements
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
                          initialDate: _endDate ?? DateTime.now(), // Default date is today
                          firstDate: _startDate ?? DateTime.now(), // End date must be after start date
                          lastDate: DateTime(2100), // Limit to a reasonable future date
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
              const SizedBox(height: 16), // Space between elements

              // Text field for adding participants
              TextField(
                controller: _participantController, // Controller for participant input
                decoration: const InputDecoration(labelText: 'Add Participant'), // Label for text field
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
                child: const Text('Add Participant'), // Button text
              ),
              const SizedBox(height: 16), // Space between elements

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
              const SizedBox(height: 16), // Space between elements

              // Button to create the challenge
              ElevatedButton(
                onPressed: () {
                  // Handle the logic to create the challenge here
                  _createChallenge();
                },
                child: const Text('Create Challenge'), // Button text
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
