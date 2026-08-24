import 'package:flutter/material.dart';

import '../../features/owner_applications/screens/owner_applications_screen.dart';
import '../../features/owner_home/screens/owner_home_screen.dart';
import '../../features/owner_incidents/screens/owner_incidents_screen.dart';
import '../../features/owner_profitability/screens/owner_profitability_screen.dart';
import '../../features/owner_tenants/screens/owner_tenants_screen.dart';
import '../../screens/account_screen.dart';
import '../../screens/properties_dashboard_screen.dart';

void handleOwnerNavigation(BuildContext context, int index) {
  final Widget screen;

  switch (index) {
    case 0:
      screen = const OwnerHomeScreen();
      break;
    case 1:
      screen = const PropertiesDashboardScreen();
      break;
    case 2:
      screen = const OwnerApplicationsScreen();
      break;
    case 3:
      screen = const OwnerTenantsScreen();
      break;
    case 4:
      screen = const OwnerIncidentsScreen();
      break;
    case 5:
      screen = const OwnerProfitabilityScreen();
      break;
    case 6:
      screen = const AccountScreen();
      break;
    default:
      screen = const OwnerHomeScreen();
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => screen),
    (_) => false,
  );
}
