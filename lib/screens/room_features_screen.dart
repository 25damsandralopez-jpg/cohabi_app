import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';
import 'room_photos_screen.dart';

class RoomFeaturesScreen extends StatefulWidget {
  final String propertyId;
  final int roomCount;
  final int roomIndex;
  final String roomId;

  const RoomFeaturesScreen({
    super.key,
    required this.propertyId,
    required this.roomCount,
    required this.roomIndex,
    required this.roomId,
  });

  @override
  State<RoomFeaturesScreen> createState() =>
      _RoomFeaturesScreenState();
}

class _RoomFeaturesScreenState extends State<RoomFeaturesScreen> {
  String? _bedSize;

  // ------------------------------------------------------------
  // OTROS DETALLES
  // ------------------------------------------------------------

  bool _privateBathroom = false;
  bool _doorLock = true;
  bool _privateKitchen = false;
  bool _exteriorView = false;

  // ------------------------------------------------------------
  // EQUIPAMIENTO
  // ------------------------------------------------------------

  final Set<String> _equipment = {
    'Armario',
    'Mesita',
    'Silla',
    'Escritorio',
    'Espejo',
    'Ventilador de techo',
    'Calefactor',
    'Aire acondicionado',
    'Televisión',
    'Ropa de cama',
    'Almohada',
  };

  final List<_BedOption> _bedOptions = const [
    _BedOption(
      value: '90 cm',
      subtitle: 'Individual',
    ),
    _BedOption(
      value: '105 cm',
      subtitle: 'Individual amplia',
    ),
    _BedOption(
      value: '135 cm',
      subtitle: 'Doble',
    ),
    _BedOption(
      value: '150 cm o más',
      subtitle: 'Doble queen',
    ),
  ];

  final List<_EquipmentOption> _equipmentOptions = const [
    _EquipmentOption(
      name: 'Armario',
      icon: Icons.door_sliding_outlined,
    ),
    _EquipmentOption(
      name: 'Mesita',
      icon: Icons.table_restaurant_outlined,
    ),
    _EquipmentOption(
      name: 'Silla',
      icon: Icons.chair_alt_outlined,
    ),
    _EquipmentOption(
      name: 'Escritorio',
      icon: Icons.desk_outlined,
    ),
    _EquipmentOption(
      name: 'Estantería',
      icon: Icons.shelves,
    ),
    _EquipmentOption(
      name: 'Cómoda',
      icon: Icons.inventory_2_outlined,
    ),
    _EquipmentOption(
      name: 'Espejo',
      icon: Icons.circle_outlined,
    ),
    _EquipmentOption(
      name: 'Perchero',
      icon: Icons.checkroom_outlined,
    ),
    _EquipmentOption(
      name: 'Ventilador de techo',
      icon: Icons.toys_outlined,
    ),
    _EquipmentOption(
      name: 'Calefactor',
      icon: Icons.heat_pump_outlined,
    ),
    _EquipmentOption(
      name: 'Aire acondicionado',
      icon: Icons.air_outlined,
    ),
    _EquipmentOption(
      name: 'Televisión',
      icon: Icons.tv_outlined,
    ),
    _EquipmentOption(
      name: 'Nevera',
      icon: Icons.kitchen_outlined,
    ),
    _EquipmentOption(
      name: 'Microondas',
      icon: Icons.microwave_outlined,
    ),
    _EquipmentOption(
      name: 'Ropa de cama',
      icon: Icons.bed_outlined,
    ),
    _EquipmentOption(
      name: 'Almohada',
      icon: Icons.airline_seat_flat_outlined,
    ),
  ];

  // ============================================================
  // CONTINUAR
  // ============================================================

