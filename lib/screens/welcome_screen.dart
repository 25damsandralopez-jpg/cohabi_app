import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'login_screen.dart';
import 'account_type_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // LOGO REAL DE COHABI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Image.asset(
                  'assets/images/cohabi_logo.png',
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 8),

              // ESLOGAN
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 17,
                    color: CohabiColors.navy,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(text: 'Encuentra '),
                    TextSpan(
                      text: 'a tu',
                      style: TextStyle(
                        color: CohabiColors.turquoise,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' inquilino ideal.'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // FOTO PRINCIPAL
              SizedBox(
                width: double.infinity,
                height: 300,
                child: Image.asset(
                  'assets/images/cohabi_home.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // TARJETA DE BENEFICIOS SUPERPUESTA SOBRE LA FOTO
              Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _BenefitItem(
                          icon: Icons.verified_user_outlined,
                          title: 'Confianza',
                          description:
                          'Elegimos al candidato ideal para un alquiler seguro y tranquilo.',
                          color: CohabiColors.turquoise,
                          background: CohabiColors.turquoiseSoft,
                        ),
                      ),

                      SizedBox(width: 8),

                      Expanded(
                        child: _BenefitItem(
                          icon: Icons.handshake_outlined,
                          title: 'Gestión',
                          description:
                          'Gestiona pisos, inquilinos e incidencias desde un único lugar.',
                          color: CohabiColors.purple,
                          background: CohabiColors.purpleSoft,
                        ),
                      ),

                      SizedBox(width: 8),

                      Expanded(
                        child: _BenefitItem(
                          icon: Icons.rocket_launch_outlined,
                          title: 'Optimiza',
                          description:
                          'Analiza el rendimiento de tus propiedades y maximiza beneficios.',
                          color: CohabiColors.orange,
                          background: CohabiColors.orangeSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // BOTÓN CREAR CUENTA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: CohabiColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountTypeScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Spacer(),
                            Text(
                              'Crear cuenta',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // BOTÓN INICIAR SESIÓN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CohabiColors.navy,
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: CohabiColors.navy,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // INFORMACIÓN INFERIOR
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _FooterItem(
                      icon: Icons.verified_user_outlined,
                      text: 'Perfiles verificados',
                    ),

                    Text(
                      '•',
                      style: TextStyle(
                        color: CohabiColors.turquoise,
                      ),
                    ),

                    _FooterItem(
                      text: 'Pago seguro',
                    ),

                    Text(
                      '•',
                      style: TextStyle(
                        color: CohabiColors.turquoise,
                      ),
                    ),

                    _FooterItem(
                      text: 'Comunidad segura',
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

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color background;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CohabiColors.navy,
            fontSize: 10.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _FooterItem extends StatelessWidget {
  final IconData? icon;
  final String text;

  const _FooterItem({
    this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 17,
            color: CohabiColors.turquoise,
          ),
          const SizedBox(width: 5),
        ],
        Text(
          text,
          style: const TextStyle(
            color: CohabiColors.navy,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}