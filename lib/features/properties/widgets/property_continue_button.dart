import 'package:flutter/material.dart';

import '../../../core/widgets/cohabi_primary_button.dart';

class PropertyContinueButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PropertyContinueButton({
    super.key,
    this.text = 'Continuar',
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CohabiPrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}
