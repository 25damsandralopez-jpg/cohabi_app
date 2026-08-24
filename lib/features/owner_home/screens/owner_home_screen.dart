import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/navigation/owner_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';
import '../../../screens/properties_dashboard_screen.dart';
import '../../owner_applications/screens/owner_applications_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  bool _loading = true;
  String? _error;
  String _ownerName = 'Propietario';
  int _properties = 0;
  int _rooms = 0;
  int _availableRooms = 0;
  int _applications = 0;
  int _confirmedVisits = 0;
  double _monthlyIncome = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No hay una sesión iniciada.');

      final profile = await supabase
          .from('profiles')
          .select('first_name')
          .eq('id', user.id)
          .maybeSingle();

      final propertiesResponse = await supabase
          .from('properties')
          .select('id')
          .eq('owner_id', user.id);
      final properties = List<Map<String, dynamic>>.from(
        (propertiesResponse as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      final propertyIds = properties.map((e) => e['id'].toString()).toList();

      int rooms = 0;
      int available = 0;
      double income = 0;
      int applications = 0;
      int visits = 0;

      if (propertyIds.isNotEmpty) {
        final roomsResponse = await supabase
            .from('rooms')
            .select('id, property_id, status, monthly_price')
            .inFilter('property_id', propertyIds);
        final roomRows = List<Map<String, dynamic>>.from(
          (roomsResponse as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );
        rooms = roomRows.length;
        available = roomRows.where((r) => r['status'] == 'Disponible').length;
        income = roomRows
            .where((r) => r['status'] == 'Ocupada')
            .fold<double>(0, (sum, r) {
          final value = r['monthly_price'];
          return sum + (value is num ? value.toDouble() : double.tryParse('$value') ?? 0);
        });

        try {
          final appResponse = await supabase
              .from('applications')
              .select('id, status')
              .inFilter('property_id', propertyIds);
          final appRows = List<Map<String, dynamic>>.from(
            (appResponse as List).map((e) => Map<String, dynamic>.from(e as Map)),
          );
          applications = appRows.where((a) => !['rejected', 'withdrawn'].contains(a['status'])).length;
          visits = appRows.where((a) => a['status'] == 'visit_confirmed').length;
        } catch (_) {
          // El dashboard principal sigue funcionando aunque aún no haya solicitudes.
        }
      }

      if (!mounted) return;
      setState(() {
        _ownerName = profile?['first_name']?.toString().trim().isNotEmpty == true
            ? profile!['first_name'].toString()
            : 'Propietario';
        _properties = properties.length;
        _rooms = rooms;
        _availableRooms = available;
        _applications = applications;
        _confirmedVisits = visits;
        _monthlyIncome = income;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, $_ownerName',
                          style: const TextStyle(
                            color: CohabiColors.navy,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Resumen de tu cartera en Cohabi',
                          style: TextStyle(
                            color: CohabiColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CohabiColors.purpleSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.notifications_none_rounded, color: CohabiColors.purple),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator(color: CohabiColors.turquoise)),
                )
              else if (_error != null)
                _messageCard('No se pudo cargar el resumen', _error!)
              else ...[
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    _metric('Pisos', '$_properties', Icons.apartment_rounded, CohabiColors.blue),
                    _metric('Habitaciones', '$_rooms', Icons.bed_rounded, CohabiColors.purple),
                    _metric('Disponibles', '$_availableRooms', Icons.meeting_room_rounded, CohabiColors.turquoise),
                    _metric('Ingresos/mes', '${_monthlyIncome.toStringAsFixed(0)} €', Icons.trending_up_rounded, CohabiColors.success),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle('Acciones pendientes'),
                const SizedBox(height: 10),
                _actionCard(
                  icon: Icons.person_add_alt_1_rounded,
                  title: '$_applications candidatos activos',
                  subtitle: 'Revisa perfiles, valida candidatos y propón visitas.',
                  color: CohabiColors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OwnerApplicationsScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _actionCard(
                  icon: Icons.event_available_rounded,
                  title: '$_confirmedVisits visitas confirmadas',
                  subtitle: 'Consulta las próximas visitas desde Selección.',
                  color: CohabiColors.turquoise,
                  onTap: () => handleOwnerNavigation(context, 2),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Tus pisos'),
                const SizedBox(height: 10),
                _actionCard(
                  icon: Icons.apartment_rounded,
                  title: 'Gestionar propiedades',
                  subtitle: 'Habitaciones, fotos, ocupación y datos de cada piso.',
                  color: CohabiColors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PropertiesDashboardScreen()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: OwnerBottomNavigation(
        currentIndex: 0,
        onTap: (index) => handleOwnerNavigation(context, index),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: CohabiColors.navy,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      );

  Widget _metric(String label, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: CohabiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accent, size: 23),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: CohabiColors.navy,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: CohabiColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 12.5, height: 1.35)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: CohabiColors.purple),
          ],
        ),
      ),
    );
  }

  Widget _messageCard(String title, String subtitle) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CohabiColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 12)),
          ],
        ),
      );
}
