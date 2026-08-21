import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class TipsCard extends StatelessWidget {
  final String title;
  final List<String> tips;
  final IconData icon;

  const TipsCard({
    super.key,
    this.title = 'Consejos',
    required this.tips,
    this.icon = Icons.lightbulb_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CohabiColors.turquoiseSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: CohabiColors.turquoise),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: CohabiColors.turquoise)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
