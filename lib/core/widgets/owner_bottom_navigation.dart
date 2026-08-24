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

  static const _items = <_OwnerNavItem>[
    _OwnerNavItem('Inicio', Icons.home_outlined, Icons.home_rounded),
    _OwnerNavItem('Pisos', Icons.apartment_outlined, Icons.apartment_rounded),
    _OwnerNavItem('Selección', Icons.person_add_alt_1_outlined, Icons.person_add_alt_1_rounded),
    _OwnerNavItem('Inquilinos', Icons.people_outline_rounded, Icons.people_rounded),
    _OwnerNavItem('Incidencias', Icons.handyman_outlined, Icons.handyman_rounded),
    _OwnerNavItem('Rentabilidad', Icons.bar_chart_outlined, Icons.bar_chart_rounded),
    _OwnerNavItem('Cuenta', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 74,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: CohabiColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D071747),
              blurRadius: 18,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 38,
                        height: 32,
                        decoration: BoxDecoration(
                          color: selected
                              ? CohabiColors.purpleSoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          selected ? item.selectedIcon : item.icon,
                          size: 21,
                          color: selected
                              ? CohabiColors.purple
                              : CohabiColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          style: TextStyle(
                            color: selected
                                ? CohabiColors.purple
                                : CohabiColors.textSecondary,
                            fontSize: 9.5,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _OwnerNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _OwnerNavItem(this.label, this.icon, this.selectedIcon);
}
