import 'package:flutter/material.dart';

import '../../../core/widgets/cohabi_step_indicator.dart';

class PropertyStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const PropertyStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return CohabiStepIndicator(
      currentStep: currentStep,
      totalSteps: totalSteps,
    );
  }
}
