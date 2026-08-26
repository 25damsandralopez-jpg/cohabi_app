import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/navigation/owner_navigation.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../screens/property_register_screen.dart';
import '../../../screens/properties_dashboard_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../owner_applications/screens/owner_applications_screen.dart';
import '../../owner_incidents/screens/owner_incidents_screen.dart';
import '../../owner_profitability/screens/owner_profitability_screen.dart';
import '../../owner_tenants/screens/owner_tenants_screen.dart';
import '../../../screens/account_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _loading = true;
  String? _error;

  String _ownerName = 'Propietario';

  int _unreadNotifications = 0;
  int _propertyCount = 0;
  int _roomCount = 0;
  int _occupiedRoomCount = 0;
  int _availableRoomCount = 0;
  int _openIncidents = 0;
  int _candidatesPendingReview = 0;
  int _endingSoonCount = 0;

  double _monthlyIncome = 0;

  List<_PropertyDashboardItem> _properties = [];
  List<_UpcomingItem> _upcoming = [];
  List<_RecommendationItem> _recommendations = [];

  static const _months = <String>[
    '',
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay una sesión iniciada.');
      }

      // ----------------------------------------------------------
      // 1. PERFIL + NOTIFICACIONES
      // ----------------------------------------------------------
      final profile = await _supabase
          .from('profiles')
          .select('first_name, last_name')
          .eq('id', user.id)
          .maybeSingle();

      final notificationsResponse = await _supabase
          .from('notifications')
          .select('id, is_read')
          .eq('user_id', user.id);

      final notificationRows = _maps(notificationsResponse);
      final unreadNotifications =
          notificationRows.where((row) => row['is_read'] != true).length;

      // ----------------------------------------------------------
      // 2. PISOS DEL OWNER
      // ----------------------------------------------------------
      final propertiesResponse = await _supabase
          .from('properties')
          .select(
            'id, name, address, city, rooms, status, created_at',
          )
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      final propertyRows = _maps(propertiesResponse);
      final propertyIds =
          propertyRows.map((row) => row['id'].toString()).toList();

      if (propertyIds.isEmpty) {
        if (!mounted) return;
        setState(() {
          _ownerName = _safeName(profile?['first_name']);
          _unreadNotifications = unreadNotifications;
          _propertyCount = 0;
          _roomCount = 0;
          _occupiedRoomCount = 0;
          _availableRoomCount = 0;
          _openIncidents = 0;
          _candidatesPendingReview = 0;
          _endingSoonCount = 0;
          _monthlyIncome = 0;
          _properties = [];
          _upcoming = [];
          _recommendations = [];
          _loading = false;
        });
        return;
      }

      // ----------------------------------------------------------
      // 3. HABITACIONES
      // ----------------------------------------------------------
      final roomsResponse = await _supabase
          .from('rooms')
          .select(
            'id, property_id, room_number, status, available_from, monthly_price',
          )
          .inFilter('property_id', propertyIds);

      final roomRows = _maps(roomsResponse);
      final roomById = <String, Map<String, dynamic>>{
        for (final row in roomRows) row['id'].toString(): row,
      };

      final occupiedRooms =
          roomRows.where((row) => row['status'] == 'Ocupada').length;
      final availableRooms =
          roomRows.where((row) => row['status'] == 'Disponible').length;

      // ----------------------------------------------------------
      // 4. SOLICITUDES
      // ----------------------------------------------------------
      List<Map<String, dynamic>> applicationRows = [];
      try {
        final applicationsResponse = await _supabase
            .from('applications')
            .select(
              'id, tenant_id, property_id, room_id, status, created_at',
            )
            .inFilter('property_id', propertyIds);

        applicationRows = _maps(applicationsResponse);
      } catch (_) {
        // El dashboard puede seguir funcionando si aún no se ha desplegado
        // el módulo de solicitudes.
      }

      const reviewStatuses = {
        'pending',
        'under_review',
      };

      final candidatesPendingReview = applicationRows
          .where((row) => reviewStatuses.contains(row['status']))
          .length;

      // ----------------------------------------------------------
      // 5. INCIDENCIAS
      // ----------------------------------------------------------
      List<Map<String, dynamic>> incidentRows = [];
      try {
        final incidentsResponse = await _supabase
            .from('incidents')
            .select(
              'id, property_id, room_id, title, status, created_at',
            )
            .inFilter('property_id', propertyIds)
            .order('created_at', ascending: false);

        incidentRows = _maps(incidentsResponse);
      } catch (_) {
        // Igual que arriba: no rompemos Inicio por un módulo secundario.
      }

      final openIncidentRows = incidentRows.where(
        (row) => !{'resolved', 'closed'}.contains(row['status']),
      );

      // ----------------------------------------------------------
      // 6. ESTANCIAS / "CONTRATOS"
      // ----------------------------------------------------------
      List<Map<String, dynamic>> tenancyRows = [];
      try {
        final tenanciesResponse = await _supabase
            .from('tenancies')
            .select(
              'id, tenant_id, property_id, room_id, start_date, end_date, monthly_rent, status',
            )
            .inFilter('property_id', propertyIds);

        tenancyRows = _maps(tenanciesResponse);
      } catch (_) {
        // Permite usar el dashboard aunque aún no existan estancias.
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final in45Days = today.add(const Duration(days: 45));

      final liveTenancies = tenancyRows.where(
        (row) => {'reserved', 'active', 'ending'}.contains(row['status']),
      );

      final endingSoon = liveTenancies.where((row) {
        final endDate = _parseDate(row['end_date']);
        if (endDate == null) return false;
        return !endDate.isBefore(today) && !endDate.isAfter(in45Days);
      }).toList();

      final monthlyIncome = liveTenancies
          .where((row) => {'active', 'ending'}.contains(row['status']))
          .fold<double>(
            0,
            (sum, row) => sum + _toDouble(row['monthly_rent']),
          );

      // ----------------------------------------------------------
      // 7. NOMBRES DE TENANTS
      // ----------------------------------------------------------
      final tenantIds = tenancyRows
          .map((row) => row['tenant_id']?.toString())
          .whereType<String>()
          .toSet()
          .toList();

      final tenantProfiles = <String, Map<String, dynamic>>{};

      if (tenantIds.isNotEmpty) {
        try {
          final profilesResponse = await _supabase
              .from('profiles')
              .select('id, first_name, last_name')
              .inFilter('id', tenantIds);

          for (final row in _maps(profilesResponse)) {
            tenantProfiles[row['id'].toString()] = row;
          }
        } catch (_) {}
      }

      // ----------------------------------------------------------
      // 8. FOTO PRINCIPAL DE CADA PISO
      // ----------------------------------------------------------
      final imageByProperty = <String, String?>{};

      try {
        final photosResponse = await _supabase
            .from('property_photos')
            .select('property_id, storage_path, position')
            .inFilter('property_id', propertyIds)
            .order('position', ascending: true);

        final photoRows = _maps(photosResponse);

        for (final propertyId in propertyIds) {
          final photo = photoRows.cast<Map<String, dynamic>?>().firstWhere(
                (row) => row?['property_id']?.toString() == propertyId,
                orElse: () => null,
              );

          if (photo == null) {
            imageByProperty[propertyId] = null;
            continue;
          }

          final path = photo['storage_path']?.toString();
          if (path == null || path.isEmpty) {
            imageByProperty[propertyId] = null;
            continue;
          }

          try {
            imageByProperty[propertyId] = await _supabase.storage
                .from('property-photos')
                .createSignedUrl(path, 60 * 60);
          } catch (_) {
            imageByProperty[propertyId] = null;
          }
        }
      } catch (_) {
        for (final propertyId in propertyIds) {
          imageByProperty[propertyId] = null;
        }
      }

      // ----------------------------------------------------------
      // 9. TARJETAS DE PISOS
      // ----------------------------------------------------------
      final dashboardProperties = propertyRows.map((property) {
        final propertyId = property['id'].toString();
        final propertyRooms = roomRows
            .where((room) => room['property_id']?.toString() == propertyId)
            .toList();

        final occupied = propertyRooms
            .where((room) => room['status'] == 'Ocupada')
            .length;

        final incidents = openIncidentRows
            .where(
              (incident) =>
                  incident['property_id']?.toString() == propertyId,
            )
            .length;

        return _PropertyDashboardItem(
          id: propertyId,
          name: _textOr(property['name'], 'Piso'),
          city: _textOr(property['city'], ''),
          occupiedRooms: occupied,
          totalRooms: propertyRooms.length,
          openIncidents: incidents,
          availableRooms: propertyRooms.length - occupied,
          imageUrl: imageByProperty[propertyId],
        );
      }).toList();

      // ----------------------------------------------------------
      // 10. PRÓXIMAMENTE
      // ----------------------------------------------------------
      final upcoming = <_UpcomingItem>[];

      for (final tenancy in liveTenancies) {
        final propertyId = tenancy['property_id']?.toString() ?? '';
        final tenantId = tenancy['tenant_id']?.toString() ?? '';
        final roomId = tenancy['room_id']?.toString() ?? '';

        final property = propertyRows.cast<Map<String, dynamic>?>().firstWhere(
              (row) => row?['id']?.toString() == propertyId,
              orElse: () => null,
            );

        final tenant = tenantProfiles[tenantId];
        final room = roomById[roomId];

        final propertyName =
            _textOr(property?['name'], _textOr(property?['address'], 'Piso'));
        final roomNumber = _textOr(room?['room_number'], '');
        final tenantName = _shortPersonName(tenant);

        final startDate = _parseDate(tenancy['start_date']);
        final endDate = _parseDate(tenancy['end_date']);
        final status = tenancy['status']?.toString();

        if (status == 'reserved' &&
            startDate != null &&
            !startDate.isBefore(today)) {
          upcoming.add(
            _UpcomingItem(
              date: startDate,
              personName: '$tenantName entra',
              subtitle:
                  '$propertyName${roomNumber.isEmpty ? '' : ' · Hab. $roomNumber'}',
              type: _UpcomingType.entry,
            ),
          );
        }

        if ({'active', 'ending'}.contains(status) &&
            endDate != null &&
            !endDate.isBefore(today) &&
            !endDate.isAfter(today.add(const Duration(days: 90)))) {
          upcoming.add(
            _UpcomingItem(
              date: endDate,
              personName: '$tenantName finaliza contrato',
              subtitle:
                  '$propertyName${roomNumber.isEmpty ? '' : ' · Hab. $roomNumber'}',
              type: _UpcomingType.exit,
            ),
          );
        }
      }

      upcoming.sort((a, b) => a.date.compareTo(b.date));

      // ----------------------------------------------------------
      // 11. RECOMENDACIONES BASADAS EN DATOS REALES
      // ----------------------------------------------------------
      final recommendations = <_RecommendationItem>[];

      final availableRoomRows = roomRows
          .where((row) => row['status'] == 'Disponible')
          .toList();

      if (availableRoomRows.isNotEmpty) {
        availableRoomRows.sort((a, b) {
          final aDate = _parseDate(a['available_from']) ?? today;
          final bDate = _parseDate(b['available_from']) ?? today;
          return aDate.compareTo(bDate);
        });

        final room = availableRoomRows.first;
        final propertyId = room['property_id']?.toString() ?? '';
        final property = propertyRows.cast<Map<String, dynamic>?>().firstWhere(
              (row) => row?['id']?.toString() == propertyId,
              orElse: () => null,
            );

        final propertyName = _textOr(property?['name'], 'Piso');
        final roomNumber = _textOr(room['room_number'], '');
        final availableFrom = _parseDate(room['available_from']);
        final daysAvailable = availableFrom == null
            ? null
            : today.difference(availableFrom).inDays;

        final candidates = applicationRows.where((application) {
          return application['room_id']?.toString() ==
                  room['id']?.toString() &&
              !{'rejected', 'withdrawn', 'accepted'}
                  .contains(application['status']);
        }).length;

        recommendations.add(
          _RecommendationItem(
            icon: Icons.home_work_outlined,
            color: CohabiColors.turquoise,
            softColor: CohabiColors.turquoiseSoft,
            title:
                '$propertyName${roomNumber.isEmpty ? '' : ' · Habitación $roomNumber'}',
            description: [
              if (daysAvailable != null && daysAvailable > 0)
                'Lleva $daysAvailable días disponible.',
              if (candidates > 0)
                'Tienes $candidates candidato${candidates == 1 ? '' : 's'} activo${candidates == 1 ? '' : 's'}.',
              if ((daysAvailable == null || daysAvailable <= 0) &&
                  candidates == 0)
                'Está disponible para recibir nuevos candidatos.',
            ].join(' '),
            action: 'Ver candidatos',
            onTap: () => _openApplications(),
          ),
        );
      }

      if (openIncidentRows.isNotEmpty) {
        final incident = openIncidentRows.first;
        final propertyId = incident['property_id']?.toString() ?? '';
        final property = propertyRows.cast<Map<String, dynamic>?>().firstWhere(
              (row) => row?['id']?.toString() == propertyId,
              orElse: () => null,
            );

        recommendations.add(
          _RecommendationItem(
            icon: Icons.build_circle_outlined,
            color: CohabiColors.orange,
            softColor: CohabiColors.orangeSoft,
            title: _textOr(property?['name'], 'Revisar incidencia'),
            description:
                'Tienes una incidencia pendiente: ${_textOr(incident['title'], 'requiere atención')}.',
            action: 'Ver detalle',
            onTap: _goToIncidents,
          ),
        );
      }

      if (endingSoon.isNotEmpty) {
        final tenancy = endingSoon.first;
        final propertyId = tenancy['property_id']?.toString() ?? '';
        final property = propertyRows.cast<Map<String, dynamic>?>().firstWhere(
              (row) => row?['id']?.toString() == propertyId,
              orElse: () => null,
            );

        final endDate = _parseDate(tenancy['end_date']);
        final days = endDate == null ? 0 : endDate.difference(today).inDays;

        recommendations.add(
          _RecommendationItem(
            icon: Icons.calendar_month_outlined,
            color: CohabiColors.purple,
            softColor: CohabiColors.purpleSoft,
            title: _textOr(property?['name'], 'Próxima salida'),
            description:
                'Una estancia finaliza ${days == 0 ? 'hoy' : 'en $days días'}. Puedes preparar la siguiente ocupación.',
            action: 'Ver inquilinos',
            onTap: () => _openTenants(),
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _ownerName = _safeName(profile?['first_name']);
        _unreadNotifications = unreadNotifications;

        _propertyCount = propertyRows.length;
        _roomCount = roomRows.length;
        _occupiedRoomCount = occupiedRooms;
        _availableRoomCount = availableRooms;
        _openIncidents = openIncidentRows.length;
        _candidatesPendingReview = candidatesPendingReview;
        _endingSoonCount = endingSoon.length;

        _monthlyIncome = monthlyIncome;

        _properties = dashboardProperties.take(3).toList();
        _upcoming = upcoming.take(3).toList();
        _recommendations = recommendations.take(3).toList();

        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  List<Map<String, dynamic>> _maps(dynamic response) {
    return List<Map<String, dynamic>>.from(
      (response as List).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );
  }

  String _safeName(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? 'Propietario' : text;
  }

  String _textOr(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime? _parseDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  String _shortPersonName(Map<String, dynamic>? profile) {
    if (profile == null) return 'Inquilino';

    final first = _textOr(profile['first_name'], 'Inquilino');
    final last = profile['last_name']?.toString().trim() ?? '';

    if (last.isEmpty) return first;
    return '$first ${last.substring(0, 1).toUpperCase()}.';
  }

  String _money(double value) {
    final rounded = value.round().toString();
    final chars = rounded.split('').reversed.toList();
    final result = <String>[];

    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) result.add('.');
      result.add(chars[i]);
    }

    return '${result.reversed.join()} €';
  }

  int _daysFromToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.difference(today).inDays;
  }

  // ---------------------------------------------------------------------------
  // NAVEGACIÓN
  // El dashboard tiene 5 pestañas como la referencia visual.
  // Internamente reutilizamos los índices actuales del proyecto:
  // 0 Inicio, 1 Pisos, 3 Inquilinos, 5 Rentabilidad, 6 Cuenta.
  // ---------------------------------------------------------------------------


  void _openAttention() {
    if (_openIncidents > 0) {
      _goToIncidents();
      return;
    }
    if (_candidatesPendingReview > 0) {
      _openApplications();
      return;
    }
    if (_availableRoomCount > 0) {
      _openProperties();
      return;
    }
    if (_endingSoonCount > 0) {
      _openTenants();
      return;
    }
  }

  void _openProperties() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PropertiesDashboardScreen(),
      ),
    );
  }

  void _openApplications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OwnerApplicationsScreen(),
      ),
    );
  }

  void _openTenants() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OwnerTenantsScreen(),
      ),
    );
  }

  void _goToIncidents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OwnerIncidentsScreen(),
      ),
    );
  }

  void _openProfitability() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OwnerProfitabilityScreen(),
      ),
    );
  }

  void _openAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AccountScreen(),
      ),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  void _openAddProperty() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PropertyRegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          color: CohabiColors.purple,
          child: _loading
              ? const _DashboardLoading()
              : _error != null
                  ? _DashboardError(
                      error: _error!,
                      onRetry: _loadDashboard,
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 760;

                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            wide ? 44 : 20,
                            24,
                            wide ? 44 : 20,
                            34,
                          ),
                          children: [
                            _buildHeader(wide),
                            const SizedBox(height: 30),
                            _buildAttentionSection(wide),
                            const SizedBox(height: 28),
                            _buildPortfolioSection(wide),
                            const SizedBox(height: 28),
                            _buildUpcomingSection(),
                            const SizedBox(height: 24),
                            _buildRecommendationsSection(wide),
                            const SizedBox(height: 28),
                            _buildPropertiesSection(),
                            const SizedBox(height: 24),
                            _buildQuickActions(wide),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
        ),
      ),
      bottomNavigationBar: OwnerBottomNavigation(
        currentIndex: 0,
        onTap: (index) => handleOwnerNavigation(context, index),
      ),
    );
  }

  Widget _buildHeader(bool wide) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buenos días, $_ownerName 👋',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: wide ? 34 : 28,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Esto es lo que está pasando en tus propiedades.',
                style: TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        _NotificationButton(
          count: _unreadNotifications,
          onTap: _openNotifications,
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: _openAccount,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: CohabiColors.purpleSoft,
              shape: BoxShape.circle,
              border: Border.all(color: CohabiColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              _ownerName.isEmpty
                  ? 'P'
                  : _ownerName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: CohabiColors.purple,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttentionSection(bool wide) {
    final cards = <Widget>[
      _AttentionCard(
        icon: Icons.priority_high_rounded,
        accent: const Color(0xFFFF3D4F),
        soft: const Color(0xFFFFF0F2),
        title: '$_openIncidents incidencias abiertas',
        subtitle: _openIncidents == 0
            ? 'No tienes incidencias pendientes.'
            : 'Revisa y actualiza las incidencias que siguen abiertas.',
        action: 'Ver incidencias',
        onTap: _goToIncidents,
      ),
      _AttentionCard(
        icon: Icons.home_work_outlined,
        accent: const Color(0xFFFF7A20),
        soft: const Color(0xFFFFF2E9),
        title: '$_availableRoomCount habitaciones sin alquilar',
        subtitle: _availableRoomCount == 0
            ? 'Todas tus habitaciones están ocupadas.'
            : 'Hay habitaciones disponibles para nuevos candidatos.',
        action: 'Buscar candidatos',
        onTap: _openApplications,
      ),
      _AttentionCard(
        icon: Icons.people_alt_outlined,
        accent: CohabiColors.purple,
        soft: CohabiColors.purpleSoft,
        title: '$_candidatesPendingReview candidatos esperando revisión',
        subtitle: _candidatesPendingReview == 0
            ? 'No tienes perfiles pendientes ahora mismo.'
            : 'Tienes perfiles nuevos que requieren revisión.',
        action: 'Ver candidatos',
        onTap: _openApplications,
      ),
      _AttentionCard(
        icon: Icons.calendar_month_outlined,
        accent: const Color(0xFF2D7FF9),
        soft: const Color(0xFFEAF3FF),
        title:
            '$_endingSoonCount ${_endingSoonCount == 1 ? 'contrato próximo' : 'contratos próximos'} a finalizar',
        subtitle: _endingSoonCount == 0
            ? 'No hay salidas previstas en los próximos 45 días.'
            : 'Planifica las próximas salidas y sustituciones.',
        action: 'Revisar contratos',
        onTap: _openTenants,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Necesita tu atención',
          action: 'Revisar pendientes (${_openIncidents + _availableRoomCount + _candidatesPendingReview + _endingSoonCount})',
          onTap: _openAttention,
        ),
        const SizedBox(height: 13),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i != cards.length - 1) const SizedBox(width: 12),
              ],
            ],
          )
        else
          SizedBox(
            height: 242,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) => SizedBox(
                width: 210,
                child: cards[index],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPortfolioSection(bool wide) {
    final metrics = <Widget>[
      _PortfolioMetric(
        icon: Icons.apartment_rounded,
        iconColor: CohabiColors.turquoise,
        iconBackground: CohabiColors.turquoiseSoft,
        value: '$_propertyCount',
        label: 'Pisos',
      ),
      _PortfolioMetric(
        icon: Icons.bed_outlined,
        iconColor: const Color(0xFF2878F0),
        iconBackground: const Color(0xFFEAF3FF),
        value: '$_occupiedRoomCount / $_roomCount',
        label: 'Habitaciones\nocupadas',
      ),
      _PortfolioMetric(
        icon: Icons.handyman_outlined,
        iconColor: const Color(0xFFE73149),
        iconBackground: const Color(0xFFFFEDF0),
        value: '$_openIncidents',
        label: 'Incidencias\nabiertas',
      ),
      _PortfolioMetric(
        icon: Icons.euro_rounded,
        iconColor: CohabiColors.purple,
        iconBackground: CohabiColors.purpleSoft,
        value: _money(_monthlyIncome),
        label: 'Ingresos\neste mes',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Resumen de tu cartera',
          trailingIcon: Icons.info_outline_rounded,
        ),
        const SizedBox(height: 13),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 4 : 2;
            final width = (constraints.maxWidth - ((columns - 1) * 12)) / columns;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: metrics
                  .map(
                    (metric) => SizedBox(
                      width: width,
                      child: metric,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Próximamente',
          action: 'Ver calendario',
          onTap: _openTenants,
        ),
        const SizedBox(height: 13),
        Container(
          decoration: _whiteCardDecoration(radius: 18),
          child: _upcoming.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(22),
                  child: _EmptyInline(
                    icon: Icons.event_available_outlined,
                    text: 'No tienes entradas o salidas próximas.',
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < _upcoming.length; i++) ...[
                      _UpcomingRow(
                        item: _upcoming[i],
                        monthLabel: _months[_upcoming[i].date.month],
                        daysFromToday: _daysFromToday(_upcoming[i].date),
                        onTap: _openTenants,
                      ),
                      if (i != _upcoming.length - 1)
                        const Divider(
                          height: 1,
                          color: CohabiColors.border,
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(bool wide) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDCD8FF),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7F4FF),
            Color(0xFFFFFFFF),
            Color(0xFFF1FBFA),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: CohabiColors.purple,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cohabi te recomienda',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Oportunidades detectadas con los datos actuales de tu cartera.',
                      style: TextStyle(
                        color: CohabiColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (_recommendations.isNotEmpty)
                Text(
                  'Ver todas (${_recommendations.length})',
                  style: const TextStyle(
                    color: CohabiColors.purple,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 17),
          if (_recommendations.isEmpty)
            const _EmptyInline(
              icon: Icons.check_circle_outline_rounded,
              text: 'Todo está al día. No hay recomendaciones pendientes.',
            )
          else if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _recommendations.length; i++) ...[
                  Expanded(
                    child: _RecommendationCard(
                      item: _recommendations[i],
                    ),
                  ),
                  if (i != _recommendations.length - 1)
                    const SizedBox(width: 14),
                ],
              ],
            )
          else
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recommendations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, index) => SizedBox(
                  width: 265,
                  child: _RecommendationCard(
                    item: _recommendations[index],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPropertiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Tus pisos',
          action: 'Ver todos mis pisos',
          onTap: _openProperties,
        ),
        const SizedBox(height: 13),
        Container(
          decoration: _whiteCardDecoration(radius: 18),
          child: _properties.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const _EmptyInline(
                        icon: Icons.apartment_outlined,
                        text: 'Todavía no has añadido ningún piso.',
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _openAddProperty,
                        icon: const Icon(Icons.add_home_work_outlined),
                        label: const Text('Añadir mi primer piso'),
                        style: FilledButton.styleFrom(
                          backgroundColor: CohabiColors.turquoise,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < _properties.length; i++) ...[
                      _PropertyRow(
                        property: _properties[i],
                        onTap: _openProperties,
                      ),
                      if (i != _properties.length - 1)
                        const Divider(
                          height: 1,
                          color: CohabiColors.border,
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool wide) {
    final actions = [
      _QuickAction(
        icon: Icons.add_home_work_outlined,
        title: 'Añadir piso',
        accent: CohabiColors.turquoise,
        soft: CohabiColors.turquoiseSoft,
        onTap: _openAddProperty,
      ),
      _QuickAction(
        icon: Icons.people_alt_outlined,
        title: 'Buscar inquilino',
        accent: CohabiColors.purple,
        soft: CohabiColors.purpleSoft,
        onTap: _openApplications,
      ),
      _QuickAction(
        icon: Icons.handyman_outlined,
        title: 'Gestionar incidencia',
        accent: CohabiColors.orange,
        soft: CohabiColors.orangeSoft,
        onTap: _goToIncidents,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _whiteCardDecoration(radius: 20),
      child: wide
          ? Row(
              children: [
                const SizedBox(
                  width: 180,
                  child: Text(
                    '¿Qué quieres\nhacer hoy?',
                    style: TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                for (int i = 0; i < actions.length; i++) ...[
                  Expanded(child: actions[i]),
                  if (i != actions.length - 1)
                    const SizedBox(width: 12),
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Qué quieres hacer hoy?',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      Expanded(child: actions[i]),
                      if (i != actions.length - 1)
                        const SizedBox(width: 8),
                    ],
                  ],
                ),
              ],
            ),
    );
  }

  BoxDecoration _whiteCardDecoration({double radius = 18}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: CohabiColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x09071747),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    );
  }
}

// =============================================================================
// COMPONENTES
// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.action,
    this.onTap,
    this.trailingIcon,
  });

  final String title;
  final String? action;
  final VoidCallback? onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: CohabiColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailingIcon != null)
          Icon(
            trailingIcon,
            size: 18,
            color: CohabiColors.textSecondary,
          ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: CohabiColors.purple,
            ),
            child: Row(
              children: [
                Text(
                  action!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: CohabiColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C071747),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: CohabiColors.navy,
              size: 23,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -3,
              right: -2,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: const BoxDecoration(
                  color: CohabiColors.purple,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.icon,
    required this.accent,
    required this.soft,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final Color soft;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withOpacity(.20),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07071747),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: soft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: accent,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CohabiColors.navy,
              fontSize: 15,
              height: 1.22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CohabiColors.textSecondary,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                backgroundColor: soft,
                foregroundColor: accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      action,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioMetric extends StatelessWidget {
  const _PortfolioMetric({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 103),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: CohabiColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06071747),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({
    required this.item,
    required this.monthLabel,
    required this.daysFromToday,
    required this.onTap,
  });

  final _UpcomingItem item;
  final String monthLabel;
  final int daysFromToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final entry = item.type == _UpcomingType.entry;
    final accent = entry
        ? CohabiColors.turquoise
        : CohabiColors.orange;
    final soft = entry
        ? CohabiColors.turquoiseSoft
        : CohabiColors.orangeSoft;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(
                    '${item.date.day}',
                    style: TextStyle(
                      color: accent,
                      fontSize: 25,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    monthLabel,
                    style: const TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 9.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: CohabiColors.purpleSoft,
                shape: BoxShape.circle,
                border: Border.all(color: CohabiColors.border),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: CohabiColors.purple,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.personName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: soft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry ? 'Entrada' : 'Salida',
                style: TextStyle(
                  color: accent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              daysFromToday <= 0
                  ? 'hoy'
                  : 'en $daysFromToday días',
              style: const TextStyle(
                color: CohabiColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.chevron_right_rounded,
              color: CohabiColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.item,
  });

  final _RecommendationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.72),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.softColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: CohabiColors.navy,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Text(
              item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CohabiColors.textSecondary,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: item.onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              backgroundColor: item.softColor,
              foregroundColor: item.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    item.action,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  const _PropertyRow({
    required this.property,
    required this.onTap,
  });

  final _PropertyDashboardItem property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ratio = property.totalRooms == 0
        ? 0.0
        : property.occupiedRooms / property.totalRooms;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: SizedBox(
                width: 105,
                height: 64,
                child: property.imageUrl == null
                    ? Container(
                        color: const Color(0xFFF0F2F7),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: CohabiColors.textMuted,
                          size: 30,
                        ),
                      )
                    : Image.network(
                        property.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF0F2F7),
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: CohabiColors.textMuted,
                            size: 30,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    property.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 45,
              height: 45,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: ratio.clamp(0, 1),
                    strokeWidth: 4,
                    backgroundColor: CohabiColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      CohabiColors.success,
                    ),
                  ),
                  Text(
                    property.totalRooms == 0
                        ? '—'
                        : '${property.occupiedRooms}/${property.totalRooms}',
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (property.openIncidents == 0)
                    const _StatusPill(
                      text: 'Todo en orden',
                      foreground: CohabiColors.success,
                      background: CohabiColors.turquoiseSoft,
                    )
                  else
                    _StatusPill(
                      text:
                          '${property.openIncidents} incidencia${property.openIncidents == 1 ? '' : 's'}',
                      foreground: CohabiColors.orange,
                      background: CohabiColors.orangeSoft,
                    ),
                  if (property.availableRooms > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${property.availableRooms} ${property.availableRooms == 1 ? 'habitación libre' : 'habitaciones libres'}',
                      style: const TextStyle(
                        color: CohabiColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: CohabiColors.textSecondary,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.foreground,
    required this.background,
  });

  final String text;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.accent,
    required this.soft,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final Color soft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 85),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: soft.withOpacity(.60),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accent.withOpacity(.22),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: accent,
              size: 25,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: CohabiColors.purple,
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(
          Icons.error_outline_rounded,
          size: 42,
          color: CohabiColors.coral,
        ),
        const SizedBox(height: 14),
        const Text(
          'No se pudo cargar Inicio',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CohabiColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: CohabiColors.purple,
            ),
            child: const Text('Reintentar'),
          ),
        ),
      ],
    );
  }
}

class _EmptyInline extends StatelessWidget {
  const _EmptyInline({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: CohabiColors.textMuted,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// MODELOS LOCALES DEL DASHBOARD
// =============================================================================

class _PropertyDashboardItem {
  const _PropertyDashboardItem({
    required this.id,
    required this.name,
    required this.city,
    required this.occupiedRooms,
    required this.totalRooms,
    required this.openIncidents,
    required this.availableRooms,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String city;
  final int occupiedRooms;
  final int totalRooms;
  final int openIncidents;
  final int availableRooms;
  final String? imageUrl;
}

enum _UpcomingType {
  entry,
  exit,
}

class _UpcomingItem {
  const _UpcomingItem({
    required this.date,
    required this.personName,
    required this.subtitle,
    required this.type,
  });

  final DateTime date;
  final String personName;
  final String subtitle;
  final _UpcomingType type;
}

class _RecommendationItem {
  const _RecommendationItem({
    required this.icon,
    required this.color,
    required this.softColor,
    required this.title,
    required this.description,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color softColor;
  final String title;
  final String description;
  final String action;
  final VoidCallback onTap;
}
