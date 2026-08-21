import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cohabi_card.dart';

class ActiveModeCard extends StatelessWidget {
  final String activeMode;
  final String secondaryText;

  const ActiveModeCard({
    super.key,
    required this.activeMode,
    required this.secondaryText,
  });

  bool get _isTenant => activeMode == 'tenant';

  @override
  Widget build(BuildContext context) {
    final modeColor = _isTenant ? CohabiColors.purple : CohabiColors.turquoise;
    final softColor = _isTenant ? CohabiColors.purpleSoft : CohabiColors.turquoiseSoft;
    final icon = _isTenant ? Icons.person_outline_rounded : Icons.home_outlined;
    final title = _isTenant ? 'Inquilino activo' : 'Propietario activo';

    return CohabiCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: softColor, shape: BoxShape.circle),
            child: Icon(icon, color: modeColor, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Modo actual',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  secondaryText,
                  style: const TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: softColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: modeColor.withOpacity(0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: modeColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: modeColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
