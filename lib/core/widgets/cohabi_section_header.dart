import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CohabiSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextAlign textAlign;

  const CohabiSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisAlignment = textAlign == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            title,
            textAlign: textAlign,
            style: const TextStyle(
              color: CohabiColors.navy,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: Text(
              subtitle!,
              textAlign: textAlign,
              style: const TextStyle(
                color: CohabiColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
