import 'package:fitbattles/settings/app_strings.dart';
import 'package:fitbattles/settings/app_dimens.dart';
import 'package:flutter/material.dart';

// Awards section widget for the EarnedPointsPage
class EarnedPointsAwardsSection extends StatelessWidget {
  final List<String> awards;

  const EarnedPointsAwardsSection({super.key, required this.awards});

  @override
  Widget build(BuildContext context) {
    if (awards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          AppStrings.awardsLabel,
          style: TextStyle(fontSize: AppDimens.statsTitleSize, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Display each award
        ...awards.map((award) => Text(
          award,
          style: const TextStyle(fontSize: AppDimens.statsTextSize),
        )),
        const SizedBox(height: 20),
      ],
    );
  }
}

