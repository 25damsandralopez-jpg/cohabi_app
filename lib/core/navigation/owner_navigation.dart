import 'package:flutter/material.dart';

import '../../screens/account_screen.dart';
import '../../screens/properties_dashboard_screen.dart';

void handleOwnerNavigation(BuildContext context, int index) {
  switch (index) {
    case 0:
    case 1:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PropertiesDashboardScreen()),
        (_) => false,
      );
      return;
    case 2:
      _showComingSoon(context, 'Solicitudes');
      return;
    case 3:
      _showComingSoon(context, 'Visitas');
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
