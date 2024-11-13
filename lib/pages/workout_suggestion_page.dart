import 'package:flutter/material.dart';
import 'dart:math';

class WorkoutSuggestionPage extends StatelessWidget {
  final List<String> workoutTips = [
    "Try increasing your reps to boost strength.",
    "Add 5 minutes of cardio to improve stamina.",
    "Focus on form for better results and avoid injuries.",
    "Challenge yourself with a new HIIT workout!",
    "Incorporate rest days for muscle recovery."
  ];

  final int completedChallenges = 3;
  final int goalProgress = 75; // Assume this is a percentage of user's goal completion
  final bool nearMilestone = true;

  WorkoutSuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random();
    String selectedTip = workoutTips[random.nextInt(workoutTips.length)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Suggestions & Tips'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Home Screen Widget / Banner
          Card(
            color: Colors.lightBlue[50],
            child: ListTile(
              title: const Text('Today\'s Workout Tip'),
              subtitle: Text(selectedTip),
              leading: const Icon(Icons.fitness_center, color: Colors.blue),
              trailing: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailPage(
                      title: 'Workout Tip Detail',
                      content: 'Here’s more information on today\'s workout tip.',
                    ),
                  ),
                ),
                child: const Icon(Icons.arrow_forward),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Progress & Goal Screen Suggestion
          if (goalProgress >= 50)
            Card(
              color: Colors.green[50],
              child: ListTile(
                title: const Text('Keep Going!'),
                subtitle: Text("You're $goalProgress% towards your goal. Try a 5-minute cardio boost!"),
                leading: const Icon(Icons.directions_run, color: Colors.green),
                trailing: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailPage(
                        title: 'Progress Boost Tip',
                        content: 'Learn more ways to keep up your progress!',
                      ),
                    ),
                  ),
                  child: const Icon(Icons.arrow_forward),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Post-Workout Summary
          Card(
            color: Colors.orange[50],
            child: ListTile(
              title: const Text('Post-Workout Tip'),
              subtitle: Text('Stay hydrated and stretch after workouts to improve recovery.'),
              leading: const Icon(Icons.local_drink, color: Colors.orange),
              trailing: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailPage(
                      title: 'Post-Workout Tips',
                      content: 'More recovery tips after your workout.',
                    ),
                  ),
                ),
                child: const Icon(Icons.arrow_forward),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Challenge Screen Suggestion
          if (completedChallenges > 0)
            Card(
              color: Colors.purple[50],
              child: ListTile(
                title: const Text('Challenge Yourself Further'),
                subtitle: Text('You\'ve completed $completedChallenges challenges! Try adding one more this week.'),
                leading: const Icon(Icons.emoji_events, color: Colors.purple),
                trailing: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailPage(
                        title: 'Challenge Tips',
                        content: 'Explore new challenges to push yourself further!',
                      ),
                    ),
                  ),
                  child: const Icon(Icons.arrow_forward),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Milestone Achievement
          if (nearMilestone)
            Card(
              color: Colors.yellow[50],
              child: ListTile(
                title: const Text('Almost There!'),
                subtitle: const Text('You\'re close to a new milestone! Consider a light workout today to push through.'),
                leading: const Icon(Icons.flag, color: Colors.yellow),
                trailing: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailPage(
                        title: 'Milestone Tip',
                        content: 'Keep up the momentum and achieve your next milestone!',
                      ),
                    ),
                  ),
                  child: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Placeholder page for detail view
class DetailPage extends StatelessWidget {
  final String title;
  final String content;

  const DetailPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(content, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
