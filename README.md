FitBattles
FitBattles is a Flutter application designed to help users track and improve their fitness journey through engaging challenges and community support.

Getting Started
FitBattles is built using Flutter and Firebase to provide real-time fitness tracking, challenges, and community engagement. This project is a starting point for building fitness-centric mobile applications with Flutter.

Resources
If this is your first Flutter project, you can find helpful resources below:

Lab: Write your first Flutter app
Cookbook: Useful Flutter samples
Flutter Documentation
Firebase Documentation
Features
User Authentication: Sign up and log in using Firebase Authentication.
Fitness Challenges: Participate in preset or custom challenges to compete with friends or others in the community.
Progress Tracking: Track your fitness progress with real-time visual graphs and statistics.
Community Leaderboard: Compete on a global or friend-specific leaderboard to see how your fitness progress compares to others.
User Profiles: Create and customize your user profile, showcasing achievements, challenges completed, and progress.
Installation
To run this project locally, follow these steps:

Prerequisites
Ensure you have the following installed:

Flutter SDK (version 3.26.0 or higher)
Dart
Android Studio or Visual Studio Code (with Flutter and Dart plugins)
Firebase CLI (for Firebase integration)
Steps
Clone the repository:

git clone https://github.com/Natlope5/FitBattles.git
cd fitbattles
Install dependencies: Run the following command to fetch the required Flutter and Dart packages:

flutter pub get
Configure Firebase:

Set up Firebase in your Flutter app by following this guide.
Add your google-services.json (for Android) and GoogleService-Info.plist (for iOS) to the respective android and ios directories.
Enable Firebase Authentication, Firestore, and Firebase Cloud Messaging in your Firebase Console.
Run the app: You can run the app on an emulator or connected device:

flutter run
Optional Configuration
Google Fonts: Ensure to install fonts manually if desired, as google_fonts package might not be included.
Git LFS: If you're using large files such as videos or APKs, ensure you have Git LFS configured in the project by running git lfs install.
Usage
Sign Up: Create an account using Firebase Authentication (or log in if you already have an account).
Create Challenges: Create your custom fitness challenges or join preloaded ones.
Track Progress: View your performance and progress through the app’s visual graphs and progress meters.
Community Engagement: Participate in challenges, track friends' progress, and engage through the leaderboard.
Directory Structure
Here's an overview of the project's directory structure:

lib/
│
├── auth/                  # Authentication-related files
├── challenges/            # Challenge-related logic and UI
├── location/              # Location-based services
├── models/                # Data models (e.g., user, challenge)
├── notifications/         # Push notifications logic
├── screens/               # UI Screens (e.g., HomePage, ProfilePage)
├── settings/              # Settings page and logic
└── workouts/              # Workout tracking and history
Contributing
If you'd like to contribute to FitBattles:

Fork the repository.
Create a new branch (git checkout -b feature/new-feature).
Commit your changes (git commit -m "Add new feature").
Push to the branch (git push origin feature/new-feature).
Open a pull request.
License
FitBattles is licensed under the MIT License. See LICENSE for more information.