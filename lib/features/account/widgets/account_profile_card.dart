import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cohabi_card.dart';

class AccountProfileCard extends StatelessWidget {
  final String fullName;
  final String email;
  final bool verified;
  final VoidCallback? onTap;

  const AccountProfileCard({
    super.key,
    required this.fullName,
    required this.email,
    this.verified = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CohabiCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              gradient: CohabiColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 45),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                if (verified) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: CohabiColors.turquoiseSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: CohabiColors.turquoise, size: 16),
                        SizedBox(width: 5),
                        Text(
                          'Perfil verificado',
                          style: TextStyle(
                            color: CohabiColors.turquoise,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right_rounded, color: CohabiColors.navy),
        ],
      ),
    );
  }
}
