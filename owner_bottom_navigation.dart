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

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: CohabiColors.turquoiseSoft,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? CohabiColors.turquoise : CohabiColors.textSecondary,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: CohabiColors.textSecondary),
            selectedIcon: Icon(Icons.dashboard_rounded, color: CohabiColors.turquoise),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined, color: CohabiColors.textSecondary),
            selectedIcon: Icon(Icons.apartment_rounded, color: CohabiColors.turquoise),
            label: 'Propiedades',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined, color: CohabiColors.textSecondary),
            selectedIcon: Icon(Icons.assignment_rounded, color: CohabiColors.turquoise),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined, color: CohabiColors.textSecondary),
            selectedIcon: Icon(Icons.event_available_rounded, color: CohabiColors.turquoise),
            label: 'Visitas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: CohabiColors.textSecondary),
            selectedIcon: Icon(Icons.person_rounded, color: CohabiColors.turquoise),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}
