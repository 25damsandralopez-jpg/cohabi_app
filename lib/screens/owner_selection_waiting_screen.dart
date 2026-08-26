import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'owner_room_candidates_screen.dart';
import 'cohabi_selection_ready_screen.dart';
import 'properties_dashboard_screen.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/owner_bottom_navigation.dart';

class OwnerSelectionWaitingScreen extends StatefulWidget {
  final List<String> propertyIds;

  const OwnerSelectionWaitingScreen({
    super.key,
    this.propertyIds = const [],
  });

  @override
  State<OwnerSelectionWaitingScreen> createState() =>
      _OwnerSelectionWaitingScreenState();
}

class _OwnerSelectionWaitingScreenState
    extends State<OwnerSelectionWaitingScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _loading = true;
  String? _errorMessage;

  List<_OwnerProperty> _properties = [];

  // ============================================================
  // INICIO
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadSelectionData();
  }

  // ============================================================
  // CARGAR DATOS REALES DESDE SUPABASE
  // ============================================================

  Future<void> _loadSelectionData() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('No hay un propietario autenticado.');
      }

      // ----------------------------------------------------------
      // 1. OBTENER LOS PISOS DEL PROPIETARIO
      // ----------------------------------------------------------

      final propertiesResponse = await _supabase
          .from('properties')
          .select('id, name, address, rooms')
          .eq('owner_id', user.id)
          .order('created_at');

      final List<Map<String, dynamic>> propertyRows =
      List<Map<String, dynamic>>.from(propertiesResponse);

      if (propertyRows.isEmpty) {
        if (!mounted) return;

        setState(() {
          _properties = [];
          _loading = false;
        });

        return;
      }

      final propertyIds = propertyRows
          .map((property) => property['id']?.toString())
          .whereType<String>()
          .toList();

      // ----------------------------------------------------------
      // 2. OBTENER HABITACIONES DE ESOS PISOS
      // ----------------------------------------------------------

      final roomsResponse = await _supabase
          .from('rooms')
          .select(
        'id, property_id, room_number, status, available_from, monthly_price',
      )
          .inFilter('property_id', propertyIds)
          .order('room_number');

      final List<Map<String, dynamic>> roomRows =
      List<Map<String, dynamic>>.from(roomsResponse);

      // ----------------------------------------------------------
      // 3. OBTENER APPLICATIONS
      //
      // Una application representa que el inquilino realmente
      // ha mostrado interés por esa habitación.
      // ----------------------------------------------------------

      final roomIds = roomRows
          .map((room) => room['id']?.toString())
          .whereType<String>()
          .toList();

      List<Map<String, dynamic>> applicationRows = [];

      if (roomIds.isNotEmpty) {
        final applicationsResponse = await _supabase
            .from('applications')
            .select('id, room_id, tenant_id, status, created_at')
            .inFilter('room_id', roomIds);

        applicationRows =
        List<Map<String, dynamic>>.from(applicationsResponse);
      }

      // ----------------------------------------------------------
      // 4. CONSTRUIR MODELO DE LA PANTALLA
      // ----------------------------------------------------------

      final List<_OwnerProperty> loadedProperties = [];

      for (final propertyRow in propertyRows) {
        final propertyId = propertyRow['id']?.toString();

        if (propertyId == null) continue;

        final propertyRooms = roomRows.where((room) {
          return room['property_id']?.toString() == propertyId;
        }).toList();

        final List<_OwnerRoom> loadedRooms = [];

        for (final roomRow in propertyRooms) {
          final roomId = roomRow['id']?.toString();

          if (roomId == null) continue;

          final roomApplications = applicationRows.where((application) {
            return application['room_id']?.toString() == roomId;
          }).toList();

          loadedRooms.add(
            _OwnerRoom(
              id: roomId,
              roomNumber: _parseRoomNumber(roomRow['room_number']),
              status: roomRow['status']?.toString(),
              candidateCount: roomApplications.length,
            ),
          );
        }

        loadedProperties.add(
          _OwnerProperty(
            id: propertyId,
            name: _propertyDisplayName(propertyRow),
            roomCount: loadedRooms.length,
            rooms: loadedRooms,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _properties = loadedProperties;
        _loading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('ERROR CARGANDO SELECCIÓN: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = error.toString();
      });
    }
  }

  int _parseRoomNumber(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _propertyDisplayName(Map<String, dynamic> property) {
    final name = property['name']?.toString().trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    final address = property['address']?.toString().trim();

    if (address != null && address.isNotEmpty) {
      return address;
    }

    return 'Mi piso';
  }

  // ============================================================
  // ¿HAY CANDIDATOS?
  // ============================================================

  bool get _hasCandidates {
    for (final property in _properties) {
      for (final room in property.rooms) {
        if (room.candidateCount > 0) {
          return true;
        }
      }
    }

    return false;
  }

  int get _totalCandidates {
    int total = 0;

    for (final property in _properties) {
      for (final room in property.rooms) {
        total += room.candidateCount;
      }
    }

    return total;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: _buildBody(context),
      ),
      bottomNavigationBar: OwnerBottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          _handleBottomNavigation(context, index);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_hasCandidates) {
      return _buildCandidatesState(context);
    }

    return _buildWaitingState(context);
  }

  // ============================================================
  // CARGANDO
  // ============================================================

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: CohabiColors.purple,
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFF3EEFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: CohabiColors.purple,
                size: 38,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No hemos podido cargar tus candidatos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CohabiColors.navy,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Comprueba la conexión e inténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CohabiColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSelectionData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Volver a intentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CohabiColors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO 1
  // ESPERANDO CANDIDATOS
  // ============================================================

  Widget _buildWaitingState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadSelectionData,
      color: CohabiColors.purple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          24,
          18,
          24,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(context),

            const SizedBox(height: 34),

            _buildReadyLabel(),

            const SizedBox(height: 10),

            const Text(
              'Esperando\ncandidatos',
              style: TextStyle(
                color: CohabiColors.navy,
                fontSize: 44,
                height: 1.02,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.4,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'En cuanto un interesado complete su registro y '
                  'muestre interés por una de tus habitaciones, '
                  'aparecerá aquí.',
              style: TextStyle(
                color: CohabiColors.textSecondary,
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 22),

            _buildWaitingIllustration(),

            const SizedBox(height: 26),

            _buildEmailReminderCard(context),

            const SizedBox(height: 20),

            _buildCandidateCounter(),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO 2
  // YA HAY CANDIDATOS
  // ============================================================

  Widget _buildCandidatesState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadSelectionData,
      color: CohabiColors.purple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(context),

            const SizedBox(height: 30),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Candidatos recibidos ✨',
                        style: TextStyle(
                          color: CohabiColors.navy,
                          fontSize: 30,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),

                      SizedBox(height: 14),

                      Text(
                        'Selecciona la habitación para la que quieres '
                            'revisar los candidatos.',
                        style: TextStyle(
                          color: CohabiColors.textSecondary,
                          fontSize: 14.5,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                _buildCandidatesHeaderIllustration(),
              ],
            ),

            const SizedBox(height: 34),

            ..._buildPropertySections(context),

            const SizedBox(height: 8),

            _buildCompatibilityInfo(),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LISTA DE PROPIEDADES
  // ============================================================

  List<Widget> _buildPropertySections(BuildContext context) {
    final widgets = <Widget>[];

    final propertiesWithCandidates = _properties.where((property) {
      return property.rooms.any(
            (room) => room.candidateCount > 0,
      );
    }).toList();

    for (int i = 0; i < propertiesWithCandidates.length; i++) {
      final property = propertiesWithCandidates[i];

      widgets.add(
        _buildPropertySection(
          context,
          property,
        ),
      );

      if (i < propertiesWithCandidates.length - 1) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 26),
            child: Divider(
              color: CohabiColors.border,
              height: 1,
            ),
          ),
        );
      } else {
        widgets.add(
          const SizedBox(height: 28),
        );
      }
    }

    return widgets;
  }

  // ============================================================
  // CABECERA COMÚN
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        const Spacer(),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      _hasCandidates
                          ? 'Aquí puedes revisar los candidatos que han mostrado interés en tus habitaciones.'
                          : 'Cohabi está esperando nuevos candidatos.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: CohabiColors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.025,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: CohabiColors.navy,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadyLabel() {
    return Row(
      children: [
        const Text(
          'TODO LISTO',
          style: TextStyle(
            color: CohabiColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(width: 7),

        Container(
          width: 19,
          height: 19,
          decoration: const BoxDecoration(
            color: CohabiColors.turquoise,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 14,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ILUSTRACIÓN ESPERA
  // ============================================================

  Widget _buildWaitingIllustration() {
    return Center(
      child: Image.asset(
        'assets/images/owner_waiting_candidates.png',
        width: double.infinity,
        height: 285,
        fit: BoxFit.contain,
      ),
    );
  }

  // ============================================================
  // ILUSTRACIÓN CANDIDATOS
  // ============================================================

  Widget _buildCandidatesHeaderIllustration() {
    return SizedBox(
      width: 155,
      height: 145,
      child: Image.asset(
        'assets/images/selection_candidates_hero.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  // ============================================================
  // RECORDATORIO EMAIL
  // ============================================================

  Widget _buildEmailReminderCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CohabiSelectionReadyScreen(
                propertyIds: widget.propertyIds,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: CohabiColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: CohabiColors.turquoiseSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: CohabiColors.turquoise,
                  size: 31,
                ),
              ),

              const SizedBox(width: 16),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Aún no has cambiado el correo?',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Sustituye el correo de contacto de tus anuncios '
                          'por el de Cohabi y empieza a recibir los',
                      style: TextStyle(
                        color: CohabiColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'mejores candidatos.',
                      style: TextStyle(
                        color: CohabiColors.purple,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: CohabiColors.purple,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTADOR ESTADO ESPERA
  // ============================================================

  Widget _buildCandidateCounter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        30,
        24,
        28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CohabiColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$_totalCandidates',
            style: const TextStyle(
              color: CohabiColors.purple,
              fontSize: 62,
              height: 0.95,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'candidatos recibidos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(
              horizontal: 40,
            ),
            color: CohabiColors.border,
          ),

          const SizedBox(height: 20),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                color: CohabiColors.textSecondary,
                size: 29,
              ),

              SizedBox(width: 13),

              Flexible(
                child: Text(
                  'Solo verás candidatos verificados\n'
                      'que cumplan tus requisitos.',
                  style: TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
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
  // PROPIEDAD
  // ============================================================

  Widget _buildPropertySection(
      BuildContext context,
      _OwnerProperty property,
      ) {
    final visibleRooms = property.rooms
        .where(
          (room) => room.candidateCount > 0,
    )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF2EDFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.apartment_rounded,
                color: CohabiColors.purple,
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${property.roomCount} habitaciones',
                    style: const TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        SizedBox(
          height: 345,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visibleRooms.length,
            separatorBuilder: (_, __) {
              return const SizedBox(width: 14);
            },
            itemBuilder: (context, index) {
              return _buildRoomCard(
                context,
                property,
                visibleRooms[index],
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TARJETA HABITACIÓN
  // ============================================================

  Widget _buildRoomCard(
      BuildContext context,
      _OwnerProperty property,
      _OwnerRoom room,
      ) {
    return Container(
      width: 195,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CohabiColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 165,
                child: Image.asset(
                  'assets/images/cohabi_home.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.94,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Hab. ${room.roomNumber}',
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                13,
                14,
                14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      _StatusDot(),

                      SizedBox(width: 7),

                      Text(
                        'Candidatos',
                        style: TextStyle(
                          color: CohabiColors.turquoise,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    '${room.candidateCount}',
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 27,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    room.candidateCount == 1
                        ? 'candidato'
                        : 'candidatos',
                    style: const TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: () {
                        _openRoomCandidates(
                          context,
                          property.name,
                          room,
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EEFF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: CohabiColors.purple.withValues(
                              alpha: 0.14,
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              color: CohabiColors.purple,
                              size: 17,
                            ),

                            SizedBox(width: 6),

                            Expanded(
                              child: Text(
                                'Ver candidatos',
                                style: TextStyle(
                                  color: CohabiColors.purple,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: CohabiColors.purple,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPLICACIÓN COMPATIBILIDAD
  // ============================================================

  Widget _buildCompatibilityInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CohabiColors.border,
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
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFF3EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              color: CohabiColors.purple,
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Los candidatos se ordenan por compatibilidad',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Analizamos más de 20 factores para mostrarte '
                      'a los inquilinos que mejor encajan en tu piso.',
                  style: TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFF3EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: CohabiColors.purple,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HABITACIÓN → CANDIDATOS
  // ============================================================

  void _openRoomCandidates(
      BuildContext context,
      String propertyName,
      _OwnerRoom room,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerRoomCandidatesScreen(
          propertyName: propertyName,
          roomNumber: room.roomNumber,
          candidateCount: room.candidateCount,

          // IMPORTANTE:
          // En el siguiente paso añadiremos roomId al constructor
          // de OwnerRoomCandidatesScreen.
        ),
      ),
    );
  }

  // ============================================================
  // NAVEGACIÓN INFERIOR
  // ============================================================

  void _handleBottomNavigation(
      BuildContext context,
      int index,
      ) {
    if (index == 2) return;

    switch (index) {
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PropertiesDashboardScreen(),
          ),
        );
        break;

      default:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                _sectionName(index),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
    }
  }

  String _sectionName(int index) {
    switch (index) {
      case 0:
        return 'Inicio';

      case 1:
        return 'Pisos';

      case 2:
        return 'Selección';

      case 3:
        return 'Inquilinos';

      case 4:
        return 'Incidencias';

      case 5:
        return 'Rentabilidad';

      default:
        return 'Sección';
    }
  }
}

// ============================================================
// MODELOS REALES DE LA PANTALLA
// ============================================================

class _OwnerProperty {
  final String id;
  final String name;
  final int roomCount;
  final List<_OwnerRoom> rooms;

  const _OwnerProperty({
    required this.id,
    required this.name,
    required this.roomCount,
    required this.rooms,
  });
}

class _OwnerRoom {
  final String id;
  final int roomNumber;
  final String? status;
  final int candidateCount;

  const _OwnerRoom({
    required this.id,
    required this.roomNumber,
    required this.status,
    required this.candidateCount,
  });
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: CohabiColors.turquoise,
        shape: BoxShape.circle,
      ),
    );
  }
}