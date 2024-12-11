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
  int currentIntake = 0;
  int dailyGoal = 4000;
  int cupsConsumed = 0;
  int totalCups = 8;
  bool goalReached = false;

  List<String> dailyLogs = [];
  late AnimationController _animationController;
  late double progress;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    loadProgress();
    loadWeeklyLogs();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cupsConsumed = prefs.getInt('cupsConsumed') ?? 0;
      currentIntake = cupsConsumed * 500;
      goalReached = cupsConsumed >= totalCups;
      progress = cupsConsumed / totalCups;
    });
  }

  Future<void> loadWeeklyLogs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyLogs = prefs.getStringList('dailylogs') ?? [];
    });
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('cupsConsumed', cupsConsumed);
  }

  Future<void> logWeeklyConsumption() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final formattedDate = DateFormat('EEE, MMM d').format(now);
    final logEntry = 'Day of $formattedDate: $currentIntake mL';

    setState(() {
      dailyLogs.add(logEntry);
    });

    await prefs.setStringList('weeklyLogs', dailyLogs);
  }

  void resetProgress() {
    setState(() {
      cupsConsumed = 0;
      currentIntake = 0;
      goalReached = false;
      progress = 0.0;
    });
    saveProgress();
  }

  void onCupConsumed() {
    setState(() {
      if (cupsConsumed < totalCups) {
        cupsConsumed++;
        currentIntake += 500;
        progress = cupsConsumed / totalCups;

        _animationController.value = progress;

        if (cupsConsumed == totalCups) {
          goalReached = true;
          _animationController.forward();
          logWeeklyConsumption();
        }
      }
    });
    saveProgress();
  }

  int calculateWeeklyTotal() {
    int total = 0;
    for (var log in dailyLogs) {
      final match = RegExp(r'(\d+) mL').firstMatch(log);
      if (match != null) {
        total += int.parse(match.group(1)!);
      }
    }
    return total;
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingLarge),
          child: Column(
            children: [
              // Title and Total Weekly Consumption
              Text(
                'Hydration Tracker',
                style: TextStyle(fontSize: AppDimens.fontLarge, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Total Water Consumed This Week: ${calculateWeeklyTotal()} mL',
                style: TextStyle(fontSize: AppDimens.fontMedium, fontWeight: FontWeight.bold, color: AppColors.waterBlue),
              ),
              const SizedBox(height: AppDimens.spacingMedium),

              // Animation
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  'assets/animations/muscle_cup.json',
                  fit: BoxFit.contain,
                  controller: _animationController,
                ),
              ),
              if (goalReached)
                Icon(Icons.sentiment_very_satisfied, size: 100, color: AppColors.waterBlue),
              const SizedBox(height: AppDimens.spacingSmall),

              // Progress Info
              Text(
                '$currentIntake mL',
                style: TextStyle(fontSize: AppDimens.fontLarge, fontWeight: FontWeight.bold),
              ),
              Text('${(progress * 100).toStringAsFixed(0)}%'),
              Text('$cupsConsumed/$totalCups ${AppStrings.cups}'),
              Text('${AppStrings.dailyGoal} $dailyGoal mL'),
              const SizedBox(height: AppDimens.spacingSmall),

              // Cup Icons
              Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(totalCups, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.local_drink,
                      color: index < cupsConsumed ? AppColors.waterBlue : AppColors.lightGray,
                    ),
                    onPressed: () {
                      if (!goalReached) onCupConsumed();
                    },
                  );
                }),
              ),
              const SizedBox(height: AppDimens.spacingSmall),

              // Weekly Logs and Total Water Consumption
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Text(
                      'Daily Water Consumption',
                      style: TextStyle(fontSize: AppDimens.fontMedium, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: AppDimens.fontLarge, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