  Future<void> _continue() async {
    if (_bedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona el tamaño de la cama.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await Supabase.instance.client
          .from('rooms')
          .update({
        'bed_size': _bedSize,
        'private_bathroom': _privateBathroom,
        'room_lock': _doorLock,
        'private_kitchen': _privateKitchen,
        'exterior_view': _exteriorView,
        'equipment': _equipment.join(', '),
      })
          .eq('id', widget.roomId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomPhotosScreen(
            propertyId: widget.propertyId,
            roomCount: widget.roomCount,
            roomIndex: widget.roomIndex,
            roomId: widget.roomId,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudieron guardar las características: $error',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            16,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ------------------------------------------------
              // CABECERA
              // ------------------------------------------------

              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: CohabiColors.navy,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: CohabiColors.navy,
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              _buildStepIndicator(),

              const SizedBox(height: 20),

              Text(
                'Habitación ${widget.roomIndex + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 26),

              // ==================================================
              // OTROS DETALLES
              // ==================================================

              const Text(
                'Otros detalles',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildDetailCard(
                      title: 'Baño\npropio',
                      icon: Icons.bathtub_outlined,
                      selected: _privateBathroom,
                      onTap: () {
                        setState(() {
                          _privateBathroom = !_privateBathroom;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _buildDetailCard(
                      title: 'Habitación\ncon llave',
                      icon: Icons.lock_outline_rounded,
                      selected: _doorLock,
                      onTap: () {
                        setState(() {
                          _doorLock = !_doorLock;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _buildDetailCard(
                      title: 'Cocina\npropia',
                      icon: Icons.kitchen_outlined,
                      selected: _privateKitchen,
                      onTap: () {
                        setState(() {
                          _privateKitchen = !_privateKitchen;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _buildDetailCard(
                      title: 'Vistas al\nexterior',
                      icon: Icons.window_outlined,
                      selected: _exteriorView,
                      onTap: () {
                        setState(() {
                          _exteriorView = !_exteriorView;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==================================================
              // CAMA
              // ==================================================

              const Text(
                'Cama',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Tamaño de la cama',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              // Las cuatro camas EN UNA SOLA FILA
              Row(
                children: List.generate(
                  _bedOptions.length,
                      (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right:
                          index == _bedOptions.length - 1 ? 0 : 7,
                        ),
                        child: _buildBedOption(
                          _bedOptions[index],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // EQUIPAMIENTO
              // ==================================================

              const Text(
                'Muebles y equipamiento',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              GridView.builder(
                itemCount: _equipmentOptions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.86,
                ),
                itemBuilder: (context, index) {
                  return _buildEquipmentCard(
                    _equipmentOptions[index],
                  );
                },
              ),

              const SizedBox(height: 26),

              _buildContinueButton(),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PASO 4 DE 6
  // ============================================================

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
                  text: 'Paso 4',
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
                (index) => Container(
              width: index < 4 ? 42 : 30,
              height: 5,
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              decoration: BoxDecoration(
                color: index < 4
                    ? CohabiColors.turquoise
                    : const Color(0xFFE1E3EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TARJETAS OTROS DETALLES
  // ============================================================

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 125,
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            width: selected ? 1.5 : 1,
            color: selected
                ? CohabiColors.turquoise
                : const Color(0xFFDDE0E9),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: selected
                        ? CohabiColors.turquoise
                        : CohabiColors.navy,
                    size: 30,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 11,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
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
                  radius: 9,
                  backgroundColor: CohabiColors.turquoise,
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OPCIONES CAMA
  // ============================================================

  Widget _buildBedOption(
      _BedOption option,
      ) {
    final selected = _bedSize == option.value;

    return InkWell(
      onTap: () {
        setState(() {
          _bedSize = option.value;
        });
      },
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 92,
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            width: selected ? 1.7 : 1,
            color: selected
                ? CohabiColors.turquoise
                : const Color(0xFFDDE0E9),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    option.value,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    option.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 9.5,
                      height: 1.1,
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
                  backgroundColor: CohabiColors.turquoise,
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EQUIPAMIENTO
  // ============================================================

  Widget _buildEquipmentCard(
      _EquipmentOption option,
      ) {
    final selected = _equipment.contains(option.name);

    return InkWell(
      onTap: () {
        setState(() {
          if (selected) {
            _equipment.remove(option.name);
          } else {
            _equipment.add(option.name);
          }
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? CohabiColors.turquoise
                : const Color(0xFFDDE0E9),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    option.icon,
                    size: 27,
                    color: selected
                        ? CohabiColors.turquoise
                        : CohabiColors.navy,
                  ),

                  const SizedBox(height: 7),

                  Text(
                    option.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 10.5,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
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
                  backgroundColor: CohabiColors.turquoise,
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTÓN
  // ============================================================

  Widget _buildContinueButton() {
    return InkWell(
      onTap: _continue,
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
              'Guardar y continuar',
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

// ============================================================
// MODELOS
// ============================================================

class _BedOption {
  final String value;
  final String subtitle;

  const _BedOption({
    required this.value,
    required this.subtitle,
  });
}

class _EquipmentOption {
  final String name;
  final IconData icon;

  const _EquipmentOption({
    required this.name,
    required this.icon,
  });
}