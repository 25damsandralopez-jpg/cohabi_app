import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'properties_dashboard_screen.dart';
import 'property_rooms_screen.dart';

class PropertyCompletedScreen extends StatelessWidget {
  final String propertyId;
  final int roomCount;
  final int roomIndex;

  const PropertyCompletedScreen({
    super.key,
    required this.propertyId,
    required this.roomCount,
    required this.roomIndex,
  });

  bool get _canAddMoreRooms => roomIndex + 1 < roomCount;

  int get _currentRoomNumber => roomIndex + 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // CABECERA
              // ==================================================
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: CohabiColors.navy,
                      size: 30,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: CohabiColors.navy,
                      size: 31,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // ==================================================
              // LOGO REAL DE COHABI
              // ==================================================
              _buildLogo(),

              const SizedBox(height: 26),

              // ==================================================
              // PASO 6 DE 6
              // ==================================================
              _buildStepIndicator(),

              const SizedBox(height: 30),

              // ==================================================
              // ILUSTRACIÓN REAL
              // ==================================================
              _buildSuccessIllustration(),

              const SizedBox(height: 18),

              const Text(
                '¡Enhorabuena!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Habitación $_currentRoomNumber creada',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CohabiColors.turquoise,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                _canAddMoreRooms
                    ? 'La habitación se ha guardado correctamente.\n'
                    '¿Qué quieres hacer ahora?'
                    : 'La habitación se ha guardado correctamente.\n'
                    'Ya has completado las $roomCount habitaciones del piso.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF53629B),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 32),

              // ==================================================
              // AÑADIR MÁS HABITACIONES
              // ==================================================
              if (_canAddMoreRooms)
                _buildActionCard(
                  icon: Icons.bed_outlined,
                  title: 'Añadir más habitaciones',
                  subtitle:
                  'Continúa añadiendo más habitaciones a este piso.',
                  onTap: () {
                    Navigator.push(                     context,
                      MaterialPageRoute(
                        builder: (context) => PropertyRoomsScreen(
                          propertyId: propertyId,
                          roomCount: roomCount,
                          initialRoomIndex: roomIndex + 1,
                        ),
                      ),
                    );
                  },
                )
              else
                _buildRoomsCompletedCard(),

              const SizedBox(height: 14),

              // ==================================================
              // CREAR MÁS PISOS
              // ==================================================
              _buildActionCard(
                icon: Icons.apartment_outlined,
                title: 'Crear más pisos',
                subtitle:
                'Añade otro piso y gestiona más propiedades.',
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const PropertiesDashboardScreen(),
                    ),
                        (route) => false,
                  );
                },
              ),

              const SizedBox(height: 18),

              // ==================================================
              // COHABI SELECCIÓN
              // ==================================================
              _buildSelectionCard(context),

              const SizedBox(height: 24),

              // ==================================================
              // VER MIS PISOS
              // ==================================================
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const PropertiesDashboardScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.home_outlined,
                    color: Color(0xFF6476C7),
                    size: 23,
                  ),
                  label: const Text(
                    'Ver mis pisos',
                    style: TextStyle(
                      color: Color(0xFF6476C7),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGO REAL
  // ============================================================

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/cohabi_logo.png',
          width: 165,
          height: 105,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 5),

        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Alquila con ',
                style: TextStyle(
                  color: CohabiColors.navy,
                ),
              ),
              TextSpan(
                text: 'confianza',
                style: TextStyle(
                  color: CohabiColors.turquoise,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ', gestiona con ',
                style: TextStyle(
                  color: CohabiColors.navy,
                ),
              ),
              TextSpan(
                text: 'facilidad.',
                style: TextStyle(
                  color: CohabiColors.purple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PASO 6 DE 6
  // ============================================================

  Widget _buildStepIndicator() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CohabiColors.turquoise.withOpacity(0.11),
                CohabiColors.purple.withOpacity(0.07),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Paso 6',
                  style: TextStyle(
                    color: CohabiColors.turquoise,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' de 6',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),

        const SizedBox(height: 17),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            6,
                (index) {
              final isLast = index == 5;

              return Container(
                width: isLast ? 22 : 42,
                height: isLast ? 22 : 5,
                margin: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: CohabiColors.turquoise,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isLast
                    ? Center(
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGEN DE CAMA + CHECK + CONFETI
  // ============================================================

  Widget _buildSuccessIllustration() {
    return Center(
      child: Image.asset(
        'assets/images/room_completed.png',
        width: 235,
        height: 235,
        fit: BoxFit.contain,
      ),
    );
  }

  // ============================================================
  // TARJETAS PRINCIPALES
  // ============================================================

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE3E6EE),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.018),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CohabiColors.turquoise.withOpacity(0.12),
                    CohabiColors.turquoise.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: CohabiColors.turquoise,
                size: 34,
              ),
            ),

            const SizedBox(width: 17),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF5968A2),
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.arrow_forward_rounded,
              color: CohabiColors.turquoise,
              size: 29,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TODAS LAS HABITACIONES COMPLETADAS
  // ============================================================

  Widget _buildRoomsCompletedCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: CohabiColors.turquoise.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CohabiColors.turquoise.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: CohabiColors.turquoise.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: CohabiColors.turquoise,
              size: 37,
            ),
          ),

          const SizedBox(width: 17),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Habitaciones completadas',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Has configurado las $roomCount habitaciones de este piso.',
                  style: const TextStyle(
                    color: Color(0xFF5968A2),
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COHABI SELECCIÓN
  // ============================================================

  Widget _buildSelectionCard(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cohabi Selección la conectaremos más adelante.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CohabiColors.purple.withOpacity(0.045),
              CohabiColors.purple.withOpacity(0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.78),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: CohabiColors.purple,
                size: 38,
              ),
            ),

            const SizedBox(width: 16),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 Encuentra al inquilino ideal',
                    style: TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Cuéntanos qué perfil buscas y deja que '
                        'Cohabi haga el resto. Nuestro sistema '
                        'filtrará y verificará a los candidatos.',
                    style: TextStyle(
                      color: Color(0xFF5968A2),
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 7),

            const Icon(
              Icons.arrow_forward_rounded,
              color: CohabiColors.purple,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}