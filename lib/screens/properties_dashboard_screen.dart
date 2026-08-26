import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cohabi_selection_screen.dart';
import '../core/theme/app_colors.dart';
import '../core/navigation/owner_navigation.dart';
import '../core/widgets/owner_bottom_navigation.dart';
import 'property_register_screen.dart';
import '../features/owner_properties/screens/owner_property_detail_screen.dart';

class PropertiesDashboardScreen extends StatefulWidget {
  const PropertiesDashboardScreen({super.key});

  @override
  State<PropertiesDashboardScreen> createState() =>
      _PropertiesDashboardScreenState();
}

class _PropertiesDashboardScreenState extends State<PropertiesDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  final List<_PropertySummary> _properties = [];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('No hay un usuario autenticado.');
      }

      // =========================================================
      // 1. CARGAMOS LOS PISOS DEL PROPIETARIO
      // =========================================================

      final propertiesResponse = await supabase
          .from('properties')
          .select('id, name, city, rooms')
          .eq('owner_id', user.id);

      final List<dynamic> propertiesData = propertiesResponse;

      final List<_PropertySummary> loadedProperties = [];

      // =========================================================
      // 2. PARA CADA PISO:
      //    - habitaciones configuradas/disponibles
      //    - habitaciones máximas
      //    - foto principal
      // =========================================================

      for (final property in propertiesData) {
        final propertyId = property['id'] as String;

        final roomsResponse = await supabase
            .from('rooms')
            .select('id, status')
            .eq('property_id', propertyId);

        final List<dynamic> roomsData = roomsResponse;

        // Número TOTAL de habitaciones declarado al crear el piso.
        final totalRooms = property['rooms'] as int? ?? 0;

        // Habitaciones que ya existen en rooms y están disponibles.
        final availableRooms = roomsData.where((room) {
          return room['status'] == 'Disponible';
        }).length;

        // =======================================================
        // FOTO PRINCIPAL DEL PISO
        // =======================================================

        String? imageUrl;

        final photosResponse = await supabase
            .from('property_photos')
            .select('storage_path, position')
            .eq('property_id', propertyId)
            .order('position', ascending: true)
            .limit(1);

        final List<dynamic> photosData = photosResponse;

        if (photosData.isNotEmpty) {
          final storagePath = photosData.first['storage_path'] as String?;

          if (storagePath != null && storagePath.isNotEmpty) {
            imageUrl = await supabase.storage
                .from('property-photos')
                .createSignedUrl(storagePath, 3600);
          }
        }

        loadedProperties.add(
          _PropertySummary(
            id: propertyId,
            name: property['name']?.toString() ?? 'Mi piso',
            city: property['city']?.toString() ?? '',
            totalRooms: totalRooms,
            availableRooms: availableRooms,
            imageUrl: imageUrl,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _properties
          ..clear()
          ..addAll(loadedProperties);

        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _loadProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
            children: [
              // ==================================================
              // PROPIEDAD CREADA
              // ==================================================

              // ==================================================
              // TÍTULO DEL RESUMEN
              // ==================================================
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mis propiedades',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==================================================
              // CONTENIDO
              // ==================================================
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 70),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: CohabiColors.turquoise,
                    ),
                  ),
                )
              else if (_errorMessage != null)
                _buildErrorBox()
              else if (_properties.isEmpty)
                _buildEmptyState()
              else
                ..._properties.map(
                  (property) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildPropertyCard(property),
                  ),
                ),

              const SizedBox(height: 4),

              // ==================================================
              // AÑADIR OTRO PISO
              // ==================================================
              _buildAddPropertyButton(),

              const SizedBox(height: 18),

              // ==================================================
              // COHABI SELECCIÓN
              // ==================================================
              _buildCohabiSelectionButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: OwnerBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          handleOwnerNavigation(context, index);
        },
      ),
    );
  }

  // ============================================================
  // CABECERA
  // ============================================================


  // ============================================================
  // TARJETA DE PROPIEDAD
  // ============================================================

  Widget _buildPropertyCard(_PropertySummary property) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OwnerPropertyDetailScreen(
              propertyId: property.id,
            ),
          ),
        );

        if (mounted) {
          await _refresh();
        }
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ====================================================
            // FOTO + NOMBRE
            // ====================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyImage(property),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              property.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CohabiColors.navy,
                                fontSize: 19,
                                height: 1.1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF53629B),
                            size: 26,
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFF6573A9),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.city.isEmpty
                                  ? 'Sin ciudad'
                                  : property.city,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6573A9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ====================================================
            // 4 MÉTRICAS
            // ====================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildStatistic(
                    icon: Icons.bed_outlined,
                    title: 'Habitaciones\ndisponibles',
                    value:
                        '${property.availableRooms} / ${property.totalRooms}',
                    accent: CohabiColors.turquoise,
                  ),
                ),

                _verticalDivider(),

                Expanded(
                  child: _buildStatistic(
                    icon: Icons.person_outline_rounded,
                    title: 'Inquilinos',
                    value: '0',
                    accent: CohabiColors.purple,
                  ),
                ),

                _verticalDivider(),

                Expanded(
                  child: _buildStatistic(
                    icon: Icons.euro_rounded,
                    title: 'Generando\ningresos',
                    value: '0 €/mes',
                    accent: const Color(0xFFFF951F),
                  ),
                ),

                _verticalDivider(),

                Expanded(
                  child: _buildStatistic(
                    icon: Icons.warning_amber_rounded,
                    title: 'Incidencias',
                    value: '0',
                    accent: const Color(0xFFFF6674),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(color: Color(0xFFE9EAF0), height: 1),

            const SizedBox(height: 15),

            // ====================================================
            // ENTRADAS / SALIDAS
            // ====================================================
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _EmptyEvent(
                    icon: Icons.calendar_today_outlined,
                    title: 'Próximas entradas',
                    text: 'No hay entradas programadas',
                    accent: CohabiColors.turquoise,
                  ),
                ),

                SizedBox(width: 18),

                Expanded(
                  child: _EmptyEvent(
                    icon: Icons.event_busy_outlined,
                    title: 'Próximas salidas',
                    text: 'No hay salidas programadas',
                    accent: Color(0xFFFF6674),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImage(_PropertySummary property) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 120,
        height: 105,
        color: CohabiColors.turquoise.withOpacity(0.06),
        child: property.imageUrl != null
            ? Image.network(
                property.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.apartment_rounded,
                    size: 40,
                    color: CohabiColors.turquoise,
                  );
                },
              )
            : const Icon(
                Icons.apartment_rounded,
                size: 40,
                color: CohabiColors.turquoise,
              ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 92, color: const Color(0xFFE8EAF1));
  }

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================

  Widget _buildStatistic({
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withOpacity(0.10),
          ),
          child: Icon(icon, color: accent, size: 21),
        ),

        const SizedBox(height: 7),

        SizedBox(
          height: 30,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF536199),
                fontSize: 10.5,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AÑADIR OTRO PISO
  // ============================================================

  Widget _buildAddPropertyButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PropertyRegisterScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFCDD2E1), width: 1.3),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: CohabiColors.turquoise.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add_home_outlined,
                color: CohabiColors.turquoise,
                size: 31,
              ),
            ),

            const SizedBox(width: 17),

            const Expanded(
              child: Text(
                'Añadir otro piso',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: CohabiColors.navy,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COHABI SELECCIÓN
  // ============================================================

  Widget _buildCohabiSelectionButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CohabiSelectionScreen()),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
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
            CircleAvatar(
              radius: 29,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: CohabiColors.purple,
                size: 30,
              ),
            ),

            SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usar Cohabi Selección',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Encuentra a tu inquilino ideal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 29),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E4EC)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 40,
          ),

          const SizedBox(height: 12),

          const Text(
            'No se pudieron cargar tus pisos.',
            style: TextStyle(
              color: CohabiColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: _refresh,
            child: const Text('Volver a intentar'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIN PISOS
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E4EC)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.home_work_outlined,
            color: CohabiColors.turquoise,
            size: 44,
          ),

          SizedBox(height: 12),

          Text(
            'Todavía no tienes pisos',
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODELO INTERNO DEL DASHBOARD
// ============================================================

class _PropertySummary {
  final String id;
  final String name;
  final String city;
  final int totalRooms;
  final int availableRooms;
  final String? imageUrl;

  const _PropertySummary({
    required this.id,
    required this.name,
    required this.city,
    required this.totalRooms,
    required this.availableRooms,
    required this.imageUrl,
  });
}

// ============================================================
// BLOQUE DE PRÓXIMAS ENTRADAS / SALIDAS
// ============================================================

class _EmptyEvent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color accent;

  const _EmptyEvent({
    required this.icon,
    required this.title,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accent, size: 19),

            const SizedBox(width: 7),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        Text(
          text,
          style: const TextStyle(
            color: CohabiColors.textSecondary,
            fontSize: 10.5,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
