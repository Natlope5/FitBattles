import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutHistoryPage extends StatelessWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user ID
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Reference to the user's workouts collection
    CollectionReference workoutsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('workouts');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workout History'),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: workoutsRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if there is data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No workout history found.'));
          }

          // Map the workout documents to a list
          final workoutDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: workoutDocs.length,
            itemBuilder: (context, index) {
              // Get each workout data
              final workoutData = workoutDocs[index].data() as Map<String, dynamic>;

              // Extract fields with null checks
              final workoutType = workoutData['workoutType'] ?? 'Unknown';
              final intensity = workoutData['intensity'] ?? 'Unknown';
              final duration = workoutData['duration'];
              final calories = workoutData['calories'];
              final timestamp = workoutData['timestamp'] as Timestamp?;

              // Format the timestamp
              String formattedDate = 'Unknown Date';
              if (timestamp != null) {
                DateTime date = timestamp.toDate();
                formattedDate = '${date.day}/${date.month}/${date.year}';
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4.0,
                child: ListTile(
                  title: Text('$workoutType - $intensity'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Duration: ${duration != null ? '$duration minutes' : 'N/A'}'),
                      Text('Calories Burned: ${calories != null ? calories.toStringAsFixed(2) : 'N/A'}'),
                      Text('Date: $formattedDate'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}