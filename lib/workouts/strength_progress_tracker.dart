import 'package:fitbattles/settings/app_colors.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:fitbattles/settings/app_strings.dart';
import 'package:flutter/material.dart';


class StrengthWorkoutPage extends StatelessWidget {
  const StrengthWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.workoutTitle),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          children: [
            Text(AppStrings.workoutDescription, style: TextStyle(fontSize: AppDimens.fontSizeMedium)),
            SizedBox(height: AppDimens.paddingLarge),
            // Other UI components like input fields and buttons
            ElevatedButton(
              onPressed: () {
                // Calculate volume logic
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, AppDimens.buttonHeight), backgroundColor: AppColors.accentColor,
              ),
              child: Text(AppStrings.calculateVolumeButton),
            ),
          ],
        ),
      ),
    );
  }
}
