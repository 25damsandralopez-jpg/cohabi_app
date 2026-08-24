import 'package:flutter/material.dart';
import '../../../core/navigation/owner_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';

class OwnerIncidentsScreen extends StatelessWidget {
  const OwnerIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(
        backgroundColor: CohabiColors.background,
        elevation: 0,
        title: const Text('Incidencias', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900)),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'Módulo preparado para incidencias de mantenimiento, pagos y avisos de cada piso. Será el siguiente bloque operativo después del flujo de selección.',
            textAlign: TextAlign.center,
            style: TextStyle(color: CohabiColors.textSecondary, height: 1.45),
          ),
        ),
      ),
      bottomNavigationBar: OwnerBottomNavigation(currentIndex: 4, onTap: (i) => handleOwnerNavigation(context, i)),
    );
  }
}
