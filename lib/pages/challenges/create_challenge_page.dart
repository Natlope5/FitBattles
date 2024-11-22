import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key});

  @override
  CreateChallengePageState createState() => CreateChallengePageState();
}

class CreateChallengePageState extends State<CreateChallengePage> {
  final TextEditingController _challengeNameController = TextEditingController();
  String _challengeType = 'Steps';
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final List<String> _selectedFriends = [];
  List<Map<String, dynamic>> _friendsList = [];

  @override
  void initState() {
    super.initState();
    _fetchFriends(); // Fetch friends when the page loads
  }

  Future<void> _fetchFriends() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('friends')
          .get();

      setState(() {
        _friendsList = friendsSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'] as String? ?? '',
            'email': doc['email'] as String? ?? '',
          };
        }).toList();
      });
    } catch (e) {
      showSnackBar('Error fetching friends: $e');
    }
  }

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
      appBar: AppBar(
        title: const Text('Create a Challenge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _challengeNameController,
                decoration: const InputDecoration(labelText: 'Challenge Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _challengeType,
                items: <String>['Steps', 'Time', 'Distance']
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _challengeType = newValue!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Challenge Type'),
              ),
              const SizedBox(height: 16),
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
                            _startDateController.text =
                            '${pickedDate.toLocal()}'.split(' ')[0];
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
                        if (_startDate == null) {
                          showSnackBar('Please select a start date first.');
                          return;
                        }
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
                          firstDate: _startDate!,
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _endDate = pickedDate;
                            _endDateController.text =
                            '${pickedDate.toLocal()}'.split(' ')[0];
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Select Friends to Invite:'),
              const SizedBox(height: 8),
              _friendsList.isEmpty
                  ? const Text('No friends found.')
                  : ListView(
                shrinkWrap: true,
                children: _friendsList.map((friend) {
                  return CheckboxListTile(
                    title: Text(friend['name']!),
                    subtitle: Text(friend['email']!),
                    value: _selectedFriends.contains(friend['id']),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedFriends.add(friend['id']!);
                        } else {
                          _selectedFriends.remove(friend['id']!);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createChallenge,
                child: const Text('Create Challenge'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createChallenge() async {
    String challengeName = _challengeNameController.text;

    if (challengeName.isEmpty ||
        _startDate == null ||
        _endDate == null ||
        _selectedFriends.isEmpty) {
      showSnackBar('Please fill all fields.');
      return;
    }

    showSnackBar('Creating challenge...');

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Prepare the challenge data
      Map<String, dynamic> challengeData = {
        'challengeName': challengeName,
        'challengeType': _challengeType,
        'startDate': _startDate,
        'endDate': _endDate,
        'participants': _selectedFriends,
        'timestamp': Timestamp.now(),
        'createdBy': uid, // Add creator ID for reference
        'challengeCompleted': false,
      };

      // Write the challenge to the current user's challenges collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('challenges')
          .add(challengeData);

      // Also write the challenge to each selected friend's challenges collection
      for (String friendId in _selectedFriends) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .collection('challenges')
            .add(challengeData);
      }

      if (!mounted) return;
      showSnackBar('Challenge "$challengeName" created and sent to friends!');
      Navigator.pop(context); // Navigate back after creation
    } catch (e) {
      if (!mounted) return;
      showSnackBar('Error creating challenge: $e');
    }
  }
}