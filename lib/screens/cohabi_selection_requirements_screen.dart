import 'package:flutter/material.dart';
import 'cohabi_selection_lifestyle_screen.dart';

class CohabiSelectionRequirementsScreen extends StatefulWidget {
  final List<String> propertyIds;

  const CohabiSelectionRequirementsScreen({
    super.key,
    required this.propertyIds,
  });

  @override
  State<CohabiSelectionRequirementsScreen> createState() =>
      _CohabiSelectionRequirementsScreenState();
}

class _CohabiSelectionRequirementsScreenState
    extends State<CohabiSelectionRequirementsScreen> {
  static const Color navy = Color(0xFF071747);
  static const Color turquoise = Color(0xFF10B9B4);
  static const Color purple = Color(0xFF7439F5);
  static const Color orange = Color(0xFFFF6A21);
  static const Color background = Color(0xFFFBFBFE);
  static const Color border = Color(0xFFE9EBF2);
  static const Color textSecondary = Color(0xFF66729A);

  bool smokersAllowed = false;
  bool petsAllowed = false;
  bool guarantorAllowed = true;

  bool visitsAllowed = true;
  bool sleepoversAllowed = true;

  bool minorsAllowed = false;

  String minimumStay = '6 meses';
  String minimumIncome = '1.500 €';
  String maxNights = '4 noches';

  final List<String> stayOptions = [
    '1 mes',
    '3 meses',
    '6 meses',
    '9 meses',
    '12 meses',
    '24 meses',
  ];

  final List<String> incomeOptions = [
    '1.000 €',
    '1.200 €',
    '1.500 €',
    '1.800 €',
    '2.000 €',
    '2.500 €',
    '3.000 €',
  ];

  final List<String> nightsOptions = [
    '1 noche',
    '2 noches',
    '3 noches',
    '4 noches',
    '5 noches',
    '6 noches',
    '8 noches',
    'Sin límite',
  ];

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
                  22,
                  18,
                  22,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(),

                    const SizedBox(height: 22),

                    _buildProgress(),

                    const SizedBox(height: 38),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: _stepPill(),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Requisitos imprescindibles',
                      style: TextStyle(
                        color: navy,
                        fontSize: 31,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 16,
                          height: 1.55,
                        ),
                        children: [
                          TextSpan(
                            text: 'Define las ',
                          ),
                          TextSpan(
                            text: 'condiciones mínimas',
                            style: TextStyle(
                              color: purple,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text:
                            ' que deben cumplir\nlos candidatos para que los tengas en cuenta.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    _yesNoCard(
                      icon: Icons.smoke_free_rounded,
                      iconColor: turquoise,
                      title: 'Fumadores',
                      subtitle: '¿Se permiten fumadores?',
                      value: smokersAllowed,
                      onChanged: (value) {
                        setState(() {
                          smokersAllowed = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    _yesNoCard(
                      icon: Icons.pets_rounded,
                      iconColor: purple,
                      title: 'Mascotas',
                      subtitle: '¿Se permiten mascotas?',
                      value: petsAllowed,
                      onChanged: (value) {
                        setState(() {
                          petsAllowed = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    _dropdownCard(
                      icon: Icons.calendar_month_outlined,
                      iconColor: turquoise,
                      title: 'Duración mínima de la estancia',
                      value: minimumStay,
                      options: stayOptions,
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          minimumStay = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    _incomeCard(),

                    const SizedBox(height: 14),

                    _visitsCard(),

                    const SizedBox(height: 14),

                    _yesNoCard(
                      icon: Icons.child_care_rounded,
                      iconColor: turquoise,
                      title: 'Menores de edad',
                      subtitle: '¿Se permiten menores\nde edad?',
                      value: minorsAllowed,
                      onChanged: (value) {
                        setState(() {
                          minorsAllowed = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildInformationBox(),
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
        _roundButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),

        const Spacer(),

        _roundButton(
          icon: Icons.help_outline_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Estas condiciones funcionarán como filtros obligatorios.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
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
          size: 23,
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 78,
      ),
      child: Row(
        children: [
          _progressSegment(true),
          const SizedBox(width: 10),
          _progressSegment(true),
          const SizedBox(width: 10),
          _progressSegment(false),
          const SizedBox(width: 10),
          _progressSegment(false),
        ],
      ),
    );
  }

  Widget _progressSegment(bool active) {
    return Expanded(
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: active
              ? turquoise
              : const Color(0xFFE1E4ED),
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
        color: const Color(0xFFE7F9F8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text(
        'Paso 2 de 4',
        style: TextStyle(
          color: turquoise,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // TARJETAS
  // ============================================================

  Widget _baseCard({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBubble({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.09,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 29,
      ),
    );
  }

  Widget _yesNoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _baseCard(
      child: Row(
        children: [
          _iconBubble(
            icon: icon,
            color: iconColor,
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          _radioChoice(
            label: 'Sí',
            selected: value,
            color: iconColor,
            onTap: () => onChanged(true),
          ),

          const SizedBox(width: 20),

          _radioChoice(
            label: 'No',
            selected: !value,
            color: iconColor,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _radioChoice({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 3,
          vertical: 8,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration:
              const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? color
                      : const Color(0xFFD1D6E4),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),

            const SizedBox(width: 7),

            Text(
              label,
              style: const TextStyle(
                color: navy,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return _baseCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBubble(
            icon: icon,
            color: iconColor,
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 17,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: _dropdown(
                    value: value,
                    options: options,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD9DEEA),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: navy,
          ),
          style: const TextStyle(
            color: navy,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ============================================================
  // SOLVENCIA
  // ============================================================

  Widget _incomeCard() {
    return _baseCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBubble(
            icon: Icons.euro_rounded,
            color: purple,
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solvencia económica mínima',
                  style: TextStyle(
                    color: navy,
                    fontSize: 17,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: _dropdown(
                    value: minimumIncome,
                    options: incomeOptions,
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        minimumIncome = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 13),

                InkWell(
                  onTap: () {
                    setState(() {
                      guarantorAllowed = !guarantorAllowed;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 150,
                        ),
                        width: 21,
                        height: 21,
                        decoration: BoxDecoration(
                          color: guarantorAllowed
                              ? purple
                              : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: guarantorAllowed
                                ? purple
                                : const Color(0xFFD2D7E4),
                          ),
                        ),
                        child: guarantorAllowed
                            ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 15,
                        )
                            : null,
                      ),

                      const SizedBox(width: 8),

                      const Expanded(
                        child: Text(
                          'Aceptar avalista como alternativa',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
  // VISITAS
  // ============================================================

  Widget _visitsCard() {
    return _baseCard(
      child: Column(
        children: [
          Row(
            children: [
              _iconBubble(
                icon: Icons.people_outline_rounded,
                color: orange,
              ),

              const SizedBox(width: 18),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visitas',
                      style: TextStyle(
                        color: navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '¿Se permiten visitas?',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              _radioChoice(
                label: 'Sí',
                selected: visitsAllowed,
                color: orange,
                onTap: () {
                  setState(() {
                    visitsAllowed = true;
                  });
                },
              ),

              const SizedBox(width: 20),

              _radioChoice(
                label: 'No',
                selected: !visitsAllowed,
                color: orange,
                onTap: () {
                  setState(() {
                    visitsAllowed = false;
                  });
                },
              ),
            ],
          ),

          if (visitsAllowed) ...[
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ¿PUEDEN QUEDARSE A DORMIR?
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '¿Pueden quedarse a dormir?',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12.5,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      _radioChoice(
                        label: 'Sí',
                        selected: sleepoversAllowed,
                        color: orange,
                        onTap: () {
                          setState(() {
                            sleepoversAllowed = true;
                          });
                        },
                      ),

                      const SizedBox(width: 12),

                      _radioChoice(
                        label: 'No',
                        selected: !sleepoversAllowed,
                        color: orange,
                        onTap: () {
                          setState(() {
                            sleepoversAllowed = false;
                          });
                        },
                      ),
                    ],
                  ),

                  // Solo mostramos las noches si permitimos dormir
                  if (sleepoversAllowed) ...[
                    const SizedBox(height: 14),

                    Container(
                      height: 1,
                      color: const Color(0xFFFFE1D1),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Máximo de noches al mes',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        SizedBox(
                          width: 125,
                          child: _dropdown(
                            value: maxNights,
                            options: nightsOptions,
                            onChanged: (value) {
                              if (value == null) return;

                              setState(() {
                                maxNights = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _buildInformationBox() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: turquoise,
            size: 28,
          ),

          SizedBox(width: 14),

          Expanded(
            child: Text(
              'Solo mostraremos candidatos que cumplan todas estas condiciones.',
              style: TextStyle(
                color: textSecondary,
                fontSize: 13.5,
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
        22,
        8,
        22,
        16,
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: _continue,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Spacer(),

                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 27,
                ),

                SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _continue() {
    final requirements = <String, dynamic>{
      'smokers_allowed': smokersAllowed,
      'pets_allowed': petsAllowed,
      'minimum_stay': minimumStay,
      'minimum_income': minimumIncome,
      'guarantor_allowed': guarantorAllowed,
      'visits_allowed': visitsAllowed,
      'sleepovers_allowed':
      visitsAllowed ? sleepoversAllowed : false,
      'max_nights_per_month':
      visitsAllowed && sleepoversAllowed
          ? maxNights
          : null,
      'minors_allowed': minorsAllowed,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CohabiSelectionLifestyleScreen(
          propertyIds: widget.propertyIds,
          requirements: requirements,
        ),
      ),
    );
  }
}