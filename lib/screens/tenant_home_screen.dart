import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/navigation/tenant_navigation.dart';
import '../core/widgets/tenant_bottom_navigation.dart';
import '../features/notifications/screens/notifications_screen.dart';

class TenantHomeScreen extends StatelessWidget {
  const TenantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  20,
                  18,
                  28,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    // ================================================
                    // CABECERA
                    // ================================================

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Hola 👋',
                                style: TextStyle(
                                  color:
                                  CohabiColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Encuentra tu próximo hogar',
                                style: TextStyle(
                                  color:
                                  CohabiColors.navy,
                                  fontSize: 25,
                                  height: 1.15,
                                  fontWeight:
                                  FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CohabiColors.border,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                            ),
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: CohabiColors.navy,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // ================================================
                    // COHABI SELECCIÓN
                    // ================================================

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient:
                        CohabiColors.primaryGradient,
                        borderRadius:
                        BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 33,
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'Cohabi Selección',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Descubre viviendas y compañeros que encajan contigo.',
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.90),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 20),

                          InkWell(
                            onTap: () {
                              // Aquí conectaremos:
                              // TenantSelectionScreen()
                            },
                            borderRadius:
                            BorderRadius.circular(14),
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 17,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(
                                  14,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize:
                                MainAxisSize.min,
                                children: [
                                  Text(
                                    'Ver mi selección',
                                    style: TextStyle(
                                      color:
                                      CohabiColors.purple,
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons
                                        .arrow_forward_rounded,
                                    color:
                                    CohabiColors.purple,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ================================================
                    // TU BÚSQUEDA
                    // ================================================

                    const Text(
                      'Tu búsqueda',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(20),
                        border: Border.all(
                          color: CohabiColors.border,
                        ),
                      ),
                      child: const Row(
                        children: [
                          _HomeInfoIcon(
                            icon:
                            Icons.location_on_outlined,
                            color:
                            CohabiColors.turquoise,
                          ),

                          SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Zona de búsqueda',
                                  style: TextStyle(
                                    color:
                                    CohabiColors
                                        .textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Configura tu zona',
                                  style: TextStyle(
                                    color:
                                    CohabiColors.navy,
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Icon(
                            Icons.chevron_right_rounded,
                            color:
                            CohabiColors.textSecondary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ================================================
                    // ACCESOS RÁPIDOS
                    // ================================================

                    const Text(
                      'Accesos rápidos',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon:
                            Icons.assignment_outlined,
                            title: 'Solicitudes',
                            subtitle:
                            'Revisa tus solicitudes',
                            color:
                            CohabiColors.purple,
                            onTap: () {
                              // TenantApplicationsScreen()
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _QuickActionCard(
                            icon:
                            Icons.home_work_outlined,
                            title: 'Mi Casa',
                            subtitle:
                            'Tu estancia activa',
                            color:
                            CohabiColors.turquoise,
                            onTap: () {
                              // TenantMyHomeScreen()
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ================================================
            // NAVEGACIÓN
            // ================================================

            TenantBottomNavigation(
              currentIndex: 0,
              onTap: (index) {
                if (index == 0) return;
                handleTenantNavigation(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// ICONO DE INFORMACIÓN
// ============================================================

class _HomeInfoIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _HomeInfoIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 27,
      ),
    );
  }
}


// ============================================================
// ACCESO RÁPIDO
// ============================================================

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: CohabiColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: const TextStyle(
                color: CohabiColors.navy,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: const TextStyle(
                color:
                CohabiColors.textSecondary,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
