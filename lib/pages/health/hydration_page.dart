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
      dailyLogs = prefs.getStringList('dailyLogs') ?? [];
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
    await prefs.setStringList('dailyLogs', dailyLogs);
  }

  void autoResetProgress() {
    setState(() {
      cupsConsumed = 0;
      currentIntake = 0;
      goalReached = false;
      progress = 0.0;
      _animationController.reset();
    });
    saveProgress();
    logWeeklyConsumption();
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
          Future.delayed(Duration(seconds: 3), () {
            autoResetProgress();
          });
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: autoResetProgress,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hydration Tracker',
                style: TextStyle(fontSize: AppDimens.fontLarge, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimens.spacingSmall),
              Text(
                'Total Water Consumed This Week: ${calculateWeeklyTotal()} mL',
                style: TextStyle(fontSize: AppDimens.fontMedium, color: AppColors.waterBlue),
              ),
              const SizedBox(height: AppDimens.spacingMedium),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$currentIntake mL',
                          style: TextStyle(fontSize: AppDimens.fontLarge, fontWeight: FontWeight.bold),
                        ),
                        Text('${(progress * 100).toStringAsFixed(0)}% of daily goal'),
                        Text('$cupsConsumed/$totalCups ${AppStrings.cups}'),
                        Text('${AppStrings.dailyGoal} $dailyGoal mL'),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 150,
                      child: Lottie.asset(
                        'assets/animations/muscle_cup.json',
                        fit: BoxFit.contain,
                        controller: _animationController,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spacingMedium),
              Text(
                'Track Your Cups',
                style: TextStyle(fontSize: AppDimens.fontMedium, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimens.spacingSmall),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: totalCups,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: IconButton(
                        icon: Icon(
                          Icons.local_drink,
                          color: index < cupsConsumed ? AppColors.waterBlue : AppColors.lightGray,
                          size: 32,
                        ),
                        onPressed: () {
                          if (!goalReached) onCupConsumed();
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDimens.spacingMedium),
              Text(
                'Daily Water Consumption',
                style: TextStyle(fontSize: AppDimens.fontMedium, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimens.spacingSmall),
              ...dailyLogs.map((log) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(log, style: TextStyle(fontSize: AppDimens.fontSmall)),
              )),
              if (goalReached)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      AppStrings.congratulations,
                      style: TextStyle(fontSize: AppDimens.fontLarge, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
