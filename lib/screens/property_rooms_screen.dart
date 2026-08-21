import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';
import 'room_features_screen.dart';

class PropertyRoomsScreen extends StatefulWidget {
  final String propertyId;
  final int roomCount;
  final int initialRoomIndex;

  const PropertyRoomsScreen({
    super.key,
    required this.propertyId,
    required this.roomCount,
    this.initialRoomIndex = 0,
  });

  @override
  State<PropertyRoomsScreen> createState() =>
      _PropertyRoomsScreenState();
}

class _PropertyRoomsScreenState extends State<PropertyRoomsScreen> {
  int _selectedRoom = 0;

  late final List<_RoomData> _rooms;

  final List<String> _minimumStayOptions = [
    '1 mes',
    '2 meses',
    '3 meses',
    '6 meses',
    '12 meses',
  ];

  final List<String> _maximumStayOptions = [
    '3 meses',
    '6 meses',
    '12 meses',
    '24 meses',
    'Sin máximo',
  ];

  @override
  void initState() {
    super.initState();

    _selectedRoom = widget.initialRoomIndex;

    _rooms = List.generate(
      widget.roomCount,
          (index) => _RoomData(),
    );
  }

  _RoomData get currentRoom => _rooms[_selectedRoom];

  Future<void> _selectDate() async {
    final initialDate =
        currentRoom.availableFrom ?? DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 3650),
      ),
    );

    if (selected != null) {
      setState(() {
        currentRoom.availableFrom = selected;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void _changePeople(int delta) {
    final next = currentRoom.maxPeople + delta;

    if (next < 1) return;

    setState(() {
      currentRoom.maxPeople = next;
    });
  }

  bool _roomIsComplete(_RoomData room) {
    return room.availableFrom != null &&
        room.monthlyPrice.text.trim().isNotEmpty &&
        room.deposit.text.trim().isNotEmpty &&
        room.bookingAmount.text.trim().isNotEmpty &&
        room.surface.text.trim().isNotEmpty &&
        room.minimumStay != null &&
        room.maximumStay != null;
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    final room = _rooms[_selectedRoom];

    // 1. Comprobamos que la habitación actual esté completa
    if (!_roomIsComplete(room)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Completa todos los campos de la habitación ${_selectedRoom + 1}.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // 2. Preparamos los datos de esta habitación
      final roomData = {
        'property_id': widget.propertyId,
        'room_number': _selectedRoom + 1,
        'status': room.isAvailable ? 'Disponible' : 'Ocupada',
        'available_from':
        room.availableFrom!.toIso8601String().split('T').first,
        'monthly_price': double.parse(
          room.monthlyPrice.text.trim().replaceAll(',', '.'),
        ),
        'deposit': double.parse(
          room.deposit.text.trim().replaceAll(',', '.'),
        ),
        'reservation_price': double.parse(
          room.bookingAmount.text.trim().replaceAll(',', '.'),
        ),
        'min_stay': room.minimumStay,
        'max_stay': room.maximumStay,
        'max_people': room.maxPeople,
        'area_m2': double.parse(
          room.surface.text.trim().replaceAll(',', '.'),
        ),
      };

      // 3. Si todavía no existe en Supabase, la creamos.
      if (room.roomId == null) {
        final insertedRoom = await Supabase.instance.client
            .from('rooms')
            .insert(roomData)
            .select('id')
            .single();

        room.roomId = insertedRoom['id'] as String;
      } else {
        // Si ya existía, actualizamos la misma habitación.
        await Supabase.instance.client
            .from('rooms')
            .update(roomData)
            .eq('id', room.roomId!);
      }

      if (!mounted) return;

      // 4. Vamos a las características DE ESTA habitación.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomFeaturesScreen(
            propertyId: widget.propertyId,
            roomCount: widget.roomCount,
            roomIndex: _selectedRoom,
            roomId: room.roomId!,
          ),
        ),
      );
    } on FormatException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Revisa los campos numéricos. Introduce solo números.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar la habitación: $error',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final room in _rooms) {
      room.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = currentRoom;

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

              _buildStepIndicator(),

              const SizedBox(height: 22),

              const Text(
                'Habitaciones',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Tu piso tiene ${widget.roomCount} habitaciones.\n'
                    'Aquí podrás configurarlas.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF5968A2),
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              _buildRoomSelector(),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE3E5ED),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Habitación ${_selectedRoom + 1}',
                          style: const TextStyle(
                            color: CohabiColors.navy,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: room.isAvailable
                                ? CohabiColors.turquoise
                                .withOpacity(0.10)
                                : const Color(0xFFF2F2F5),
                            borderRadius:
                            BorderRadius.circular(18),
                          ),
                          child: Text(
                            room.isAvailable
                                ? 'Disponible'
                                : 'Ocupada',
                            style: TextStyle(
                              color: room.isAvailable
                                  ? CohabiColors.turquoise
                                  : CohabiColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Estado',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 9),

                    _buildStatusSelector(),

                    const SizedBox(height: 20),

                    const Text(
                      'Disponible desde',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 9),

                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(13),
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(13),
                          border: Border.all(
                            color:
                            const Color(0xFFDDE0E9),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              room.availableFrom == null
                                  ? 'Selecciona una fecha'
                                  : _formatDate(
                                room.availableFrom,
                              ),
                              style: TextStyle(
                                color:
                                room.availableFrom == null
                                    ? CohabiColors
                                    .textSecondary
                                    : CohabiColors.navy,
                                fontSize: 15,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: Color(0xFF7D89B5),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMoneyField(
                            label: 'Precio mensual',
                            controller:
                            room.monthlyPrice,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Estancia mínima',
                            value: room.minimumStay,
                            items:
                            _minimumStayOptions,
                            onChanged: (value) {
                              setState(() {
                                room.minimumStay =
                                    value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 17),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMoneyField(
                            label: 'Fianza',
                            controller: room.deposit,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Estancia máxima',
                            value: room.maximumStay,
                            items:
                            _maximumStayOptions,
                            onChanged: (value) {
                              setState(() {
                                room.maximumStay =
                                    value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 17),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMoneyField(
                            label: 'Reserva',
                            controller:
                            room.bookingAmount,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPeopleField(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 17),

                    SizedBox(
                      width: MediaQuery.of(context)
                          .size
                          .width *
                          0.48,
                      child: _buildSurfaceField(
                        controller: room.surface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              _buildContinueButton(),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () =>
                    Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color:
                    CohabiColors.textSecondary,
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
                CohabiColors.turquoise
                    .withOpacity(0.12),
                CohabiColors.purple
                    .withOpacity(0.08),
              ],
            ),
            borderRadius:
            BorderRadius.circular(20),
          ),
          child: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Paso 4',
                  style: TextStyle(
                    color:
                    CohabiColors.turquoise,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' de 6',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
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
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          widget.roomCount,
              (index) {
            final selected =
                index == _selectedRoom;

            return Padding(
              padding:
              const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedRoom = index;
                  });
                },
                borderRadius:
                BorderRadius.circular(14),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                      colors: [
                        CohabiColors.turquoise,
                        Color(0xFF08BFC7),
                      ],
                    )
                        : null,
                    color:
                    selected ? null : Colors.white,
                    borderRadius:
                    BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : const Color(
                        0xFFDDE0E9,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : CohabiColors.navy,
                      fontSize: 20,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFDDE0E9),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<bool>(
              value: true,
              groupValue:
              currentRoom.isAvailable,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  currentRoom.isAvailable =
                      value;
                });
              },
              title: const Text(
                'Disponible',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CohabiColors.navy,
                ),
              ),
              activeColor:
              CohabiColors.turquoise,
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 6,
              ),
            ),
          ),
          Expanded(
            child: RadioListTile<bool>(
              value: false,
              groupValue:
              currentRoom.isAvailable,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  currentRoom.isAvailable =
                      value;
                });
              },
              title: const Text(
                'Ocupada',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CohabiColors.navy,
                ),
              ),
              activeColor:
              CohabiColors.turquoise,
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyField({
    required String label,
    required TextEditingController controller,
  }) {
    return _FieldBlock(
      label: label,
      child: TextField(
        controller: controller,
        keyboardType:
        const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: const InputDecoration(
          suffixText: '€',
          border: InputBorder.none,
          contentPadding:
          EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSurfaceField({
    required TextEditingController controller,
  }) {
    return _FieldBlock(
      label: 'Superficie de la habitación',
      child: TextField(
        controller: controller,
        keyboardType:
        const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: const InputDecoration(
          suffixText: 'm²',
          border: InputBorder.none,
          contentPadding:
          EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>
    onChanged,
  }) {
    return _FieldBlock(
      label: label,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        hint: const Text('Selecciona'),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding:
          EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
        ),
        items: items
            .map(
              (item) =>
              DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
        )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPeopleField() {
    return _FieldBlock(
      label: 'Máximo de personas',
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                _changePeople(-1),
            icon: const Icon(
              Icons.remove_rounded,
              color: CohabiColors.navy,
            ),
          ),
          Expanded(
            child: Text(
              '${currentRoom.maxPeople}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CohabiColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () =>
                _changePeople(1),
            icon: const Icon(
              Icons.add_rounded,
              color: CohabiColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return InkWell(
      onTap: _continue,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(15),
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

class _FieldBlock extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldBlock({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(13),
            border: Border.all(
              color:
              const Color(0xFFDDE0E9),
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _RoomData {
  String? roomId;
  bool isAvailable = true;

  DateTime? availableFrom;

  String? minimumStay;
  String? maximumStay;

  int maxPeople = 1;

  final TextEditingController monthlyPrice =
  TextEditingController();

  final TextEditingController deposit =
  TextEditingController();

  final TextEditingController bookingAmount =
  TextEditingController();

  final TextEditingController surface =
  TextEditingController();

  void dispose() {
    monthlyPrice.dispose();
    deposit.dispose();
    bookingAmount.dispose();
    surface.dispose();
  }
}