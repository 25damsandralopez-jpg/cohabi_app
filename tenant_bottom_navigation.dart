import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TenantBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TenantBottomNavigation({
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
        indicatorColor: CohabiColors.purpleSoft,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? CohabiColors.purple : CohabiColors.textSecondary,
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
            icon: Icon(Icons.home_outlined, color: CohabiColors.textSecondary),
            selectedIcon: Icon(Icons.home_rounded, color: CohabiColors.purple),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined, color: CohabiColors.textSecondary),
            selectedIcon: Icon(Icons.auto_awesome_rounded, color: CohabiColors.purple),
            label: 'Selección',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined, color: CohabiColors.textSecondary),
            selectedIcon: Icon(Icons.assignment_rounded, color: CohabiColors.purple),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.house_outlined, color: CohabiColors.textSecondary),
            selectedIcon: Icon(Icons.house_rounded, color: CohabiColors.purple),
            label: 'Mi Casa',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: CohabiColors.textSecondary),
            selectedIcon: Icon(Icons.person_rounded, color: CohabiColors.purple),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}
