import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengesInitializer {
  static final List<Map<String, dynamic>> communityChallenges = [
    {
      "name": "Core Crusher",
      "description": "A rigorous challenge designed to strengthen your core muscles, including the abs, obliques, and lower back. Perfect for those aiming to build a solid foundation of strength.",
      "intensity": 3.0,
      "goal": "To win, complete a series of core exercises (e.g., planks, sit-ups, leg raises) every day for 30 days. Track your progress by the number of days you complete your core workout."
    },
    {
      "name": "Goal Setter",
      "description": "Set clear, achievable fitness goals and track your progress to see how far you've come. This challenge motivates you to push past your limits while celebrating every milestone.",
      "intensity": 2.0,
      "goal": "To win, set at least three fitness goals (e.g., run 5K, lose 5 lbs, etc.) and track your daily or weekly progress. Complete at least 80% of your set goals within 30 days."
    },
    {
      "name": "Healthy Habit",
      "description": "This challenge helps you establish and maintain long-term healthy habits such as proper hydration, balanced eating, and regular exercise. A great way to improve your overall well-being.",
      "intensity": 2.5,
      "goal": "To win, form and stick to 3 healthy habits (e.g., drink 8 cups of water daily, avoid junk food, exercise for 30 minutes each day) for at least 21 days."
    },
    {
      "name": "Community Leader",
      "description": "Become a leader in your fitness community by inspiring others to stay active, motivated, and engaged. Lead group workouts, encourage fellow participants, and foster a sense of community.",
      "intensity": 4.0,
      "goal": "To win, engage with at least 10 other participants, encourage them to join workouts, and motivate them to stay on track. Aim to lead or organize at least 2 community fitness sessions."
    },
    {
      "name": "Nutrition Enthusiast",
      "description": "Focus on improving your eating habits and understanding the importance of balanced, nutritious meals. Challenge yourself to make healthier food choices every day.",
      "intensity": 3.5,
      "goal": "To win, follow a balanced meal plan that includes healthy foods (e.g., fruits, vegetables, whole grains) and avoid processed junk food for 30 days. Track your meals and share your progress with others."
    },
    {
      "name": "Cardio King/Queen",
      "description": "Increase your cardiovascular endurance with daily cardio workouts, including running, cycling, swimming, or any other heart-pumping activity. Aimed at boosting stamina and heart health.",
      "intensity": 4.5,
      "goal": "To win, complete a minimum of 150 minutes of cardio each week for 4 weeks (about 30 minutes a day). You can choose activities like running, cycling, swimming, or even brisk walking."
    },
    {
      "name": "Strength Specialist",
      "description": "For those passionate about building muscle and increasing strength. This challenge includes lifting, bodyweight exercises, and more to push your limits and see significant gains.",
      "intensity": 5.0,
      "goal": "To win, complete a strength training routine (e.g., weightlifting, push-ups, squats) at least 4 times a week for 30 days. Track your progress by the amount of weight lifted or the number of repetitions performed."
    },
    {
      "name": "Fit Friend",
      "description": "Team up with friends to make fitness fun and social. This challenge encourages you to workout together, motivate each other, and celebrate victories as a team.",
      "intensity": 2.0,
      "goal": "To win, team up with at least one friend and complete fitness activities together at least 3 times a week for 30 days. Make sure to cheer each other on and share your progress."
    },
    {
      "name": "10K Steps a Day",
      "description": "Take on the goal of walking 10,000 steps every day. This challenge is all about incorporating movement into your daily routine, whether it’s walking, jogging, or exploring new routes.",
      "intensity": 3.0,
      "goal": "To win, walk at least 10,000 steps every day for 30 days. Track your steps using a fitness tracker or phone app and aim to stay consistent each day."
    },
    {
      "name": "Consistent Trainer",
      "description": "Consistency is key in this challenge. Commit to regular workouts, whether they’re strength training, cardio, or flexibility exercises. The goal is to build a routine and stick with it over time.",
      "intensity": 4.0,
      "goal": "To win, complete at least 4 workouts every week for 30 days, combining different types of exercises (strength, cardio, flexibility). Aim for consistency in your training schedule and progress over time."
    },
  ];

  static Future<void> uploadChallengesToFirestore() async {
    final collectionRef = FirebaseFirestore.instance.collection('communityChallenges');

    for (var challenge in communityChallenges) {
      // Create a document ID based on the challenge name to avoid duplicates.
      String docId = challenge['name'].replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');

      // Check if the challenge already exists to avoid duplicate entries.
      DocumentSnapshot docSnapshot = await collectionRef.doc(docId).get();
      if (!docSnapshot.exists) {
        await collectionRef.doc(docId).set({
          ...challenge,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
