import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CohabiStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool showLabel;

  const CohabiStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final safeStep = currentStep.clamp(0, totalSteps - 1);

    return Column(
      children: [
        if (showLabel)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: CohabiColors.turquoiseSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Paso ${safeStep + 1} de $totalSteps',
              style: const TextStyle(
                color: CohabiColors.turquoise,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        if (showLabel) const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalSteps,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index <= safeStep
                    ? CohabiColors.turquoise
                    : CohabiColors.border,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
