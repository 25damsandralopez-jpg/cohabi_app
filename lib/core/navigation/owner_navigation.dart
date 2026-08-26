import 'package:flutter/material.dart';

import '../../features/owner_home/screens/owner_home_screen.dart';
import '../../features/owner_incidents/screens/owner_incidents_screen.dart';
import '../../features/owner_profitability/screens/owner_profitability_screen.dart';
import '../../features/owner_tenants/screens/owner_tenants_screen.dart';

import '../../screens/account_screen.dart';
import '../../screens/properties_dashboard_screen.dart';
import '../../screens/owner_selection_waiting_screen.dart';

void handleOwnerNavigation(BuildContext context, int index) {
  final Widget screen;

  switch (index) {
  // ============================================================
  // 0. INICIO
  // ============================================================
    case 0:
      screen = const OwnerHomeScreen();
      break;

  // ============================================================
  // 1. MIS PROPIEDADES
  // ============================================================
    case 1:
      screen = const PropertiesDashboardScreen();
      break;

  // ============================================================
  // 2. COHABI SELECCIÓN
  // ============================================================
    case 2:
      screen = const OwnerSelectionWaitingScreen();
      break;

  // ============================================================
  // 3. INQUILINOS
  // ============================================================
    case 3:
      screen = const OwnerTenantsScreen();
      break;

  // ============================================================
  // 4. INCIDENCIAS
  // ============================================================
    case 4:
      screen = const OwnerIncidentsScreen();
      break;

  // ============================================================
  // 5. RENTABILIDAD
  // ============================================================
    case 5:
      screen = const OwnerProfitabilityScreen();
      break;

  // ============================================================
  // 6. MI CUENTA
  // ============================================================
    case 6:
      screen = const AccountScreen();
      break;

    default:
      screen = const OwnerHomeScreen();
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => screen,
    ),
        (_) => false,
  );
}