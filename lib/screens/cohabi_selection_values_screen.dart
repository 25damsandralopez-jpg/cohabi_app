import 'package:flutter/material.dart';
import 'cohabi_selection_ready_screen.dart';

class CohabiSelectionValuesScreen extends StatefulWidget {
  final List<String> propertyIds;
  final Map<String, dynamic> requirements;
  final Map<String, dynamic> lifestyle;

  const CohabiSelectionValuesScreen({
    super.key,
    required this.propertyIds,
    required this.requirements,
    required this.lifestyle,
  });

  @override
  State<CohabiSelectionValuesScreen> createState() =>
      _CohabiSelectionValuesScreenState();
}

class _CohabiSelectionValuesScreenState
    extends State<CohabiSelectionValuesScreen> {
  static const Color navy = Color(0xFF071747);
  static const Color turquoise = Color(0xFF10B9B4);
  static const Color purple = Color(0xFF7439F5);
  static const Color background = Color(0xFFFBFBFE);
  static const Color border = Color(0xFFE8EAF2);
  static const Color textSecondary = Color(0xFF66729A);

  final Map<String, int> _values = {
    'cleanliness': 4,
    'communication': 3,
    'tranquility': 5,
    'property_care': 4,
    'good_atmosphere': 4,
    'low_noise': 5,
    'good_coexistence': 4,
    'study_at_home': 3,
    'respect_rest_hours': 5,
    'common_spaces_organization': 4,
    'frequent_cooking': 3,
    'remote_work': 3,
  };

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
                      'Valores del piso',
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
                            '¿Qué importancia tienen estos aspectos en tu piso?\n',
                          ),
                          TextSpan(
                            text: 'Valora de 1 ',
                          ),
                          TextSpan(
                            text: '(poco importante)',
                            style: TextStyle(
                              color: purple,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' a 5 ',
                          ),
                          TextSpan(
                            text: '(muy importante).',
                            style: TextStyle(
                              color: purple,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    _buildValuesCard(),
                  ],
                ),
              ),
            ),

            _buildFinishButton(),
          ],
        ),
      ),
    );
  }

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
                  'Estas valoraciones ayudan a ordenar los candidatos según compatibilidad.',
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

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: Row(
        children: [
          _progressSegment(turquoise),
          const SizedBox(width: 9),
          _progressSegment(turquoise),
          const SizedBox(width: 9),
          _progressSegment(turquoise),
          const SizedBox(width: 9),
          _progressSegment(purple),
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
        'Paso 4 de 4',
        style: TextStyle(
          color: purple,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildValuesCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        18,
        14,
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 4,
            ),
            child: Row(
              children: [
                Text(
                  '1 = Poco importante',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Spacer(),
                Text(
                  '5 = Muy importante',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _valueRow(
            keyName: 'cleanliness',
            icon: Icons.cleaning_services_outlined,
            iconColor: turquoise,
            title: 'Limpieza',
          ),

          _valueRow(
            keyName: 'communication',
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: purple,
            title: 'Comunicación',
          ),

          _valueRow(
            keyName: 'tranquility',
            icon: Icons.spa_outlined,
            iconColor: const Color(0xFFF27AB8),
            title: 'Tranquilidad',
          ),

          _valueRow(
            keyName: 'property_care',
            icon: Icons.home_outlined,
            iconColor: const Color(0xFFFF9A32),
            title: 'Cuidado del piso',
          ),

          _valueRow(
            keyName: 'good_atmosphere',
            icon: Icons.groups_2_outlined,
            iconColor: const Color(0xFF65C65B),
            title: 'Buen ambiente',
          ),

          _valueRow(
            keyName: 'low_noise',
            icon: Icons.volume_off_outlined,
            iconColor: turquoise,
            title: 'Poco ruido',
          ),

          _valueRow(
            keyName: 'good_coexistence',
            icon: Icons.handshake_outlined,
            iconColor: purple,
            title: 'Buena convivencia',
          ),

          _valueRow(
            keyName: 'study_at_home',
            icon: Icons.menu_book_outlined,
            iconColor: const Color(0xFF6196F6),
            title: 'Se estudia en casa',
          ),

          _valueRow(
            keyName: 'respect_rest_hours',
            icon: Icons.dark_mode_outlined,
            iconColor: turquoise,
            title: 'Respetar horas de descanso',
          ),

          _valueRow(
            keyName: 'common_spaces_organization',
            icon: Icons.fact_check_outlined,
            iconColor: const Color(0xFFFF8D45),
            title: 'Organización de espacios comunes',
          ),

          _valueRow(
            keyName: 'frequent_cooking',
            icon: Icons.soup_kitchen_outlined,
            iconColor: const Color(0xFFF26EA8),
            title: 'Se cocina con frecuencia',
          ),

          _valueRow(
            keyName: 'remote_work',
            icon: Icons.laptop_mac_outlined,
            iconColor: const Color(0xFF6196F6),
            title: 'Se teletrabaja',
          ),

          const SizedBox(height: 12),

          _buildInfoBox(),
        ],
      ),
    );
  }

  Widget _valueRow({
    required String keyName,
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    final currentValue = _values[keyName] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8EAF2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: navy,
                fontSize: 12.5,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 6),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
                  (index) {
                final starValue = index + 1;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _values[keyName] = starValue;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 4,
                    ),
                    child: Icon(
                      starValue <= currentValue
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: starValue <= currentValue
                          ? purple
                          : const Color(0xFFCCD1DF),
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
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
              'Estas valoraciones nos ayudan a encontrar inquilinos que encajen con el estilo de convivencia de tu piso.',
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

  Widget _buildFinishButton() {
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
          onTap: _finish,
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
                  'Finalizar',
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

  void _finish() {
    final completeFilter = <String, dynamic>{
      'property_ids': widget.propertyIds,
      'requirements': widget.requirements,
      'lifestyle': widget.lifestyle,
      'values': _values,
    };

    debugPrint(
      'COHABI SELECCIÓN COMPLETA: $completeFilter',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CohabiSelectionReadyScreen(
          propertyIds: widget.propertyIds,
        ),
      ),
    );
  }
}