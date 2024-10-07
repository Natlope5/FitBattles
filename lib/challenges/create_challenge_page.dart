import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // For image picking

class CreateChallengePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final List<String> friends;

  const CreateChallengePage({
    super.key,
    required this.cameras,
    required this.friends, required friend,
  });

  @override
  CreateChallengePageState createState() => CreateChallengePageState();
}

class CreateChallengePageState extends State<CreateChallengePage> {
  VideoPlayerController? videoPlayerController; // Controller for video playback
  String? videoPath; // Path to the recorded video file
  final formKey = GlobalKey<FormState>(); // Key to validate the form
  final TextEditingController challengeNameController = TextEditingController();
  final TextEditingController challengeTypeController = TextEditingController();
  DateTime? startDate; // Start date of the challenge
  DateTime? endDate; // End date of the challenge
  String? statusMessage; // Message to display status updates
  List<String> participants = []; // List to store selected participants

  // Sample preloaded challenges
  final List<Challenge> preloadedChallenges = [
    Challenge(id: '1', name: '10,000 Steps Challenge', description: 'Walk every day 1000 steps for 14 days!'),
    Challenge(id: '2', name: 'Running Challenge', description: 'Run every day for 30 days'),
    Challenge(id: '3', name: 'Healthy Eating Challenge', description: 'Eat healthy for 30 days.'),
    Challenge(id: '4', name: '50 SitUps Challenge', description: 'Do 50 SitUps a day for 21 days.'),
    Challenge(id: '5', name: '100 Squat Challenge', description: 'Do 100 squats a day for 30 days.'),


  ];

  @override
  void dispose() {
    videoPlayerController?.dispose();
    challengeNameController.dispose();
    challengeTypeController.dispose();
    super.dispose();
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final videoFile = await picker.pickVideo(source: ImageSource.gallery);

    if (videoFile != null) {
      setState(() {
        videoPath = videoFile.path;
      });

      videoPlayerController = VideoPlayerController.file(File(videoPath!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> createChallenge() async {
    if (formKey.currentState!.validate()) {
      try {
        final challengeData = {
          'name': challengeNameController.text,
          'type': challengeTypeController.text,
          'startDate': startDate,
          'endDate': endDate,
          'participants': participants,
          'videoPath': videoPath,
        };

        await FirebaseFirestore.instance.collection('challenges').add(challengeData);
        setState(() {
          statusMessage = 'Challenge created successfully!';
        });
      } catch (e) {
        setState(() {
          statusMessage = 'Error creating challenge: $e';
        });
      }
    }
  }

  void _selectParticipant(String? value) {
    if (value != null && !participants.contains(value)) {
      setState(() {
        participants.add(value);
      });
    }
  }

  // Method to show preloaded challenges and notify opponents
  void _showPreloadedChallenges() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Challenge'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: preloadedChallenges.length,
              itemBuilder: (context, index) {
                final challenge = preloadedChallenges[index];
                return ListTile(
                  title: Text(challenge.name),
                  subtitle: Text(challenge.description),
                  onTap: () {
                    // Notify the opponent about the selected challenge
                    _notifyOpponent(challenge.name);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Method to notify the opponent about the selected challenge
  void _notifyOpponent(String challengeName) {
    setState(() {
      statusMessage = 'Notified opponent about $challengeName!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Own Challenge')),
      resizeToAvoidBottomInset: true,
      body: Container(
        color: const Color(0xFF5D6C8A),
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Challenge name input
                TextFormField(
                  controller: challengeNameController,
                  decoration: const InputDecoration(labelText: 'Challenge Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a challenge name';
                    }
                    return null;
                  },
                ),
                // Challenge type input
                TextFormField(
                  controller: challengeTypeController,
                  decoration: const InputDecoration(labelText: 'Challenge Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a challenge type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Start date
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        startDate == null
                            ? 'Start Date'
                            : 'Start: ${DateFormat('yyyy-MM-dd').format(startDate!)}',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => selectDate(context, true),
                    ),
                  ],
                ),
                // End date
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        endDate == null
                            ? 'End Date'
                            : 'End: ${DateFormat('yyyy-MM-dd').format(endDate!)}',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => selectDate(context, false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Participants dropdown
                DropdownButtonFormField<String>(
                  value: null,
                  onChanged: _selectParticipant,
                  decoration: const InputDecoration(labelText: 'Participant'),
                  items: widget.friends
                      .map((friend) => DropdownMenuItem(value: friend, child: Text(friend)))
                      .toList(),
                  validator: (value) {
                    if (value == null || participants.isEmpty) {
                      return 'Please select a participant';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Display selected participants
                Wrap(
                  spacing: 8.0,
                  children: participants
                      .map((participant) => Chip(
                    label: Text(participant),
                    onDeleted: () {
                      setState(() {
                        participants.remove(participant);
                      });
                    },
                  ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Pick video button
                ElevatedButton(
                  onPressed: pickVideo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF85C83E),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Pick Video'),
                ),
                const SizedBox(height: 16),
                // Display video if picked
                if (videoPath != null)
                  Column(
                    children: [
                      VideoPlayer(videoPlayerController!),
                      ElevatedButton(
                        onPressed: () {
                          videoPlayerController?.value.isPlaying == true
                              ? videoPlayerController?.pause()
                              : videoPlayerController?.play();
                        },
                        child: Icon(videoPlayerController?.value.isPlaying == true ? Icons.pause : Icons.play_arrow),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                // Notify opponents button
                ElevatedButton(
                  onPressed: _showPreloadedChallenges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF85C83E),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Notify Opponents'),
                ),
                const SizedBox(height: 16),
                // Create Challenge button
                ElevatedButton(
                  onPressed: createChallenge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF85C83E),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Create Challenge'),
                ),
                const SizedBox(height: 16),
                // Display status message
                if (statusMessage != null) Text(statusMessage!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Challenge {
  final String id;
  final String name;
  final String description;

  Challenge({required this.id, required this.name, required this.description});
}
