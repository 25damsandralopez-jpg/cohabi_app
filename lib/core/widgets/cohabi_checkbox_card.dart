import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class CohabiCheckboxCard extends StatelessWidget {
  final bool value;
  final String text;
  final ValueChanged<bool?>? onChanged;

  const CohabiCheckboxCard({
    super.key,
    required this.value,
    required this.text,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CohabiRadius.md),
        border: Border.all(color: CohabiColors.border),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: CohabiColors.turquoise,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          text,
          style: const TextStyle(
            color: CohabiColors.navy,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
