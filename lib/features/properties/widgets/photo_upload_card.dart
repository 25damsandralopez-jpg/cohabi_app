import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cohabi_card.dart';

class PhotoUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? preview;

  const PhotoUploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return CohabiCard(
      onTap: onTap,
      withShadow: false,
      child: Row(
        children: [
          if (preview != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(width: 72, height: 72, child: preview),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CohabiColors.purpleSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: CohabiColors.purple,
            ),
          ),
        ],
      ),
    );
  }
}
