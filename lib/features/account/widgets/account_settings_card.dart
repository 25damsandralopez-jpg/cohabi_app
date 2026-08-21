import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cohabi_card.dart';

class AccountSettingsCard extends StatelessWidget {
  final VoidCallback? onPersonalData;
  final VoidCallback? onPrivacy;
  final VoidCallback? onNotifications;
  final VoidCallback? onLanguage;
  final VoidCallback onLogout;

  const AccountSettingsCard({
    super.key,
    this.onPersonalData,
    this.onPrivacy,
    this.onNotifications,
    this.onLanguage,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return CohabiCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _SettingsRow(icon: Icons.person_outline_rounded, title: 'Datos personales', onTap: onPersonalData),
          const Divider(height: 1, color: CohabiColors.border),
          _SettingsRow(icon: Icons.shield_outlined, title: 'Privacidad', onTap: onPrivacy),
          const Divider(height: 1, color: CohabiColors.border),
          _SettingsRow(icon: Icons.notifications_none_rounded, title: 'Notificaciones', onTap: onNotifications),
          const Divider(height: 1, color: CohabiColors.border),
          _SettingsRow(icon: Icons.language_rounded, title: 'Idioma', onTap: onLanguage),
          const Divider(height: 1, color: CohabiColors.border),
          _SettingsRow(icon: Icons.logout_rounded, title: 'Cerrar sesión', onTap: onLogout),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _SettingsRow({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: CohabiColors.purpleSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: CohabiColors.purple, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: CohabiColors.textMuted),
          ],
        ),
      ),
    );
  }
}
