import 'package:flutter/material.dart';

import '../../features/selection/screens/tenant_selection_gate_screen.dart';
import '../../screens/account_screen.dart';
import '../../screens/tenant_home_screen.dart';

void handleTenantNavigation(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TenantHomeScreen()),
        (_) => false,
      );
      return;
    case 1:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TenantSelectionGateScreen()),
        (_) => false,
      );
      return;
    case 2:
      _showComingSoon(context, 'Solicitudes');
      return;
    case 3:
      _showComingSoon(context, 'Mi Casa');
      return;
    case 4:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AccountScreen()),
        (_) => false,
      );
      return;
  }
}

void _showComingSoon(BuildContext context, String section) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$section estará disponible próximamente.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
