import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'property_rooms_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
  });

  @override
  State<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final supabase = Supabase.instance.client;

  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _property;
  List<dynamic> _rooms = [];

  final List<String> _photoUrls = [];

  // ============================================================
  // COLORES COHABI
  // ============================================================

  static const Color navy = Color(0xFF071747);
  static const Color turquoise = Color(0xFF0DB9B4);
  static const Color purple = Color(0xFF7439F5);
  static const Color coral = Color(0xFFFF5E78);
  static const Color orange = Color(0xFFFF951F);

  static const Color background = Color(0xFFFAFBFF);
  static const Color border = Color(0xFFE8EAF1);
  static const Color secondaryText = Color(0xFF6573A0);

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  // ============================================================
  // CARGA DE DATOS
  // ============================================================

  Future<void> _loadProperty() async {
    try {
      if (mounted) {
        setState(() {
          _loading = true;
          _error = null;
        });
      }

      final propertyResponse = await supabase
          .from('properties')
          .select(
        'id, name, address, city, postal_code, property_type, '
            'rooms, bathrooms, surface, condition',
      )
          .eq('id', widget.propertyId)
          .single();

      final roomsResponse = await supabase
          .from('rooms')
          .select(
        'id, room_number, status, monthly_price, available_from, '
            'bed_size',
      )
          .eq('property_id', widget.propertyId)
          .order('room_number');

      final photosResponse = await supabase
          .from('property_photos')
          .select('storage_path, position')
          .eq('property_id', widget.propertyId)
          .order('position');

      final List<String> loadedPhotoUrls = [];

      for (final photo in photosResponse) {
        final path = photo['storage_path']?.toString();

        if (path == null || path.isEmpty) continue;

        try {
          final url = await supabase.storage
              .from('property-photos')
              .createSignedUrl(
            path,
            3600,
          );

          loadedPhotoUrls.add(url);
        } catch (_) {
          // Si una foto falla, seguimos cargando las demás.
        }
      }

      if (!mounted) return;

      setState(() {
        _property = propertyResponse;
        _rooms = roomsResponse;

        _photoUrls
          ..clear()
          ..addAll(loadedPhotoUrls);

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: CircularProgressIndicator(
            color: turquoise,
          ),
        ),
      );
    }

    if (_error != null || _property == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: coral,
                  size: 50,
                ),
                const SizedBox(height: 14),
                const Text(
                  'No se pudo cargar el piso',
                  style: TextStyle(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loadProperty,
                  child: const Text('Volver a intentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final name =
        _property!['name']?.toString() ?? 'Mi piso';

    final address =
        _property!['address']?.toString() ?? '';

    final city =
        _property!['city']?.toString() ?? '';

    final postalCode =
        _property!['postal_code']?.toString() ?? '';

    final totalRooms =
        _property!['rooms'] as int? ?? 0;

    final configuredRooms = _rooms.length;

    final availableRooms = _rooms.where((room) {
      return room['status'] == 'Disponible';
    }).length;

    final occupiedRooms = _rooms.where((room) {
      return room['status'] == 'Ocupada';
    }).length;

    final monthlyIncome = _calculateMonthlyIncome();

    final occupancyPercentage = totalRooms == 0
        ? 0
        : ((occupiedRooms / totalRooms) * 100).round();

    final fullAddress = [
      address,
      if (postalCode.isNotEmpty) postalCode,
      city,
    ].where((item) => item.isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: background,

      // ==========================================================
      // MENÚ INFERIOR PROVISIONAL
      // ==========================================================
      bottomNavigationBar: _buildBottomNavigation(),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProperty,
          color: turquoise,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              14,
              12,
              14,
              26,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // =================================================
                // CABECERA
                // =================================================

                _buildHeader(
                  name: name,
                  fullAddress: fullAddress,
                ),

                const SizedBox(height: 14),

                // =================================================
                // FOTO PRINCIPAL
                // =================================================

                _buildHeroPhoto(),

                const SizedBox(height: 14),

                // =================================================
                // MÉTRICAS PRINCIPALES
                // =================================================

                _buildMainStats(
                  totalRooms: totalRooms,
                  availableRooms: availableRooms,
                  tenantCount: 0,
                  monthlyIncome: monthlyIncome,
                  occupancyPercentage: occupancyPercentage,
                ),

                const SizedBox(height: 14),

                // =================================================
                // OCUPACIÓN
                // =================================================

                _buildOccupationSection(
                  totalRooms: totalRooms,
                  configuredRooms: configuredRooms,
                  occupiedRooms: occupiedRooms,
                  occupancyPercentage: occupancyPercentage,
                ),

                const SizedBox(height: 14),

                // =================================================
                // CALENDARIO
                // =================================================

                _buildCalendarCard(
                  totalRooms: totalRooms,
                ),

                const SizedBox(height: 14),

                // =================================================
                // INQUILINOS
                // =================================================

                _buildTenantsCard(),

                const SizedBox(height: 14),

                // =================================================
                // ENTRADAS / SALIDAS
                // =================================================

                _buildMovementsCard(),

                const SizedBox(height: 14),

                // =================================================
                // FINANZAS
                // =================================================

                _buildFinancialCard(
                  monthlyIncome: monthlyIncome,
                ),

                const SizedBox(height: 14),

                // =================================================
                // INCIDENCIAS
                // =================================================

                _buildIncidentsCard(),

                const SizedBox(height: 14),

                // =================================================
                // MENSAJES
                // =================================================

                _buildMessagesCard(),

                const SizedBox(height: 14),

                // =================================================
                // DATOS DEL PISO
                // =================================================

                _buildPropertyDataCard(
                  totalRooms: totalRooms,
                ),

                const SizedBox(height: 14),

                // =================================================
                // COHABI SELECCIÓN
                // =================================================

                _buildSelectionCard(),

                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CABECERA
  // ============================================================

  Widget _buildHeader({
    required String name,
    required String fullAddress,
  }) {
    return Row(
      children: [
        _roundIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),

        const SizedBox(width: 10),

        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EEFF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.apartment_rounded,
            color: purple,
            size: 25,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 3),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: secondaryText,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      fullAddress.isEmpty
                          ? 'Dirección no indicada'
                          : fullAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        _roundIconButton(
          icon: Icons.more_vert_rounded,
          color: purple,
          onTap: _showPropertyMenu,
        ),
      ],
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = navy,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: border,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
    );
  }

  // ============================================================
  // FOTO
  // ============================================================

  Widget _buildHeroPhoto() {
    return SizedBox(
      height: 190,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_photoUrls.isNotEmpty)
              Image.network(
                _photoUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _photoPlaceholder();
                },
              )
            else
              _photoPlaceholder(),

            Positioned(
              right: 12,
              bottom: 12,
              child: Row(
                children: [
                  InkWell(
                    onTap: _showPhotos,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.photo_camera_outlined,
                            color: purple,
                            size: 17,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Ver fotos',
                            style: TextStyle(
                              color: navy,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _photoUrls.isEmpty
                          ? '0'
                          : '1 / ${_photoUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFEAF9F8),
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 64,
          color: turquoise,
        ),
      ),
    );
  }

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================

  Widget _buildMainStats({
    required int totalRooms,
    required int availableRooms,
    required int tenantCount,
    required double monthlyIncome,
    required int occupancyPercentage,
  }) {
    return _card(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: _topStat(
              icon: Icons.bed_outlined,
              value: '$totalRooms',
              label: 'Habitaciones',
              color: purple,
            ),
          ),

          _verticalDivider(),

          Expanded(
            child: _topStat(
              icon: Icons.meeting_room_outlined,
              value: '$availableRooms',
              label: 'Disponibles',
              color: turquoise,
            ),
          ),

          _verticalDivider(),

          Expanded(
            child: _topStat(
              icon: Icons.people_outline_rounded,
              value: '$tenantCount',
              label: 'Inquilinos',
              color: purple,
            ),
          ),

          _verticalDivider(),

          Expanded(
            child: _topStat(
              icon: Icons.trending_up_rounded,
              value: '${_money(monthlyIncome)} €',
              label: 'Ingresos',
              color: turquoise,
            ),
          ),

          _verticalDivider(),

          Expanded(
            child: _topStat(
              icon: Icons.donut_large_rounded,
              value: '$occupancyPercentage%',
              label: 'Ocupación',
              color: turquoise,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 21,
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 46,
      color: border,
    );
  }

  // ============================================================
  // OCUPACIÓN DEL PISO
  // ============================================================

  Widget _buildOccupationSection({
    required int totalRooms,
    required int configuredRooms,
    required int occupiedRooms,
    required int occupancyPercentage,
  }) {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionIcon(
                Icons.meeting_room_outlined,
                turquoise,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Ocupación del piso',
                  style: TextStyle(
                    color: turquoise,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$occupiedRooms / $totalRooms',
                    style: const TextStyle(
                      color: turquoise,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '$configuredRooms configuradas',
                    style: const TextStyle(
                      color: secondaryText,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (totalRooms == 0)
            const Text(
              'Todavía no hay habitaciones.',
              style: TextStyle(
                color: secondaryText,
              ),
            )
          else
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: totalRooms,
                separatorBuilder: (_, __) =>
                const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final roomNumber = index + 1;
                  final room = _findRoom(roomNumber);

                  return _roomMiniCard(
                    roomNumber: roomNumber,
                    totalRooms: totalRooms,
                    room: room,
                  );
                },
              ),
            ),

          const SizedBox(height: 14),

          const Divider(
            color: border,
            height: 1,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Text(
                'Ocupación actual',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const Spacer(),

              Text(
                '$occupancyPercentage%',
                style: const TextStyle(
                  color: turquoise,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _findRoom(int roomNumber) {
    for (final item in _rooms) {
      if (item['room_number'] == roomNumber) {
        return Map<String, dynamic>.from(item);
      }
    }

    return null;
  }

  Widget _roomMiniCard({
    required int roomNumber,
    required int totalRooms,
    required Map<String, dynamic>? room,
  }) {
    final configured = room != null;
    final status =
        room?['status']?.toString() ?? 'Sin configurar';

    Color statusColor;
    Color softColor;

    if (!configured) {
      statusColor = secondaryText;
      softColor = const Color(0xFFF1F3F7);
    } else if (status == 'Ocupada') {
      statusColor = purple;
      softColor = const Color(0xFFF1EBFF);
    } else {
      statusColor = turquoise;
      softColor = const Color(0xFFE8FAF9);
    }

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PropertyRoomsScreen(
              propertyId: widget.propertyId,
              roomCount: totalRooms,
              initialRoomIndex: roomNumber - 1,
            ),
          ),
        );

        if (!mounted) return;

        await _loadProperty();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 105,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: softColor.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Hab. $roomNumber',
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: _photoUrls.isNotEmpty
                      ? Image.network(
                    _photoUrls.first,
                    fit: BoxFit.cover,
                  )
                      : Icon(
                    Icons.bed_outlined,
                    color: statusColor,
                    size: 30,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 7),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: softColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                child: Text(
                  configured
                      ? status
                      : 'Sin configurar',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CALENDARIO
  // ============================================================

  Widget _buildCalendarCard({
    required int totalRooms,
  }) {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionIcon(
                Icons.calendar_month_rounded,
                purple,
              ),
              const SizedBox(width: 8),
              const Text(
                'Calendario de ocupación',
                style: TextStyle(
                  color: purple,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chevron_left,
                color: purple,
                size: 20,
              ),
              SizedBox(width: 16),
              Text(
                'Ocupación actual',
                style: TextStyle(
                  color: navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.chevron_right,
                color: purple,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (totalRooms == 0)
            const Center(
              child: Text(
                'Sin habitaciones',
                style: TextStyle(
                  color: secondaryText,
                ),
              ),
            )
          else
            ...List.generate(
              totalRooms,
                  (index) {
                final roomNumber = index + 1;
                final room = _findRoom(roomNumber);

                final status =
                room?['status']?.toString();

                final configured = room != null;

                final color = !configured
                    ? const Color(0xFFE7EAF0)
                    : status == 'Ocupada'
                    ? turquoise
                    : const Color(0xFFE7EAF0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: Text(
                          'Hab. $roomNumber',
                          style: const TextStyle(
                            color: navy,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: status == 'Ocupada'
                                ? 0.92
                                : configured
                                ? 0.25
                                : 0.08,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 6),

          const Divider(
            color: border,
          ),

          Center(
            child: TextButton.icon(
              onPressed: () {
                _showInfo(
                  'Calendario',
                  'El calendario completo se conectará cuando '
                      'construyamos contratos, entradas y salidas.',
                );
              },
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 17,
              ),
              label: const Text(
                'Ver calendario completo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INQUILINOS
  // ============================================================

  Widget _buildTenantsCard() {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _sectionHeader(
            icon: Icons.people_outline_rounded,
            title: 'Inquilinos',
            color: turquoise,
          ),

          const SizedBox(height: 18),

          const Icon(
            Icons.person_search_outlined,
            color: Color(0xFFB3B9CC),
            size: 40,
          ),

          const SizedBox(height: 8),

          const Text(
            'Todavía no hay inquilinos vinculados',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Los inquilinos aparecerán aquí cuando creen '
                'su propia cuenta y se vinculen a una habitación.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryText,
              fontSize: 10.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOVIMIENTOS
  // ============================================================

  Widget _buildMovementsCard() {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _emptyMovement(
                  icon: Icons.login_rounded,
                  title: 'Próximas entradas',
                  color: purple,
                ),
              ),

              Container(
                width: 1,
                height: 90,
                color: border,
              ),

              Expanded(
                child: _emptyMovement(
                  icon: Icons.logout_rounded,
                  title: 'Próximas salidas',
                  color: orange,
                ),
              ),
            ],
          ),

          const Divider(
            color: border,
          ),

          TextButton(
            onPressed: () {
              _showInfo(
                'Movimientos',
                'Aquí aparecerán las próximas entradas y salidas '
                    'cuando construyamos las estancias.',
              );
            },
            child: const Text(
              'Ver calendario de movimientos',
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyMovement({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 25,
          ),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'No hay movimientos programados',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryText,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FINANZAS
  // ============================================================

  Widget _buildFinancialCard({
    required double monthlyIncome,
  }) {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _sectionHeader(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Resumen financiero',
            color: turquoise,
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _financeMiniBox(
                  icon: Icons.calendar_today_outlined,
                  value: '${_money(monthlyIncome)} €',
                  label: 'Ingresos\nmensuales',
                  color: turquoise,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _financeMiniBox(
                  icon: Icons.calendar_month_outlined,
                  value: '${_money(monthlyIncome * 12)} €',
                  label: 'Estimación\nanual',
                  color: turquoise,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _financeMiniBox(
                  icon: Icons.savings_outlined,
                  value: '—',
                  label: 'Depósitos\ny fianzas',
                  color: purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _financeMiniBox(
                  icon: Icons.warning_amber_outlined,
                  value: '—',
                  label: 'Gastos\nmensuales',
                  color: coral,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: border,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Ingresos potenciales configurados',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_money(monthlyIncome)} €',
                  style: const TextStyle(
                    color: turquoise,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _financeMiniBox({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 8,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INCIDENCIAS
  // ============================================================

  Widget _buildIncidentsCard() {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _sectionHeader(
            icon: Icons.warning_amber_rounded,
            title: 'Incidencias',
            color: coral,
            trailing: Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE7EC),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '0',
                style: TextStyle(
                  color: coral,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Icon(
            Icons.check_circle_outline_rounded,
            color: turquoise,
            size: 36,
          ),

          const SizedBox(height: 8),

          const Text(
            'No hay incidencias abiertas',
            style: TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Las incidencias de este piso aparecerán aquí.',
            style: TextStyle(
              color: secondaryText,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MENSAJES
  // ============================================================

  Widget _buildMessagesCard() {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _sectionHeader(
            icon: Icons.campaign_outlined,
            title: 'Mensajes para los inquilinos',
            color: coral,
            trailing: OutlinedButton(
              onPressed: () {
                _showInfo(
                  'Mensajes',
                  'Crearemos esta función cuando conectemos '
                      'los inquilinos vinculados.',
                );
              },
              child: const Text(
                'Nuevo mensaje',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFBFD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: border,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFFB4B9C9),
                  size: 30,
                ),
                SizedBox(height: 8),
                Text(
                  'Todavía no hay mensajes',
                  style: TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
  // DATOS DEL PISO
  // ============================================================

  Widget _buildPropertyDataCard({
    required int totalRooms,
  }) {
    final bathrooms =
        _property!['bathrooms']?.toString() ?? '—';

    final surface =
        _property!['surface']?.toString() ?? '—';

    final type =
        _property!['property_type']?.toString() ?? '—';

    final condition =
        _property!['condition']?.toString() ?? '—';

    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.home_work_outlined,
            title: 'Datos del piso',
            color: const Color(0xFF169AD6),
          ),

          const SizedBox(height: 14),

          Text(
            '$totalRooms habitaciones · $bathrooms baños · $surface m²',
            style: const TextStyle(
              color: navy,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Tipo: $type',
            style: const TextStyle(
              color: secondaryText,
              fontSize: 10.5,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Estado: $condition',
            style: const TextStyle(
              color: secondaryText,
              fontSize: 10.5,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showInfo(
                      'Editar datos',
                      'Conectaremos aquí la edición del piso '
                          'sin crear uno nuevo.',
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 17,
                  ),
                  label: const Text(
                    'Editar datos',
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: turquoise,
                    side: const BorderSide(
                      color: turquoise,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showPhotos,
                  icon: const Icon(
                    Icons.photo_camera_outlined,
                    size: 17,
                  ),
                  label: const Text(
                    'Gestionar fotos',
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: turquoise,
                    side: const BorderSide(
                      color: turquoise,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COHABI SELECCIÓN
  // ============================================================

  Widget _buildSelectionCard() {
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _sectionHeader(
            icon: Icons.filter_alt_outlined,
            title: 'Filtro de selección de inquilinos',
            color: purple,
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF2ECFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Sin configurar',
                style: TextStyle(
                  color: purple,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Row(
            children: [
              Expanded(
                child: _SelectionFeature(
                  icon: Icons.cake_outlined,
                  title: 'Edad',
                  value: '—',
                ),
              ),
              Expanded(
                child: _SelectionFeature(
                  icon: Icons.calendar_month_outlined,
                  title: 'Estancia',
                  value: '—',
                ),
              ),
              Expanded(
                child: _SelectionFeature(
                  icon: Icons.smoke_free_outlined,
                  title: 'Fumadores',
                  value: '—',
                ),
              ),
              Expanded(
                child: _SelectionFeature(
                  icon: Icons.pets_outlined,
                  title: 'Mascotas',
                  value: '—',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showInfo(
                  'Cohabi Selección',
                  'Aquí conectaremos el filtro de selección '
                      'para encontrar candidatos compatibles.',
                );
              },
              icon: const Icon(
                Icons.filter_alt_outlined,
                size: 17,
              ),
              label: const Text(
                'Configurar filtro',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: purple,
                side: const BorderSide(
                  color: purple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    const items = [
      _BottomItem(
        icon: Icons.home_outlined,
        label: 'Inicio',
      ),
      _BottomItem(
        icon: Icons.apartment_outlined,
        label: 'Pisos',
      ),
      _BottomItem(
        icon: Icons.person_search_outlined,
        label: 'Selección',
      ),
      _BottomItem(
        icon: Icons.people_outline,
        label: 'Inquilinos',
      ),
      _BottomItem(
        icon: Icons.build_outlined,
        label: 'Incidencias',
      ),
      _BottomItem(
        icon: Icons.bar_chart_rounded,
        label: 'Rentabilidad',
      ),
      _BottomItem(
        icon: Icons.person_outline,
        label: 'Cuenta',
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 6,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: border,
            ),
          ),
        ),
        child: Row(
          children: items.map((item) {
            final selected =
                item.label == 'Pisos';

            return Expanded(
              child: InkWell(
                onTap: () {
                  if (selected) return;

                  _showInfo(
                    item.label,
                    'Esta sección la conectaremos '
                        'cuando construyamos su módulo.',
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFF1EBFF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: selected
                            ? purple
                            : secondaryText,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: selected
                                ? purple
                                : secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS DE UI
  // ============================================================

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding =
    const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionIcon(
      IconData icon,
      Color color,
      ) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: color,
        size: 19,
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    Widget? trailing,
  }) {
    return Row(
      children: [
        _sectionIcon(
          icon,
          color,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  // ============================================================
  // CÁLCULOS
  // ============================================================

  double _calculateMonthlyIncome() {
    double total = 0;

    for (final room in _rooms) {
      if (room['status'] != 'Ocupada') continue;

      final price = room['monthly_price'];

      if (price is num) {
        total += price.toDouble();
      } else {
        total +=
            double.tryParse(price?.toString() ?? '') ??
                0;
      }
    }

    return total;
  }

  String _money(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  // ============================================================
  // MENÚ / MODALES
  // ============================================================

  void _showPropertyMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: turquoise,
                  ),
                  title: const Text(
                    'Editar datos del piso',
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    _showInfo(
                      'Editar piso',
                      'Conectaremos la edición del piso '
                          'en el siguiente módulo.',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: purple,
                  ),
                  title: const Text(
                    'Gestionar fotos',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showPhotos();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.bed_outlined,
                    color: turquoise,
                  ),
                  title: const Text(
                    'Gestionar habitaciones',
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    final totalRooms =
                        _property!['rooms'] as int? ?? 0;

                    if (totalRooms <= 0) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PropertyRoomsScreen(
                              propertyId:
                              widget.propertyId,
                              roomCount:
                              totalRooms,
                            ),
                      ),
                    ).then((_) {
                      _loadProperty();
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPhotos() {
    if (_photoUrls.isEmpty) {
      _showInfo(
        'Fotos',
        'Este piso todavía no tiene fotos disponibles.',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height:
            MediaQuery.of(context).size.height *
                0.78,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: _photoUrls.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      child: Center(
                        child: Image.network(
                          _photoUrls[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor:
                      Colors.black.withValues(
                        alpha: 0.45,
                      ),
                    ),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInfo(
      String title,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title: $message',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ============================================================
// WIDGETS AUXILIARES
// ============================================================

class _SelectionFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SelectionFeature({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2),
        Icon(
          icon,
          color: _PropertyDetailScreenState.purple,
          size: 21,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color:
            _PropertyDetailScreenState.secondaryText,
            fontSize: 8.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _PropertyDetailScreenState.navy,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BottomItem {
  final IconData icon;
  final String label;

  const _BottomItem({
    required this.icon,
    required this.label,
  });
}