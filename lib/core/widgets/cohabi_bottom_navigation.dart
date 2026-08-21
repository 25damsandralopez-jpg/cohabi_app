import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CohabiBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CohabiNavItem> items;

  const CohabiBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      CohabiNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Inicio'),
      CohabiNavItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome_rounded, label: 'Selección'),
      CohabiNavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Solicitudes'),
      CohabiNavItem(icon: Icons.house_outlined, activeIcon: Icons.house_rounded, label: 'Mi Casa'),
      CohabiNavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Cuenta'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: Colors.white,
      indicatorColor: CohabiColors.purpleSoft,
      destinations: items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon, color: CohabiColors.textSecondary),
              selectedIcon: Icon(item.activeIcon, color: CohabiColors.purple),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

class CohabiNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const CohabiNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
