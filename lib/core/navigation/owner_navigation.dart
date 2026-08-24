import 'package:flutter/material.dart';

import '../../features/owner_applications/screens/owner_applications_screen.dart';
import '../../features/owner_applications/screens/owner_visits_screen.dart';
import '../../screens/account_screen.dart';
import '../../screens/properties_dashboard_screen.dart';

void handleOwnerNavigation(BuildContext context, int index) {
  Widget screen;
  switch (index) {
    case 0:
    case 1:
      screen = const PropertiesDashboardScreen();
      break;
    case 2:
      screen = const OwnerApplicationsScreen();
      break;
    case 3:
      screen = const OwnerVisitsScreen();
      break;
    case 4:
      screen = const AccountScreen();
      break;
    default:
      return;
  }
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => screen),
    (_) => false,
  );
}
