import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cohabi_card.dart';

class AccountProfilesCard extends StatelessWidget {
  final bool hasTenantProfile;
  final bool hasOwnerProfile;
  final VoidCallback onTenantTap;
  final VoidCallback onOwnerTap;

  const AccountProfilesCard({
    super.key,
    required this.hasTenantProfile,
    required this.hasOwnerProfile,
    required this.onTenantTap,
    required this.onOwnerTap,
  });

  @override
  Widget build(BuildContext context) {
    return CohabiCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tus perfiles',
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _ProfileRow(
            title: 'Perfil de inquilino',
            icon: Icons.person_outline_rounded,
            exists: hasTenantProfile,
            onTap: onTenantTap,
          ),
          const Divider(height: 1, color: CohabiColors.border),
          _ProfileRow(
            title: 'Perfil de propietario',
            icon: Icons.home_outlined,
            exists: hasOwnerProfile,
            onTap: onOwnerTap,
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool exists;
  final VoidCallback onTap;

  const _ProfileRow({
    required this.title,
    required this.icon,
    required this.exists,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: CohabiColors.purpleSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: CohabiColors.purple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: exists ? CohabiColors.turquoiseSoft : CohabiColors.purpleSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    exists ? Icons.check_circle_rounded : Icons.schedule_rounded,
                    color: exists ? CohabiColors.turquoise : CohabiColors.purple,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    exists ? 'Activo' : 'Pendiente',
                    style: TextStyle(
                      color: exists ? CohabiColors.turquoise : CohabiColors.purple,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: CohabiColors.textMuted),
          ],
        ),
      ),
    );
  }
}
