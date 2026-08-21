import 'package:flutter/material.dart';
import 'property_register_screen.dart';

import '../core/theme/app_colors.dart';

class OwnerAccountCreatedScreen extends StatelessWidget {
  const OwnerAccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 22),

              // LOGO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 90),
                child: Image.asset(
                  'assets/images/cohabi_logo.png',
                  width: 190,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 8),

              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(text: 'Alquila con '),
                    TextSpan(
                      text: 'confianza',
                      style: TextStyle(
                        color: CohabiColors.turquoise,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ', gestiona con '),
                    TextSpan(
                      text: 'facilidad.',
                      style: TextStyle(
                        color: CohabiColors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ONDA SUAVE
              Container(
                height: 32,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF3F5F9),
                      CohabiColors.background,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // ILUSTRACIÓN CENTRAL
              Padding(
                padding: EdgeInsets.zero,
                child: Image.asset(
                  'assets/images/owner_welcome.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                '¡Bienvenido a Cohabi!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Tu cuenta como propietario\nya está lista.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 17,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // TARJETA
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: CohabiColors.turquoiseSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.home_outlined,
                        size: 36,
                        color: CohabiColors.turquoise,
                      ),
                    ),

                    const SizedBox(width: 18),

                    Container(
                      width: 1,
                      height: 75,
                      color: CohabiColors.border,
                    ),

                    const SizedBox(width: 18),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Quieres añadir tu\nprimer piso ahora?',
                            style: TextStyle(
                              color: CohabiColors.navy,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Añade tu piso y comienza a recibir inquilinos compatibles.',
                            style: TextStyle(
                              color: CohabiColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // BOTÓN PRINCIPAL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: CohabiColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PropertyRegisterScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Spacer(),
                            Text(
                              'Añadir mi primer piso',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextButton(
                onPressed: () {
                  debugPrint('Lo haré más tarde');
                },
                child: const Text(
                  'Lo haré más tarde',
                  style: TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}