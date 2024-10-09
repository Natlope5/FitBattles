FitBattles
A Fitness Challenge App for Competing with Friends

Introduction
FitBattles is a social fitness app that allows users to create, join, and compete in fitness challenges with friends. With FitBattles you can compete with friends, track your daily workouts, earn badges for reaching milestones, and participate in community challenges. FitBattles makes it fun to stay active and healthy! With seamless integration for tracking workout progress and the ability to compare results with others, it helps keep users motivated on their fitness journey.

Features
Create and Join Challenges: Set up custom fitness challenges or join existing ones with friends or the broader community.
Track Workouts: Input details like distance, duration, sets, reps, and calories burned for various workout types.
Earn Badges and Rewards: Unlock achievements for hitting fitness milestones.
Custom Workout Plans: Create and share workout plans tailored to your fitness goals.
Community Challenges: Participate in weekly or monthly challenges with users from all over the world.
Health Reports: View detailed insights into your fitness progress, including calories burned, workout duration, and more.
Technologies
Frontend: Flutter
Backend: Firebase (Firestore, Authentication, Cloud Functions)
APIs: Google Fit, Apple HealthKit (for workout data sync)
Version Control: GitHub (Gitflow branching strategy)
Installation
To install and run FitBattles on your local machine:

Clone the repository:
git clone https://github.com/Nlope5/fitbattles.git
cd fitbattles

Install Flutter dependencies:
Ensure you have Flutter SDK installed. Run the following command to get dependencies:
flutter pub get

Configure Firebase:

Create a Firebase project and configure Firestore, Authentication, and Cloud Functions.
Update the google-services.json (for Android) and GoogleService-Info.plist (for iOS) files in the project.
Run the app:
Start the development server using:
flutter run

Development Setup
To set up the development environment:

Ensure Flutter SDK is installed:
Follow Flutter’s official installation guide for your operating system.

Install Firebase CLI:
Install Firebase CLI to manage Firestore, Authentication, and Cloud Functions from the command line:
npm install -g firebase-tools

Create a Firebase project:
Follow the Firebase setup guide to link your project with Firebase services.

Set up GitHub repo:
Ensure you have the right permissions to access and contribute to the GitHub repository. Follow the branching strategy (feature branches, pull requests, etc.) for smooth collaboration.

License
This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

Contributors
Frontend Developer: Matthew Tome
Frontend Developer: Lizbett Perez
Backend Developer: Natalie Lopez
Backend Developer: Cameron Speake
Project Status
FitBattles is currently in Alpha. Development is ongoing, and the core features are still being implemented.