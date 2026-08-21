import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'login_screen.dart';
import 'owner_register_screen.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: CohabiColors.navy,
                      size: 22,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 2),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 85),
                child: Image.asset(
                  'assets/images/cohabi_logo.png',
                  width: 210,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 16,
                      height: 1.45,
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
              ),

              const SizedBox(height: 34),

              Container(
                width: double.infinity,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF5F6FA),
                      CohabiColors.background,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Crear una cuenta',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Elige cómo quieres usar Cohabi',
                style: TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _AccountTypeCard(
                  icon: Icons.home_outlined,
                  title: 'Soy propietario',
                  description:
                  'Publica tus pisos, gestiona tus propiedades y encuentra al inquilino ideal.',
                  color: CohabiColors.turquoise,
                  background: CohabiColors.turquoiseSoft,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OwnerRegisterScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _AccountTypeCard(
                  icon: Icons.person_outline_rounded,
                  title: 'Soy inquilino',
                  description:
                  'Encuentra tu piso ideal y alquila de forma segura y sencilla.',
                  color: CohabiColors.purple,
                  background: CohabiColors.purpleSoft,
                  onTap: () {
                    debugPrint('Registro inquilino');
                  },
                ),
              ),

              const SizedBox(height: 34),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 42),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: CohabiColors.border,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'o',
                        style: TextStyle(
                          color: CohabiColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: CohabiColors.border,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                '¿Ya tienes cuenta?',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: 220,
                height: 54,
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
                    side: const BorderSide(
                      color: CohabiColors.purple,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: CohabiColors.purple,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 18),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: CohabiColors.purple,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.055),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 38,
                ),
              ),

              const SizedBox(width: 18),

              Container(
                width: 1,
                height: 82,
                color: CohabiColors.border,
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: const TextStyle(
                        color: CohabiColors.textSecondary,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}