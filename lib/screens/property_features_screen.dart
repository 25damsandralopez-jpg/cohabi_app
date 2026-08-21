import 'package:flutter/material.dart';
import 'property_photos_screen.dart';

import '../core/theme/app_colors.dart';

class PropertyFeaturesScreen extends StatefulWidget {
  final String propertyId;
  final int roomCount;

  const PropertyFeaturesScreen({
    super.key,
    required this.propertyId,
    required this.roomCount,
  });

  @override
  State<PropertyFeaturesScreen> createState() =>
      _PropertyFeaturesScreenState();
}

class _PropertyFeaturesScreenState extends State<PropertyFeaturesScreen> {
  // Tipo de convivencia
  String _tenantType = 'Mixto';

  // Características seleccionadas por defecto,
  // siguiendo la plantilla que me pasaste.
  final Set<String> _features = {
    'Ascensor',
    'Garaje',
    'Balcón',
    'Salón',
    'Comedor',
    'Cocina',
    'Amueblado',
    'Lavadora',
    'Videovigilancia',
  };

  // Servicios seleccionados por defecto
  final Set<String> _services = {
    'Agua',
    'Luz',
    'Calefacción',
    'Limpieza',
    'WiFi / Internet',
  };

  final _otherServicesController = TextEditingController();

  @override
  void dispose() {
    _otherServicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // FLECHA ATRÁS
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: CohabiColors.navy,
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // PASO 2 DE 6
              _buildStepIndicator(),

              const SizedBox(height: 25),

              const Text(
                'Características del piso',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Cuéntanos qué tiene tu piso.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 24),

              // TIPO DE PISO
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de piso',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      '¿Quién puede vivir en este piso?',
                      style: TextStyle(
                        color: CohabiColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 17),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTenantCard(
                            value: 'Chicas',
                            icon: Icons.female_rounded,
                            iconColor: CohabiColors.purple,
                          ),
                        ),

                        const SizedBox(width: 9),

                        Expanded(
                          child: _buildTenantCard(
                            value: 'Chicos',
                            icon: Icons.male_rounded,
                            iconColor: Color(0xFF1677FF),
                          ),
                        ),

                        const SizedBox(width: 9),

