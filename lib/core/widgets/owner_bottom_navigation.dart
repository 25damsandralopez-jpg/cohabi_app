import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class OwnerBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const OwnerBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  void _openManagementMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              14,
              0,
              14,
              14,
            ),
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              18,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: CohabiColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.10,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // INDICADOR SUPERIOR
                // ==================================================

                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDADDEA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                const SizedBox(height: 18),

                const Row(
                  children: [
                    Text(
                      'Gestión',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Gestiona el día a día de tus propiedades.',
                    style: TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // INQUILINOS
                // ==================================================

                _ManagementOption(
                  icon: Icons.people_outline_rounded,
                  title: 'Inquilinos',
                  subtitle: 'Personas que viven en tus propiedades',
                  iconBackground: const Color(0xFFF3EEFF),
                  iconColor: CohabiColors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    onTap(3);
                  },
                ),

                const SizedBox(height: 10),

                // ==================================================
                // INCIDENCIAS
                // ==================================================

                _ManagementOption(
                  icon: Icons.build_outlined,
                  title: 'Incidencias',
                  subtitle: 'Revisa y gestiona problemas pendientes',
                  iconBackground: const Color(0xFFFFF1F1),
                  iconColor: const Color(0xFFFF6464),
                  onTap: () {
                    Navigator.pop(context);
                    onTap(4);
                  },
                ),

                const SizedBox(height: 10),

                // ==================================================
                // RENTABILIDAD
                // ==================================================

                _ManagementOption(
                  icon: Icons.bar_chart_rounded,
                  title: 'Rentabilidad',
                  subtitle: 'Ingresos, gastos y rendimiento',
                  iconBackground: const Color(0xFFFFF4E8),
                  iconColor: const Color(0xFFFF951F),
                  onTap: () {
                    Navigator.pop(context);
                    onTap(5);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: CohabiColors.turquoiseSoft,
        labelTextStyle:
        WidgetStateProperty.resolveWith<TextStyle>(
              (states) {
            final selected =
            states.contains(WidgetState.selected);

            return TextStyle(
              color: selected
                  ? CohabiColors.turquoise
                  : CohabiColors.textSecondary,
              fontSize: 11,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            );
          },
        ),
      ),
      child: NavigationBar(
        selectedIndex:
        currentIndex <= 3 ? currentIndex : 3,
        onDestinationSelected: (index) {
          if (index == 3) {
            _openManagementMenu(context);
            return;
          }

          onTap(index);
        },
        destinations: const [
          // ==========================================================
          // 0 - INICIO
          // ==========================================================

          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
              color: CohabiColors.textSecondary,
            ),
            selectedIcon: Icon(
              Icons.dashboard_rounded,
              color: CohabiColors.turquoise,
            ),
            label: 'Inicio',
          ),

          // ==========================================================
          // 1 - PROPIEDADES
          // ==========================================================

          NavigationDestination(
            icon: Icon(
              Icons.apartment_outlined,
              color: CohabiColors.textSecondary,
            ),
            selectedIcon: Icon(
              Icons.apartment_rounded,
              color: CohabiColors.turquoise,
            ),
            label: 'Propiedades',
          ),

          // ==========================================================
          // 2 - SELECCIÓN
          // ==========================================================

          NavigationDestination(
            icon: Icon(
              Icons.auto_awesome_outlined,
              color: CohabiColors.textSecondary,
            ),
            selectedIcon: Icon(
              Icons.auto_awesome_rounded,
              color: CohabiColors.turquoise,
            ),
            label: 'Selección',
          ),

          // ==========================================================
          // 3 - GESTIÓN
          // ==========================================================

          NavigationDestination(
            icon: Icon(
              Icons.dashboard_customize_outlined,
              color: CohabiColors.textSecondary,
            ),
            selectedIcon: Icon(
              Icons.dashboard_customize_rounded,
              color: CohabiColors.turquoise,
            ),
            label: 'Gestión',
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// OPCIÓN DEL MENÚ DE GESTIÓN
// ===================================================================

class _ManagementOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback onTap;

  const _ManagementOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFBFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: CohabiColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: CohabiColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              const Icon(
                Icons.chevron_right_rounded,
                color: CohabiColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}