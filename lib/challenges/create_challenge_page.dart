import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class CreateChallengePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final List<String> friends;

  const CreateChallengePage({
    super.key,
    required this.cameras,
    required this.friends, required String friend,
  });

  @override
  CreateChallengePageState createState() => CreateChallengePageState();
}

class CreateChallengePageState extends State<CreateChallengePage> {
  VideoPlayerController? videoPlayerController;
  String? videoPath;
  final formKey = GlobalKey<FormState>();
  final TextEditingController challengeNameController = TextEditingController();
  final TextEditingController challengeTypeController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? statusMessage;
  List<String> participants = [];

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
                  title: Text(challenge.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(challenge.description),
                  onTap: () {
                    _notifyOpponent(challenge.name);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _notifyOpponent(String challengeName) {
    setState(() {
      statusMessage = 'Notified opponent about $challengeName!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Own Challenge')),
      body: Container(
        color: const Color(0xFF5D6C8A),
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextInput(challengeNameController, 'Challenge Name', 'Please enter a challenge name'),
                const SizedBox(height: 16),
                _buildTextInput(challengeTypeController, 'Challenge Type', 'Please enter a challenge type'),
                const SizedBox(height: 16),
                _buildDateRow('Start Date', startDate, () => selectDate(context, true)),
                const SizedBox(height: 16),
                _buildDateRow('End Date', endDate, () => selectDate(context, false)),
                const SizedBox(height: 16),
                _buildParticipantDropdown(),
                const SizedBox(height: 16),
                _buildSelectedParticipantsChips(),
                const SizedBox(height: 16),
                _buildVideoPickerButton(),
                const SizedBox(height: 16),
                if (videoPath != null) _buildVideoPlayer(),
                const SizedBox(height: 16),
                _buildNotifyOpponentsButton(),
                const SizedBox(height: 16),
                _buildCreateChallengeButton(),
                const SizedBox(height: 16),
                if (statusMessage != null) Text(statusMessage!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String label, String errorMessage) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFE8F0FE),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorMessage;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              date == null ? label : 'Selected: ${DateFormat('yyyy-MM-dd').format(date)}',
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantDropdown() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: DropdownButtonFormField<String>(
        value: null,
        onChanged: _selectParticipant,
        decoration: InputDecoration(
          labelText: 'Participant',
          filled: true,
          fillColor: const Color(0xFFE8F0FE),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
    );
  }

  Widget _buildSelectedParticipantsChips() {
    return Wrap(
      spacing: 8.0,
      children: participants
          .map((participant) => Chip(
        label: Text(participant),
        onDeleted: () {
          setState(() {
            participants.remove(participant);
          });
        },
        backgroundColor: const Color(0xFF85C83E),
        deleteIconColor: Colors.white,
      ))
          .toList(),
    );
  }

  Widget _buildVideoPickerButton() {
    return ElevatedButton(
      onPressed: pickVideo,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF85C83E),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: const Text('Pick Video', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildVideoPlayer() {
    return Column(
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
    );
  }

  Widget _buildNotifyOpponentsButton() {
    return ElevatedButton(
      onPressed: _showPreloadedChallenges,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF85C83E),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: const Text('Notify Opponents', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCreateChallengeButton() {
    return ElevatedButton(
      onPressed: createChallenge,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF85C83E),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: const Text('Create Challenge', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class Challenge {
  final String id;
  final String name;
  final String description;

  Challenge({required this.id, required this.name, required this.description});
}