                        Expanded(
                          child: _buildTenantCard(
                            value: 'Mixto',
                            icon: Icons.person_outline_rounded,
                            iconColor: CohabiColors.turquoise,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildInfoBox(
                      icon: Icons.info_outline_rounded,
                      text:
                      'Nos ayuda a mostrarte candidatos más compatibles.',
                      turquoise: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // CARACTERÍSTICAS
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Características',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _buildFeatureGrid(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // SERVICIOS
              _buildSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Servicios incluidos',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Marca los servicios que están incluidos en el precio.',
                      style: TextStyle(
                        color: CohabiColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _buildServicesGrid(),

                    const SizedBox(height: 14),

                    // OTROS SERVICIOS
                    TextField(
                      controller: _otherServicesController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: CohabiColors.navy,
                        ),
                        labelText: 'Otros servicios (opcional)',
                        hintText: 'Ej: Comunidad, alarmas, etc.',
                        suffixIcon: const Icon(
                          Icons.chevron_right_rounded,
                          color: CohabiColors.navy,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE3E5ED),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE3E5ED),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: CohabiColors.turquoise,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    _buildInfoBox(
                      icon: Icons.info_outline_rounded,
                      text:
                      'Puedes modificar estas características más adelante desde la información del piso.',
                      turquoise: false,
                    ),

                    const SizedBox(height: 20),

                    _buildContinueButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // INDICADOR PASO 2
  // ---------------------------------------------------------

  Widget _buildStepIndicator() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CohabiColors.turquoise.withOpacity(0.12),
                CohabiColors.purple.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Paso 2',
                  style: TextStyle(
                    color: CohabiColors.turquoise,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' de 6',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            6,
                (index) {
              final completed = index < 2;

              return Container(
                width: index < 2 ? 42 : 30,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: completed
                      ? CohabiColors.turquoise
                      : const Color(0xFFE1E3EB),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // CONTENEDOR DE SECCIÓN
  // ---------------------------------------------------------

  Widget _buildSection({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3E5ED),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------
  // CHICAS / CHICOS / MIXTO
  // ---------------------------------------------------------

  Widget _buildTenantCard({
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final selected = _tenantType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _tenantType = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 145,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? CohabiColors.turquoise.withOpacity(0.035)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? CohabiColors.turquoise
                : const Color(0xFFE2E4EC),
            width: selected ? 1.7 : 1,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: selected
                    ? CohabiColors.turquoise
                    : const Color(0xFFD9DCE7),
                size: 23,
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 49,
                    color: iconColor,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    value,
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // CARACTERÍSTICAS
  // ---------------------------------------------------------

  Widget _buildFeatureGrid() {
    final items = [
      _ChoiceItem('Ascensor', Icons.elevator_outlined),
      _ChoiceItem('Garaje', Icons.directions_car_outlined),
      _ChoiceItem('Balcón', Icons.balcony_outlined),
      _ChoiceItem('Terraza', Icons.deck_outlined),
      _ChoiceItem('Salón', Icons.chair_outlined),
      _ChoiceItem('Comedor', Icons.table_restaurant_outlined),
      _ChoiceItem('Cocina', Icons.soup_kitchen_outlined),
      _ChoiceItem('Amueblado', Icons.weekend_outlined),
      _ChoiceItem('Lavadora', Icons.local_laundry_service_outlined),
      _ChoiceItem('Jardín', Icons.local_florist_outlined),
      _ChoiceItem('Piscina', Icons.pool_outlined),
      _ChoiceItem('Videovigilancia', Icons.videocam_outlined),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.90,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return _buildSelectableCard(
          label: item.label,
          icon: item.icon,
          selected: _features.contains(item.label),
          onTap: () {
            setState(() {
              if (_features.contains(item.label)) {
                _features.remove(item.label);
              } else {
                _features.add(item.label);
              }
            });
          },
        );
      },
    );
  }

  // ---------------------------------------------------------
  // SERVICIOS
  // ---------------------------------------------------------

  Widget _buildServicesGrid() {
    final items = [
      _ChoiceItem('Agua', Icons.water_drop_outlined),
      _ChoiceItem('Luz', Icons.bolt_outlined),
      _ChoiceItem('Calefacción', Icons.thermostat_outlined),
      _ChoiceItem('Aire acondicionado', Icons.ac_unit_outlined),
      _ChoiceItem('Limpieza', Icons.cleaning_services_outlined),
      _ChoiceItem('WiFi / Internet', Icons.wifi_rounded),
      _ChoiceItem('Gas', Icons.local_fire_department_outlined),
      _ChoiceItem('Mantenimiento', Icons.build_outlined),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.90,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return _buildSelectableCard(
          label: item.label,
          icon: item.icon,
          selected: _services.contains(item.label),
          onTap: () {
            setState(() {
              if (_services.contains(item.label)) {
                _services.remove(item.label);
              } else {
                _services.add(item.label);
              }
            });
          },
        );
      },
    );
  }

  // ---------------------------------------------------------
  // TARJETAS PEQUEÑAS
  // ---------------------------------------------------------

  Widget _buildSelectableCard({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? CohabiColors.turquoise.withOpacity(0.035)
              : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? CohabiColors.turquoise.withOpacity(0.65)
                : const Color(0xFFE3E5ED),
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: selected
                      ? CohabiColors.turquoise
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: selected
                        ? CohabiColors.turquoise
                        : const Color(0xFFD7DAE5),
                  ),
                ),
                child: selected
                    ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 15,
                )
                    : null,
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 29,
                    color: selected
                        ? CohabiColors.turquoise
                        : const Color(0xFF5366A5),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // AVISOS
  // ---------------------------------------------------------

  Widget _buildInfoBox({
    required IconData icon,
    required String text,
    required bool turquoise,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: turquoise
              ? [
            CohabiColors.turquoise.withOpacity(0.06),
            CohabiColors.purple.withOpacity(0.035),
          ]
              : [
            CohabiColors.purple.withOpacity(0.045),
            CohabiColors.purple.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: turquoise
                ? CohabiColors.turquoise
                : CohabiColors.purple,
            size: 25,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF53639B),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // BOTÓN CONTINUAR
  // ---------------------------------------------------------

  Widget _buildContinueButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyPhotosScreen(
              propertyId: widget.propertyId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [
              CohabiColors.turquoise,
              Color(0xFF198DFF),
              CohabiColors.purple,
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
              size: 26,
            ),

            SizedBox(width: 17),
          ],
        ),
      ),
    );
  }
}

class _ChoiceItem {
  final String label;
  final IconData icon;

  const _ChoiceItem(
      this.label,
      this.icon,
      );
}