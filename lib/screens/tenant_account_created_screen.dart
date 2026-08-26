import 'package:flutter/material.dart';

import '../core/navigation/tenant_navigation.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/tenant_bottom_navigation.dart';
import '../features/selection/screens/tenant_selection_screen.dart';
import 'tenant_home_screen.dart';

class TenantAccountCreatedScreen extends StatelessWidget {
  const TenantAccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,

      // ============================================================
      // NAVEGACIÓN INFERIOR REAL DEL INQUILINO
      // ============================================================
      bottomNavigationBar: TenantBottomNavigation(
        currentIndex: 0,
        onTap: (index) => handleTenantNavigation(context, index),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ====================================================
              // HERO COMPLETO
              //
              // Esta imagen ya contiene:
              // - confeti
              // - check
              // - "¡Tu cuenta está lista!"
              // - "Bienvenido a Cohabi"
              // - texto introductorio
              // - fotografía del piso y las personas
              // - degradados
              // ====================================================

              SizedBox(
                width: double.infinity,
                height: 470,
                child: Image.asset(
                  'assets/images/tenant_success.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

              // ====================================================
              // TARJETA COHABI SELECCIÓN
              // ====================================================

              Transform.translate(
                offset: const Offset(0, -26),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    22,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: CohabiColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: CohabiColors.navy,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(
                              text: 'Encuentra tu sitio con\n',
                            ),
                            TextSpan(
                              text: 'Cohabi ',
                              style: TextStyle(
                                color: CohabiColors.turquoise,
                              ),
                            ),
                            TextSpan(
                              text: 'Selección ✨',
                              style: TextStyle(
                                color: CohabiColors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 22),

                      _InfoRow(
                        icon: Icons.psychology_outlined,
                        iconColor: CohabiColors.turquoise,
                        iconBackground: Color(0xFFE7FAF8),
                        text:
                        'Analizamos tus preferencias y necesidades.',
                      ),

                      Divider(
                        height: 30,
                        color: CohabiColors.border,
                      ),

                      _InfoRow(
                        icon: Icons.home_outlined,
                        iconColor: CohabiColors.purple,
                        iconBackground: Color(0xFFF0E9FF),
                        text:
                        'Encontramos los pisos donde tu perfil tiene más posibilidades de encajar.',
                      ),

                      Divider(
                        height: 30,
                        color: CohabiColors.border,
                      ),

                      _InfoRow(
                        icon: Icons.groups_2_outlined,
                        iconColor: Color(0xFFFF8A00),
                        iconBackground: Color(0xFFFFF1DF),
                        text:
                        'Comparamos perfiles y estilos de convivencia para encontrar compañeros compatibles contigo.',
                        subtitle:
                        'Para ayudarte a encontrar un hogar donde te sientas cómodo y la convivencia funcione de verdad.',
                      ),
                    ],
                  ),
                ),
              ),

              // ====================================================
              // COMENZAR COHABI SELECCIÓN
              // ====================================================

              Transform.translate(
                offset: const Offset(0, -8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const TenantSelectionScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: CohabiColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Spacer(),

                          Text(
                            'Comenzar Cohabi Selección',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          Spacer(),

                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 28,
                          ),

                          SizedBox(width: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // ====================================================
              // AHORA NO, IR AL INICIO
              // ====================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const TenantHomeScreen(),
                        ),
                            (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CohabiColors.navy,
                      side: const BorderSide(
                        color: CohabiColors.border,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Ahora no, ir al inicio',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ====================================================
              // PRIVACIDAD
              // ====================================================

              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: CohabiColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.035),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color:
                        CohabiColors.purple.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: CohabiColors.purple,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tu información está segura',
                            style: TextStyle(
                              color: CohabiColors.navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'En Cohabi cuidamos tu privacidad y utilizamos tus datos solo para mejorar tu experiencia.',
                            style: TextStyle(
                              color:
                              CohabiColors.textSecondary,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Icon(
                      Icons.chevron_right_rounded,
                      color: CohabiColors.purple,
                      size: 27,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// FILA DE INFORMACIÓN
// ================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String text;
  final String? subtitle;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.text,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 27,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 5),

                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}