import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fitbattles/settings/ui/app_colors.dart';
import 'package:fitbattles/settings/ui/app_strings.dart';
import 'package:fitbattles/settings/ui/app_dimens.dart';
import 'package:lottie/lottie.dart';

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  HydrationPageState createState() => HydrationPageState();
}

class HydrationPageState extends State<HydrationPage> with TickerProviderStateMixin {
  int currentIntake = 0; // Tracks current water intake in mL
  int dailyGoal = 4000; // Set goal for daily water consumption
  int cupsConsumed = 0; // Number of cups consumed so far
  int totalCups = 8; // Total cups to consume to reach goal
  bool goalReached = false; // Whether the daily goal has been reached

  List<String> dailyLogs = []; // Logs for daily water consumption
  late AnimationController _animationController; // Controls the animation of water consumption progress
  late double progress; // The progress of water intake as a percentage

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500)); // Initialize animation controller
    loadProgress(); // Load the saved progress
    loadWeeklyLogs(); // Load logs of water consumption for the week
  }

  // Loads the saved progress from SharedPreferences
  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cupsConsumed = prefs.getInt('cupsConsumed') ?? 0; // Load number of cups consumed
      currentIntake = cupsConsumed * 500; // Calculate the total intake based on cups
      goalReached = cupsConsumed >= totalCups; // Check if the goal is reached
      progress = cupsConsumed / totalCups; // Calculate progress
    });
  }

  // Loads weekly water consumption logs from SharedPreferences
  Future<void> loadWeeklyLogs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyLogs = prefs.getStringList('dailyLogs') ?? []; // Load daily logs
    });
  }

  // Saves the current progress (cups consumed) to SharedPreferences
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('cupsConsumed', cupsConsumed); // Save cups consumed
  }

  // Logs the current water consumption and saves it to the logs
  Future<void> logWeeklyConsumption() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final formattedDate = DateFormat('EEE, MMM d').format(now); // Format the current date
    final logEntry = 'Day of $formattedDate: $currentIntake mL'; // Log entry for the day

    setState(() {
      dailyLogs.add(logEntry); // Add the log entry to the daily logs
    });

    await prefs.setStringList('dailyLogs', dailyLogs); // Save logs to SharedPreferences
  }

  // Resets the progress (cups consumed) and the animation
  void resetProgress() {
    setState(() {
      cupsConsumed = 0;
      currentIntake = 0;
      goalReached = false;
      progress = 0.0;
    });
    saveProgress(); // Save the reset progress
  }

  // Increments the cups consumed when a cup is consumed
  void onCupConsumed() {
    setState(() {
      if (cupsConsumed < totalCups) {
        cupsConsumed++; // Increment the cups consumed
        currentIntake += 500; // Increase the intake by 500 mL per cup
        progress = cupsConsumed / totalCups; // Update progress

        _animationController.value = progress; // Update the animation progress

        if (cupsConsumed == totalCups) {
          goalReached = true; // Mark goal as reached
          _animationController.forward(); // Play the animation when the goal is reached
          logWeeklyConsumption(); // Log the consumption for the day
        }
      }
    });
    saveProgress(); // Save the updated progress
  }

  // Calculates the total water consumed for the week from the logs
  int calculateWeeklyTotal() {
    int total = 0;
    for (var log in dailyLogs) {
      final match = RegExp(r'(\d+) mL').firstMatch(log); // Extract the water amount from the log
      if (match != null) {
        total += int.parse(match.group(1)!); // Add the water amount to the total
      }
    }
    return total; // Return the total consumption for the week
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose of the animation controller when no longer needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.hydrationTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface, // App bar style
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingLarge), // Main page padding
          child: Column(
            children: [
              // Title and Weekly Consumption Display
              Text(
                'Hydration Tracker',
                style: TextStyle(fontSize: AppDimens.fontLarge, fontWeight: FontWeight.bold), // Title styling
              ),
              const SizedBox(height: 10),
              Text(
                'Total Water Consumed This Week: ${calculateWeeklyTotal()} mL', // Total weekly consumption
                style: TextStyle(fontSize: AppDimens.fontMedium, fontWeight: FontWeight.bold, color: AppColors.waterBlue), // Styling for total weekly consumption
              ),
              const SizedBox(height: AppDimens.spacingMedium),

              // Lottie animation for progress
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  'assets/animations/muscle_cup.json', // Animation for water consumption
                  fit: BoxFit.contain,
                  controller: _animationController,
                ),
              ),
              if (goalReached)
                Icon(Icons.sentiment_very_satisfied, size: 100, color: AppColors.waterBlue), // Display a happy icon if the goal is reached
              const SizedBox(height: AppDimens.spacingSmall),

              // Progress info
              Text(
                '$currentIntake mL',
                style: TextStyle(fontSize: AppDimens.fontLarge, fontWeight: FontWeight.bold),
              ),
              Text('${(progress * 100).toStringAsFixed(0)}%'), // Display progress percentage
              Text('$cupsConsumed/$totalCups ${AppStrings.cups}'), // Display cups consumed and total cups
              Text('${AppStrings.dailyGoal} $dailyGoal mL'), // Display daily goal
              const SizedBox(height: AppDimens.spacingSmall),

              // Display cup icons to track consumed cups
              Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(totalCups, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.local_drink,
                      color: index < cupsConsumed ? AppColors.waterBlue : AppColors.lightGray, // Display filled or empty cup icons
                    ),
                    onPressed: () {
                      if (!goalReached) onCupConsumed(); // Increment when a cup is pressed
                    },
                  );
                }),
              ),
              const SizedBox(height: AppDimens.spacingSmall),

              // Weekly logs display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Text(
                      'Daily Water Consumption',
                      style: TextStyle(fontSize: AppDimens.fontMedium, fontWeight: FontWeight.bold), // Section title
                    ),
                    const SizedBox(height: 10),
                    ...dailyLogs.map((log) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        log,
                        style: TextStyle(fontSize: AppDimens.fontSmall),
                      ),
                    )),
                  ],
                ),
              ),

              // Reset Button
              ElevatedButton(onPressed: resetProgress, child: Text(AppStrings.reset)),

              if (goalReached)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    AppStrings.congratulations,
                    style: TextStyle(fontSize: AppDimens.fontLarge, fontWeight: FontWeight.bold), // Congratulations text when goal is reached
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
