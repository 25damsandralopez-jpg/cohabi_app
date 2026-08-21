import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cohabi_card.dart';
import '../../../core/widgets/cohabi_primary_button.dart';

class ChangeModeCard extends StatelessWidget {
  final bool isTenant;
  final String description;
  final String buttonText;
  final String note;
  final bool isLoading;
  final VoidCallback onPressed;

  const ChangeModeCard({
    super.key,
    required this.isTenant,
    required this.description,
    required this.buttonText,
    required this.note,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CohabiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cambiar de modo',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        color: CohabiColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: CohabiColors.purpleSoft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  isTenant ? Icons.home_work_outlined : Icons.search_rounded,
                  color: CohabiColors.purple,
                  size: 38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CohabiPrimaryButton(
            text: buttonText,
            isLoading: isLoading,
            onPressed: isLoading ? null : onPressed,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: CohabiColors.turquoise,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note,
                  style: const TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
