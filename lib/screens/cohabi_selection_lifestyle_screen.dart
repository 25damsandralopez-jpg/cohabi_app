import 'package:flutter/material.dart';
import 'cohabi_selection_values_screen.dart';



class CohabiSelectionLifestyleScreen extends StatefulWidget {
  final List<String> propertyIds;
  final Map<String, dynamic> requirements;

  const CohabiSelectionLifestyleScreen({
    super.key,
    required this.propertyIds,
    required this.requirements,
  });

  @override
  State<CohabiSelectionLifestyleScreen> createState() =>
      _CohabiSelectionLifestyleScreenState();
}

class _CohabiSelectionLifestyleScreenState
    extends State<CohabiSelectionLifestyleScreen> {
  static const Color navy = Color(0xFF071747);
  static const Color turquoise = Color(0xFF10B9B4);
  static const Color purple = Color(0xFF7439F5);
  static const Color background = Color(0xFFFBFBFE);
  static const Color border = Color(0xFFE8EAF2);
  static const Color textSecondary = Color(0xFF66729A);

  String homeAtmosphere = 'Equilibrado';
  String currentResidents = 'Jóvenes trabajadores';
  String schedule = 'Indiferentes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  26,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(),

                    const SizedBox(height: 20),

                    _buildProgress(),

                    const SizedBox(height: 32),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: _stepPill(),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Perfil de convivencia',
                      style: TextStyle(
                        color: navy,
                        fontSize: 30,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),

                    const SizedBox(height: 18),

                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text:
                            'Cuéntanos cómo es el ambiente de este piso para '
                                'encontrar a los inquilinos que ',
                          ),
                          TextSpan(
                            text: 'mejor encajen.',
                            style: TextStyle(
                              color: purple,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // =================================================
                    // 1. AMBIENTE
                    // =================================================

                    _sectionCard(
                      title: '1. ¿Cómo describirías este piso?',
                      subtitle:
                      'Elige la opción que mejor represente el ambiente general.',
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _optionCard(
                              icon: Icons.eco_outlined,
                              iconColor: turquoise,
                              label: 'Muy\ntranquilo',
                              selected:
                              homeAtmosphere == 'Muy tranquilo',
                              onTap: () {
                                setState(() {
                                  homeAtmosphere = 'Muy tranquilo';
                                });
                              },
                            ),

                            const SizedBox(width: 8),

                            _optionCard(
                              icon: Icons.local_cafe_outlined,
                              iconColor: const Color(0xFF6FB7FF),
                              label: 'Tranquilo',
                              selected:
                              homeAtmosphere == 'Tranquilo',
                              onTap: () {
                                setState(() {
                                  homeAtmosphere = 'Tranquilo';
                                });
                              },
                            ),

                            const SizedBox(width: 8),

                            _optionCard(
                              icon: Icons.balance_outlined,
                              iconColor: const Color(0xFFFFAE35),
                              label: 'Equilibrado',
                              selected:
                              homeAtmosphere == 'Equilibrado',
                              onTap: () {
                                setState(() {
                                  homeAtmosphere = 'Equilibrado';
                                });
                              },
                            ),

                            const SizedBox(width: 8),

                            _optionCard(
                              icon: Icons.groups_2_outlined,
                              iconColor: const Color(0xFFF173BF),
                              label: 'Sociable',
                              selected:
                              homeAtmosphere == 'Sociable',
                              onTap: () {
                                setState(() {
                                  homeAtmosphere = 'Sociable';
                                });
                              },
                            ),

                            const SizedBox(width: 8),

                            _optionCard(
                              icon: Icons.celebration_outlined,
                              iconColor: purple,
                              label: 'Muy\nsociable',
                              selected:
                              homeAtmosphere == 'Muy sociable',
                              onTap: () {
                                setState(() {
                                  homeAtmosphere = 'Muy sociable';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // 2. QUIÉNES VIVEN
                    // =================================================

                    _sectionCard(
                      title: '2. Actualmente viven...',
                      subtitle:
                      '¿Quiénes forman parte del piso en este momento?',
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _optionCard(
                              icon: Icons.school_outlined,
                              iconColor: purple,
                              label: 'Estudiantes',
                              selected:
                              currentResidents == 'Estudiantes',
                              onTap: () {
                                setState(() {
                                  currentResidents = 'Estudiantes';
                                });
                              },
                            ),

                            const SizedBox(width: 8),

                            _optionCard(
                              icon: Icons.business_center_outlined,
                              iconColor: purple,
                              label: 'Jóvenes\ntrabajadores',
                              selected:
                              currentResidents ==
                                  'Jóvenes trabajadores',
                              onTap: () {
                                setState(() {
                                  currentResidents =
                                  'Jóvenes trabajadores';
                                });
                              },
                            ),

                            const SizedBox(width: 8),

                            _optionCard(
                              icon: Icons.person_outline_rounded,
                              iconColor: purple,
                              label: 'Profesionales',
                              selected:
                              currentResidents == 'Profesionales',
                              onTap: () {
                                setState(() {
                                  currentResidents = 'Profesionales';
                                });
                              },
                            ),

                            const SizedBox(width: 8),

                            _optionCard(
                              icon: Icons.people_outline_rounded,
                              iconColor: purple,
                              label: 'Edades\nvariadas',
                              selected:
                              currentResidents == 'Edades variadas',
                              onTap: () {
                                setState(() {
                                  currentResidents = 'Edades variadas';
                                });
                              },
                            ),

                            const SizedBox(width: 8),

                            _optionCard(
                              icon: Icons.person_add_alt_outlined,
                              iconColor: purple,
                              label: '+ de 40 años',
                              selected:
                              currentResidents == '+ de 40 años',
                              onTap: () {
                                setState(() {
                                  currentResidents = '+ de 40 años';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // 3. HORARIOS
                    // =================================================

                    _sectionCard(
                      title: '3. Horarios habituales',
                      subtitle:
                      '¿Cómo son los horarios en el piso?',
                      child: Row(
                        children: [
                          Expanded(
                            child: _scheduleOption(
                              icon: Icons.light_mode_outlined,
                              iconColor: turquoise,
                              label: 'Diurnos',
                              selected: schedule == 'Diurnos',
                              onTap: () {
                                setState(() {
                                  schedule = 'Diurnos';
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 7),

                          Expanded(
                            child: _scheduleOption(
                              icon: Icons.dark_mode_outlined,
                              iconColor: purple,
                              label: 'Nocturnos',
                              selected: schedule == 'Nocturnos',
                              onTap: () {
                                setState(() {
                                  schedule = 'Nocturnos';
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 7),

                          Expanded(
                            child: _scheduleOption(
                              icon: Icons.schedule_outlined,
                              iconColor: const Color(0xFF747BA3),
                              label: 'Indiferentes',
                              selected: schedule == 'Indiferentes',
                              onTap: () {
                                setState(() {
                                  schedule = 'Indiferentes';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildInfoBox(),
                  ],
                ),
              ),
            ),

            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CABECERA
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        _circleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),

        const Spacer(),

        _circleButton(
          icon: Icons.help_outline_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Esta información nos ayuda a calcular la compatibilidad de convivencia.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: border,
          ),
        ),
        child: Icon(
          icon,
          color: navy,
          size: 22,
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESO
  // ============================================================

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 70,
      ),
      child: Row(
        children: [
          _progressSegment(turquoise),
          const SizedBox(width: 9),
          _progressSegment(turquoise),
          const SizedBox(width: 9),
          _progressSegment(purple),
          const SizedBox(width: 9),
          _progressSegment(
            const Color(0xFFE1E4ED),
          ),
        ],
      ),
    );
  }

  Widget _progressSegment(Color color) {
    return Expanded(
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _stepPill() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECFF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text(
        'Paso 3 de 4',
        style: TextStyle(
          color: purple,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // SECCIONES
  // ============================================================

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            subtitle,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // TARJETAS DE OPCIONES
  // ============================================================

  Widget _optionCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 160,
        ),
        width: 92,
        height: 118,
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFBF9FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? purple
                : const Color(0xFFE1E4EC),
            width: selected ? 1.7 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: 30,
                  ),

                  const SizedBox(height: 13),

                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 11.5,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              const Positioned(
                top: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: purple,
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HORARIOS
  // ============================================================

  Widget _scheduleOption({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 160,
        ),
        height: 82,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFAF8FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? purple
                : const Color(0xFFE1E4EC),
            width: selected ? 1.7 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),

                    const SizedBox(height: 7),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (selected)
              const Positioned(
                top: 5,
                right: 5,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor: purple,
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFORMACIÓN
  // ============================================================

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: purple,
            size: 26,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'Esta información nos ayuda a encontrar personas con hábitos y estilo de vida compatibles con tu piso.',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTINUAR
  // ============================================================

  Widget _buildContinueButton() {
    return Container(
      color: background,
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        14,
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: _continue,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  turquoise,
                  Color(0xFF168FD9),
                  purple,
                ],
              ),
            ),
            child: const Row(
              children: [
                Spacer(),

                Text(
                  'Continuar',
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
                  size: 25,
                ),

                SizedBox(width: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _continue() {
    final lifestyle = <String, dynamic>{
      'home_atmosphere': homeAtmosphere,
      'current_residents': currentResidents,
      'schedule': schedule,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CohabiSelectionValuesScreen(
          propertyIds: widget.propertyIds,
          requirements: widget.requirements,
          lifestyle: lifestyle,
        ),
      ),
    );
  }
}