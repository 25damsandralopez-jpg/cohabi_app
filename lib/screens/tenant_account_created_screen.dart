import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'tenant_home_screen.dart';

class TenantAccountCreatedScreen extends StatelessWidget {
  const TenantAccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ==================================================
                    // CONFETI + CHECK
                    // ==================================================

                    SizedBox(
                      height: 125,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Positioned(
                            left: 55,
                            top: 50,
                            child: _Confetti(
                              color: CohabiColors.turquoise,
                              angle: 0.5,
                            ),
                          ),
                          const Positioned(
                            left: 105,
                            top: 15,
                            child: _Confetti(
                              color: CohabiColors.purple,
                              angle: -0.4,
                            ),
                          ),
                          const Positioned(
                            right: 95,
                            top: 20,
                            child: _Confetti(
                              color: Color(0xFF4387E8),
                              angle: 0.8,
                            ),
                          ),
                          const Positioned(
                            right: 48,
                            top: 68,
                            child: _Confetti(
                              color: Color(0xFFFF8FAB),
                              angle: -0.5,
                            ),
                          ),
                          const Positioned(
                            left: 35,
                            top: 92,
                            child: _Confetti(
                              color: Color(0xFF4387E8),
                              angle: 0.3,
                            ),
                          ),
                          const Positioned(
                            right: 145,
                            top: 88,
                            child: _Confetti(
                              color: CohabiColors.turquoise,
                              angle: -0.8,
                            ),
                          ),

                          Container(
                            width: 105,
                            height: 105,
                            decoration: BoxDecoration(
                              color:
                              CohabiColors.turquoise.withOpacity(0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                CohabiColors.turquoise.withOpacity(0.25),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  CohabiColors.turquoise.withOpacity(0.16),
                                  blurRadius: 24,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: CohabiColors.turquoise,
                              size: 62,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ==================================================
                    // TITULO
                    // ==================================================

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '¡Tu cuenta está lista! 🎉',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CohabiColors.navy,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: CohabiColors.navy,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: 'Bienvenido a ',
                          ),
                          TextSpan(
                            text: 'Cohabi',
                            style: TextStyle(
                              color: CohabiColors.turquoise,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: CohabiColors.textSecondary,
                            fontSize: 16,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Ya formas parte de la comunidad.\n',
                            ),
                            TextSpan(
                              text:
                              'Ahora es el momento de encontrar ',
                            ),
                            TextSpan(
                              text: 'tu lugar ideal.',
                              style: TextStyle(
                                color: CohabiColors.turquoise,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // IMAGEN PRINCIPAL
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 285,
                      child: Image.asset(
                        'assets/images/tenant_success.png',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // ==================================================
                    // TARJETA COHABI SELECCIÓN
                    // ==================================================

                    Transform.translate(
                      offset: const Offset(0, -28),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text.rich(
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

                            const SizedBox(height: 22),

                            const _InfoRow(
                              icon: Icons.psychology_outlined,
                              iconColor: CohabiColors.turquoise,
                              iconBackground: Color(0xFFE7FAF8),
                              text:
                              'Analizamos tus preferencias y necesidades.',
                            ),

                            const Divider(
                              height: 30,
                              color: CohabiColors.border,
                            ),

                            const _InfoRow(
                              icon: Icons.home_outlined,
                              iconColor: CohabiColors.purple,
                              iconBackground: Color(0xFFF0E9FF),
                              text:
                              'Encontramos los pisos donde tu perfil tiene más posibilidades de encajar.',
                            ),

                            const Divider(
                              height: 30,
                              color: CohabiColors.border,
                            ),

                            const _InfoRow(
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

                    // ==================================================
                    // BOTÓN COHABI SELECCIÓN
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      child: InkWell(
                        onTap: () {
                          // Próxima pantalla:
                          // TenantSelectionScreen()
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

                    const SizedBox(height: 14),

                    // ==================================================
                    // IR AL INICIO
                    // ==================================================

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
                                builder: (context) =>
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

                    // ==================================================
                    // PRIVACIDAD
                    // ==================================================

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

                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),

            // ==================================================
            // BARRA DE NAVEGACIÓN
            // ==================================================

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(
                    color: CohabiColors.border,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                top: 11,
                bottom: 8,
              ),
              child: const Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    text: 'Inicio',
                    selected: true,
                  ),
                  _NavItem(
                    icon: Icons.auto_awesome_outlined,
                    text: 'Selección',
                  ),
                  _NavItem(
                    icon: Icons.assignment_outlined,
                    text: 'Solicitudes',
                  ),
                  _NavItem(
                    icon: Icons.home_work_outlined,
                    text: 'Mi Casa',
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    text: 'Cuenta',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// FILA DE INFORMACIÓN
// ============================================================

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


// ============================================================
// NAVEGACIÓN INFERIOR
// ============================================================

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.text,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? CohabiColors.purple
        : CohabiColors.textSecondary;

    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 27,
          ),

          const SizedBox(height: 4),

          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// CONFETI
// ============================================================

class _Confetti extends StatelessWidget {
  final Color color;
  final double angle;

  const _Confetti({
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 9,
        height: 15,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}