import 'package:flutter/material.dart';
import 'package:fitbattles/challenges/challenge.dart';
import 'package:fitbattles/challenges/challenge_data.dart'; // Ensure you import the ChallengeData

class PreloadedChallengesPage extends StatefulWidget {
  const PreloadedChallengesPage({super.key});

  @override
  PreloadedChallengesPageState createState() => PreloadedChallengesPageState();
}

class PreloadedChallengesPageState extends State<PreloadedChallengesPage> {
  String? selectedChallengeId; // State to track the selected challenge

  @override
  Widget build(BuildContext context) {
    final List<Challenge> preloadedChallenges = ChallengeData.challenges; // Use ChallengeData for challenges

    return ListView.builder(
      itemCount: preloadedChallenges.length,
      itemBuilder: (context, index) {
        final challenge = preloadedChallenges[index];
        final isSelected = selectedChallengeId == challenge.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedChallengeId = challenge.id; // Update the selected challenge
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: Colors.green, width: 2) // Highlight if selected
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(128),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.green : Colors.black, // Change color if selected
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Type: ${challenge.type}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  'Duration: ${challenge.startDate} - ${challenge.endDate}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
