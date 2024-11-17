class AppStrings {
  // Authentication Messages
  static const String authSignInSuccess = "User signed in: %1\$s";
  static const String authSignInFailed = "Sign in failed: %1\$s";
  static const String authRegisterSuccess = "User registered: %1\$s";
  static const String authVerificationSent = "Verification email sent to %1\$s";
  static const String authRegisterFailed = "Registration failed: %1\$s";
  static const String authPasswordResetSuccess = "Password reset email sent to %1\$s";
  static const String authPasswordResetFailed = "Password reset failed: %1\$s";
  static const String authSignOutSuccess = "User signed out.";
  static const String authSessionSaved = "User session saved.";
  static const String authSessionCleared = "User session cleared.";

  // App Details
  static const String appName = "FitBattles";
  static const String loginPageTitle = "Login Page";

  // Labels and Buttons
  static const String emailLabel = "Email";
  static const String passwordLabel = "Password";
  static const String signInButtonText = "FitBattles";
  static const String forgotPasswordText = "Forgot Password?";
  static const String signUpText = "Don’t have an account? Sign up here.";
  static const String emailEmptyError = "Email and password cannot be empty.";
  static const String resetPasswordSent = "Password reset email sent! Please check your inbox.";
  static const String userNotFoundError = "No user found for that email.";
  static const String wrongPasswordError = "Wrong password provided for that user.";
  static const String defaultError = "An error occurred. Please try again.";

  // User Details
  static const String userEmailKey = "user_email";
  static const String loginErrorMessage = "An unexpected error occurred. Please try again.";
  static const String logoutSuccessMessage = "You have been logged out successfully.";

  // Sign Up Details
  static const String signupTitle = "Sign Up";
  static const String emailHint = "Email";
  static const String passwordHint = "Password";
  static const String signupButtonText = "Sign Up";
  static const String errorEmptyFields = "Please fill in all fields.";
  static const String errorEmailInUse = "The email is already in use. Please use another email.";
  static const String errorWeakPassword = "The password provided is too weak.";
  static const String errorGeneric = "An error occurred. Please try again.";
  static const String successRegistration = "Successfully registered as %1\$s";
  static const String loginLinkText = "Already have an account? Log In";

  // Challenge Details
  static const String challengeName = "Challenge Name";
  static const String challengeType = "Challenge Type";
  static const String startDate = "Start Date";
  static const String endDate = "End Date";
  static const String participants = "Participants";
  static const String challengeActive = "This challenge is active.";
  static const String challengeInactive = "This challenge is not active.";
  static const String challengeName10000Steps = "10,000 Steps Challenge";
  static const String challengeNameRunning = "Running Challenge";
  static const String challengeNameHealthyEating = "Healthy Eating Challenge";
  static const String challengeNameSitup = "SitUp Challenge";
  static const String challengeName100Squat = "100 Squat Challenge";
  static const String challengeTypeFitness = "Fitness";

  // Challenge Input Details
  static const String challengeNameError = "Please enter a challenge name";
  static const String challengeTypeError = "Please enter a challenge type";
  static const String selectStartDate = "Select Start Date";
  static const String selectEndDate = "Select End Date";
  static const String selectParticipant = "Select Participant";
  static const String participantError = "Please select at least one participant";
  static const String selectVideo = "Select Video";
  static const String notifyOpponents = "Notify Opponents";
  static const String createChallenge = "Create Challenge";

  static const String pickVideo = "Select Video";
  static const String participant = "Participant"; // Singular form


  static const String distanceWorkoutTitle = 'Distance Workout';
  static const String preloadedWorkoutLabel = 'Preloaded Workout: ';
  static const String enterDistanceHint = 'Enter Distance (in km)';
  static const String logDistanceButton = 'Log Distance';
  static const String totalLoggedDistanceLabel = 'Total Logged Distance: ';
  static const String motivationalMessage = 'Keep pushing your limits! Every meter counts.';

  static const String earnedPointsTitle = 'Your Earned Points';
  static const String pointsLabel = 'Points';
  static const String goalPercentageLabel = '% of your goal reached';
  static const String keepGoingMessage = 'Keep going! You’re doing great!';
  static const String congratulationsMessage = 'Congratulations! You reached your goal!';
  static const String yourRankLabel = 'Your Rank: ';
  static const String awardsLabel = 'Awards:';
  static const String totalChallengesCompletedLabel = 'Total Challenges Completed: ';
  static const String pointsEarnedTodayLabel = 'Points Earned Today: ';
  static const String bestDayLabel = 'Best Day: ';
  static const String currentStreakLabel = 'Current Streak: ';
  static const String maintainStreakMessage = 'Maintain your streak to earn bonus points each day!';
  static const String backToHomeButton = 'Back to Home';
  static const String statisticsTitle = 'Statistics';
  static const String bronzeTrophy = '🏆 Bronze Trophy: Completed 5 Challenges';
  static const String silverTrophy = '🏆 Silver Trophy: Completed 10 Challenges';
  static const String goldTrophy = '🏆 Gold Trophy: Completed 20 Challenges';
  static const String platinumTrophy = '🏆 Platinum Trophy: Completed 50 Challenges';

  static const String leaderboardTitle = 'Leaderboard';
  static const String leaderboardRefreshed = 'Leaderboard refreshed';
  static const String errorLoadingLeaderboard = 'Error loading leaderboard';
  static const String noLeaderboardData = 'No leaderboard data available';
  static const String streak = 'Streak';
  static const String days = 'days';


  static const String strengthWorkoutTitle = 'Strength Workout';
  static const String strengthWorkoutChallengesTitle = 'Strength Workout Challenges';
  static const String sampleWorkoutsDescription = 'Here are some sample workouts:';
  static const String pushUps = 'Push Ups';
  static const String pushUpsDescription = '3 sets of 10 reps';
  static const String squats = 'Squats';
  static const String squatsDescription = '3 sets of 15 reps';
  static const String sitUps = 'Sit ups';
  static const String sitUpsDescription = '3 sets of 8 reps';
  static const String benchPress = 'Bench Press';
  static const String benchPressDescription = '3 sets of 10 reps';
  static const String lunges = 'Lunges';
  static const String lungesDescription = '3 sets of 12 reps per leg';
  static const String workoutStarted = 'Workout started!';
  static const String startWorkoutButton = 'Start Workout';

  static const String distanceLoggedMessage = "Distance logged successfully!";
  static const String distanceInputError = "Please enter a valid number.";
  static const String invalidDistanceMessage = "Invalid distance entered. Please try again.";


  static const String localizedErrorTrackingFailed = 'Error tracking localization. Please try again.';
  static const String localizedErrorInitializing = 'Error initializing localization. Please check permissions.';


  static const String preloadedChallengesTitle = 'Preloaded Challenges';
  static const String challengeTypeLabel = 'Type:';
  static const String challengeDurationLabel = 'Duration:';

  static const String errorUserIdEmpty = 'User ID cannot be empty';
  static const String defaultPrivacySetting = 'public'; // Default privacy setting
  static const String privacySettingUpdated = 'Privacy setting updated successfully';


  static const String userIdEmptyError = 'User ID cannot be empty';
  static const String privacyFetchError = 'Error fetching privacy setting';

  static const String notificationPermissionGranted = 'Notification permission granted';
  static const String notificationPermissionProvisional = 'Notification permission provisional';
  static const String notificationPermissionDenied = 'Notification permission denied';
  static const String foregroundMessageReceived = 'Foreground message received';
  static const String backgroundMessageOpened = 'Background message opened';
  static const String appOpenedByNotification = 'App opened by notification';
  static const String errorSettingUpMessaging = 'Error setting up messaging';
  static const String handlingMessage = 'Handling message: ';


  // Foreground Message
  static const String messageData = 'Message data:';
  static const String goalNotificationChannel = 'Goal Notifications';
  static const String goalNotificationChannelDescription = 'Notifications for goal updates';
  static const String goalNotificationDisplayed = 'Goal notification displayed:';
  static const String errorShowingGoalNotification = 'Error showing goal notification:';
  static const String notificationTapped = 'Notification tapped:';
  static const String backgroundMessageHandled = 'Background message handled:';
  static const String failedToInitializeGoalNotifications = 'Failed to initialize goal notifications:';
  static const String goalNotificationsInitializedSuccessfully = 'Goal notifications initialized successfully.';


  static const String friendsTitle = 'Friends';
  static const String searchFriendsLabel = 'Search Friends';
  static const String addedFriendMessage = ' has been added to your friends list.';
  static const String noFriendsAdded = 'No friends added.';
  static const String challengeStats = 'Challenge Stats';
  static const String closeButtonLabel = 'Close';

  static const String goalCompletionTitle = 'Goal Completion';
  static const String notificationSuccess = 'Notification sent successfully.';
  static const String notificationFailure = 'Failed to send notification: ';
  static const String errorOccurred = 'An error occurred: ';
  static const String sendNotificationButton = 'Send Notification';


  static const String headerTitle = 'Welcome to FitBattles!';
  static const String pointsEarnedTitle = 'Points Earned';
  static const String pointsUnit = 'pts';
  static const String viewEarnedPointsButton = 'View Earned Points';
  static const String challengesTitle = 'Challenges';
  static const String hideChallengesButton = 'Hide Challenges';
  static const String showChallengesButton = 'Show Challenges';
  static const String createChallengeButton = 'Create Challenge';
  static const String historyTitle = 'History';
  static const String viewHistoryButton = 'View History';
  static const String topChallengedFriendsTitle = 'Top Challenged Friends';
  static const String trackWorkoutButton = 'Track Workout';

  static const String hydrationTracker = 'Hydration Tracker';
  static const String yourWaterIntake = 'Your Water Intake';
  static const String dailyGoal = 'Daily Goal';
  static const String addWaterIntake = 'Add Water Intake';
  static const String enterAmountInLiters = 'Enter amount in liters';
  static const String hintExample = 'e.g. 0.5';
  static const String cancel = 'Cancel';
  static const String add = 'Add';


  static const String myHistory = 'My History';
  static const String summary = 'Summary';
  static const String pointsWon = 'Points Won';
  static const String caloriesLost = 'Calories Lost';
  static const String waterIntake = 'Water Intake (liters)';
  static const String workoutSessions = 'Workout Sessions';
  static const String challengesWon = 'Challenges Won';
  static const String challengesLost = 'Challenges Lost';
  static const String challengesTied = 'Challenges Tied';
  static const String friendsInvolved = 'Friends Involved';
  static const String friendsInvolvedDetail = 'Friends who participated in challenges with you.';
  static const String pointsWonDetail = 'Points earned through various challenges and activities.';
  static const String caloriesLostDetail = 'Total calories burned during workout sessions.';
  static const String waterIntakeDetail = 'Amount of water consumed throughout the day.';
  static const String workoutSessionsDetail = 'Total number of workout sessions completed this month.';
  static const String challengesWonDetail = 'Challenges that you have successfully completed.';
  static const String challengesLostDetail = 'Challenges that you were unable to complete.';
  static const String challengesTiedDetail = 'Challenges that ended in a tie.';
  static const String none = 'None';
  static const String close = 'Close';


  static const String settings = 'Settings';
  static const String selectTheme = 'Select Theme';
  static const String lightTheme = 'Light Theme';
  static const String darkTheme = 'Dark Mode';
  static const String lightThemeSelected = 'Light Theme selected';
  static const String darkThemeSelected = 'Dark Theme selected';

// Privacy settings
  static const String privacySettings = 'Privacy Settings';
  static const String shareData = 'Share Data';
  static const String allowSharingData = 'Allow sharing your data with third parties.';
  static const String receiveNotifications = 'Receive Notifications';
  static const String enableNotifications = 'Enable notifications for updates and offers.';

  // Save settings
  static const String saveSettings = 'Save Settings';
  static const String settingsSaved = 'Settings saved';

  static const String loading = 'Loading...';
  static const String noName = 'No Name';
  static const String defaultPrivacy = 'Public';
  static const String userProfileNotFound = 'User profile not found.';
  static const String failedToFetchProfile = 'Failed to fetch user profile';
  static const String error = 'Error';
  static const String ok = 'OK';
  static const String userProfile = 'User Profile';
  static const String name = 'Name';
  static const String privacySetting = 'Privacy Setting';
  static const String editPrivacySettings = 'Edit Privacy Settings';


  static const String noEmail = 'No Email';
  static const String userDoesNotExist = 'User does not exist.';
  static const String notAllowedToView = 'You are not allowed to view this profile.';
  static const String profileIsPrivate = 'This profile is private.';
  static const String invalidPrivacySetting = 'Invalid privacy setting.';

  static const String workoutTrackerTitle = 'Workout Tracker';
  static const String workoutTypeStrength = 'Workout Type: Strength';
  static const String enterCaloriesBurned = 'Enter Calories Burned:';
  static const String caloriesHint = 'Calories';
  static const String calorieValueError = 'Please enter a calorie value';
  static const String validNumberError = 'Please enter a valid number';
  static const String caloriesLogged = 'Calories logged: ';
  static const String logCalories = 'Log Calories';
  static const String totalCaloriesBurned = 'Total Calories Burned: ';
  static const String caloriesLog = 'Calories Log:';
  static const String calorieLogCleared = 'Calorie log cleared!';
  static const String clearLog = 'Clear Log';
  static const String workoutIntensityModerate = 'Intensity: Moderate';
  static const String start = 'Start';
  static const String pause = 'Pause';
  static const String stop = 'Stop';
  static const String calories = 'calories';
  static const String cameraTitle = 'Camera';
  static const String recordVideo = 'Record Video';

  static const String generalNotificationsChannel = 'General Notifications';
  static const String channelDescription = 'General notifications for the app';
  static const String notificationError = 'Error showing notification: ';
  static const String notificationDisplayed = 'Notification displayed: ';
  static const String notificationsInitialized = 'Notifications initialized successfully.';
  static const String notificationsInitializationFailed = 'Failed to initialize notifications: ';
  static const String goalCompletedPayload = 'goal_completed';

  static const String temporaryDirectoryLog = 'Temporary directory: ';
  static const String errorGettingTempDir = 'Error getting temporary directory: ';


  static const String notificationPermissionPermanentlyDenied = 'Notification permission permanently denied';
  static const String notificationPermissionRestricted = 'Notification permission is restricted';
  static const String unknownPermissionStatus = 'Unknown permission status: ';
  static const String openingAppSettings = 'Opening app settings for notification permission...';


  static const String appThemeKey = 'appTheme';
  static const String defaultTheme = 'light';
  static const String themeKey = 'theme';


  // Theme Selection Strings
  static const String themeTitle = 'Select Theme';
  static const String themeChanged = 'Theme changed successfully';

  static const String selectChallenge = 'Select Challenge';
  static const String sendChallenge = 'Send Challenge';
  static const String challengeSent = 'Challenge sent:';

  static const String workoutTitle = 'Strength Workout';
  static const String workoutDescription = 'Track your strength workout progress';
  static const String repsLabel = 'Reps';
  static const String setsLabel = 'Sets';
  static const String weightLabel = 'Weight (kg)';
  static const String calculateVolumeButton = 'Calculate Volume';
  static const String volumeResult = 'Total Volume: ';
  static const String invalidInputError = 'Please enter positive values for reps, sets, and weight.';

  static const String totalDistanceLabel = 'Total Distance: ';
  static const String stopTrackingButton = 'Stop Tracking';
  static const String errorTitle = 'Error';
  static const String errorMessage = 'An error occurred during tracking.';
  static const String trackingStartedMessage = 'Tracking started.';
  static const String trackingPausedMessage = 'Tracking paused.';


  // General
  static const String title = 'FitBattles';
  static const String login = 'Login';
  static const String home = 'Home';
  static const String leaderboard = 'Leaderboard';

  // Login
  static const String loginTitle = 'Welcome to FitBattles';
  static const String loginButton = 'Login';
  static const String logoutButton = 'Logout';

  // Tracking and Hydration
  static const String totalDistance = 'Total Distance:';
  static const String hydrationReminder = 'Time to Hydrate!';
  static const String trackingStarted = 'Tracking started.';
  static const String trackingStopped = 'Tracking stopped.';

  // Errors
  static const String errorDialogTitle = 'Error';
  static const String errorDialogOkButton = 'OK';


  // Challenges

  static const String strengthWorkoutDescription = 'Do a strength workout routine to earn points.';
  static const String workoutStartedMessage = 'Workout started!';
  static const String successMessage = 'Success!';


  // Profile
  static const String profileTitle = 'Profile';
  static const String editProfileButton = 'Edit Profile';
  static const String saveButton = 'Save';
  static const String cancelButton = 'Cancel';

  // Friends
  static const String friendsListTitle = 'Friends List';
  static const String addFriendButton = 'Add Friend';
  static const String removeFriendButton = 'Remove Friend';
  static const String challengeFriendButton = 'Challenge a Friend';

  // Placeholders
  static const String replacePlaceholder = 'Replace Placeholder';

  // Add this new string
  static const String errorShowingBackgroundMessage = 'Error showing background message: ';

  static const String shareDataDesc = 'Allow sharing of your workout data with friends and in challenges.';
  static const String receiveNotificationsDesc = 'Receive notifications about app updates, reminders, and friend activities.';


  static const String receiveChallengeNotifications = 'Receive Challenge Notifications';
  static const String receiveChallengeNotificationsDesc = 'Get notified about new challenges.';

  static var dailyReminder = 'Daily Reminder';
  static var dailyReminderDesc = 'Receive a daily reminder for your tasks.';

  static var selectedLanguage = 'Select Language'; // Default value
  static var selectedLanguageDesc = 'Choose your preferred language.'; // You can modify this description as needed
  static const String retryButton = 'Retry';

  // New constant for not authenticated message
  static const String notAuthenticated = 'You need to be logged in to view this profile.';


  static const String notificationChannelName = 'FitBattles Notifications';
  static const String notificationChannelDescription = 'Channel for FitBattles notifications';
  static const String welcomeMessage = 'Welcome to FitBattles!';
  static const String startChallenge = 'Start Challenge';
  static const String earnPoints = 'Earn Points';

  static const String friendsList = 'Friends List';

  static const String appTitle = 'FitBattles';

  static String loggedOut = "You have been logged out successfully.";





  // Titles
  static const String pointsInfoTitle = 'Points Information';
  static const String createProfileTitle = 'Create Profile';
  static const String settingsTitle = 'Settings';




  // Messages

  static const String fetchErrorMessage = 'Error loading data, please try again later.';

  // Button Labels

  static const String registerButton = 'Register';

  static const String viewLeaderboardButton = 'View Leaderboard';
  static const String addGoalButton = 'Add Goal';

  // Navigation Titles
  static const String homePageTitle = 'Home';
  static const String friendsPageTitle = 'Friends';
  static const String historyPageTitle = 'History';
  static const String workoutTrackingPageTitle = 'Workout Tracking';
  static const String healthReportPageTitle = 'Health Report';
  static const String rewardsPageTitle = 'Badges and Rewards';

  // Placeholder Texts
  static const String emailPlaceholder = 'Enter your email';
  static const String passwordPlaceholder = 'Enter your password';

  // Notifications
  static const String friendRequestSent = 'Friend request sent!';
}


