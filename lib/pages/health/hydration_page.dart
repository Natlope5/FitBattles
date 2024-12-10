import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int currentIntake = 1000; // Current water intake in mL
  int dailyGoal = 4000; // Daily goal in mL
  int cupsConsumed = 2; // Number of cups consumed
  int totalCups = 8; // Total cups in the daily goal
  bool goalReached = false; // Track if the goal is reached

  late AnimationController _animationController; // Lottie Animation Controller
  late double progress; // Track progress from 0 to 1

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    loadProgress(); // Load saved progress when the page loads
  }

  // Load saved progress from SharedPreferences
  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cupsConsumed = prefs.getInt('cupsConsumed') ?? 0;
      currentIntake = cupsConsumed * 500; // Assuming each cup is 500mL
      goalReached = cupsConsumed >= totalCups;
      progress = cupsConsumed / totalCups; // Update progress as a fraction (0.0 to 1.0)
    });
  }

  // Save the current progress to SharedPreferences
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('cupsConsumed', cupsConsumed);
  }

  // Reset the hydration progress
  void resetProgress() {
    setState(() {
      cupsConsumed = 0;
      currentIntake = 0;
      goalReached = false;
      progress = 0.0;
    });
    saveProgress(); // Save the reset progress
  }

  // Handle user cup consumption
  void onCupConsumed() {
    setState(() {
      cupsConsumed++;
      currentIntake += 500; // Assuming each cup is 500mL
      progress = cupsConsumed / totalCups; // Update progress fraction

      // Update the animation progress based on the cups consumed
      _animationController.value = progress;

      if (cupsConsumed == totalCups) {
        goalReached = true;
        _animationController.forward(); // Start animation when goal is reached
      }
    });
    saveProgress(); // Save the updated progress after consuming a cup
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.hydrationTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dripping Circle Animation
            SizedBox(
              width: 200, // Set the circle size (can be adjusted)
              height: 200,
              child: Lottie.asset(
                'assets/animations/muscle_cup.json',
                fit: BoxFit.contain, // Ensure the image scales properly
                controller: _animationController, // Use the controller
                onLoaded: (composition) {
                  if (!goalReached) {
                    _animationController.forward();
                  }
                },
              ),
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            // Display Smiley Face below the animation when goal is reached
            if (goalReached)
              Icon(
                Icons.sentiment_very_satisfied,
                size: 100,
                color: AppColors.waterBlue,
              ),
            // Display current water intake and progress
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$currentIntake mL',
                  style: TextStyle(
                    fontSize: AppDimens.fontLarge,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: AppDimens.fontMedium,
                    color: AppColors.lightGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            // Display Daily Goal and Cups Information
            Text(
              '$cupsConsumed/$totalCups ${AppStrings.cups}',
              style: TextStyle(
                fontSize: AppDimens.fontMedium,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '${AppStrings.dailyGoal} $dailyGoal mL',
              style: TextStyle(
                fontSize: AppDimens.fontSmall,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            // Water Cup Icons (Wrap Row in SingleChildScrollView to avoid overflow)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(totalCups, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingSmall),
                    child: GestureDetector(
                      onTap: () {
                        if (!goalReached) onCupConsumed(); // Increase intake on cup press
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: index < cupsConsumed
                                  ? AppColors.waterBlue.withValues(alpha: 0.7)
                                  : Colors.transparent,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.local_drink,
                          size: 40,
                          color: index < cupsConsumed
                              ? AppColors.waterBlue
                              : AppColors.lightGray,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            // Reset Button to Clear Progress
            ElevatedButton(
              onPressed: () {
                resetProgress();
              },
              child: Text(AppStrings.reset),
            ),
            // Congratulations message when the goal is reached
            if (goalReached)
              Padding(
                padding: const EdgeInsets.only(top: AppDimens.spacingLarge),
                child: Text(
                  AppStrings.congratulations,
                  style: TextStyle(
                    fontSize: AppDimens.fontLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.waterBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
