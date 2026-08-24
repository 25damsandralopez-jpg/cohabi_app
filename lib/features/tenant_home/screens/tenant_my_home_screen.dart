import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/navigation/tenant_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tenant_bottom_navigation.dart';
import '../../incidents/screens/tenant_new_incident_screen.dart';
import '../../notifications/screens/notifications_screen.dart';

class TenantMyHomeScreen extends StatefulWidget {
  const TenantMyHomeScreen({super.key});

  @override
  State<TenantMyHomeScreen> createState() => _TenantMyHomeScreenState();
}

class _TenantMyHomeScreenState extends State<TenantMyHomeScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _tenancy;
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _incidents = [];
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No hay una sesión iniciada.');

      final tenancyResponse = await client
          .from('tenancies')
          .select('id, property_id, room_id, start_date, end_date, monthly_rent, deposit, status, properties(name, address, city), rooms(room_number, status, available_from)')
          .eq('tenant_id', user.id)
          .inFilter('status', ['reserved', 'active', 'ending'])
          .order('created_at', ascending: false)
          .limit(1);

      final tenancyRows = List<Map<String, dynamic>>.from(
        (tenancyResponse as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );

      Map<String, dynamic>? tenancy;
      List<Map<String, dynamic>> payments = [];
      List<Map<String, dynamic>> incidents = [];
      List<Map<String, dynamic>> announcements = [];

      if (tenancyRows.isNotEmpty) {
        tenancy = tenancyRows.first;
        final tenancyId = tenancy['id'].toString();

        final paymentResponse = await client
            .from('payments')
            .select('id, concept, amount, due_date, paid_at, status')
            .eq('tenancy_id', tenancyId)
            .order('due_date', ascending: false)
            .limit(6);
        payments = List<Map<String, dynamic>>.from(
          (paymentResponse as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );

        final incidentResponse = await client
            .from('incidents')
            .select('id, title, category, priority, status, created_at')
            .eq('tenancy_id', tenancyId)
            .order('created_at', ascending: false)
            .limit(5);
        incidents = List<Map<String, dynamic>>.from(
          (incidentResponse as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );

        final announcementResponse = await client
            .from('property_announcements')
            .select('id, title, body, created_at')
            .eq('property_id', tenancy['property_id'].toString())
            .order('created_at', ascending: false)
            .limit(5);
        announcements = List<Map<String, dynamic>>.from(
          (announcementResponse as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }

      if (!mounted) return;
      setState(() {
        _tenancy = tenancy;
        _payments = payments;
        _incidents = incidents;
        _announcements = announcements;
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
      appBar: AppBar(
        backgroundColor: CohabiColors.background,
        elevation: 0,
        title: const Text('Mi Casa', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            icon: const Icon(Icons.notifications_none_rounded, color: CohabiColors.navy),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CohabiColors.turquoise))
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
              : _tenancy == null
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Text(
                          'Todavía no tienes una estancia activa. Cuando un propietario acepte tu solicitud, tu vivienda aparecerá aquí.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: CohabiColors.textSecondary, height: 1.45),
                        ),
                      ),
                    )
                  : RefreshIndicator(onRefresh: _load, child: _content()),
      bottomNavigationBar: TenantBottomNavigation(
        currentIndex: 3,
        onTap: (index) => handleTenantNavigation(context, index),
      ),
    );
  }

  Widget _content() {
    final tenancy = _tenancy!;
    final property = tenancy['properties'] is Map ? Map<String, dynamic>.from(tenancy['properties'] as Map) : <String, dynamic>{};
    final room = tenancy['rooms'] is Map ? Map<String, dynamic>.from(tenancy['rooms'] as Map) : <String, dynamic>{};

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: CohabiColors.primaryGradient, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.home_rounded, color: Colors.white, size: 34),
              const SizedBox(height: 12),
              Text(property['name']?.toString() ?? 'Tu hogar Cohabi', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text('${property['address'] ?? ''}${property['city'] != null ? ' · ${property['city']}' : ''}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('Hab. ${room['room_number'] ?? '-'}'),
                  _chip(_statusLabel(tenancy['status']?.toString() ?? 'reserved')),
                  _chip('${_money(tenancy['monthly_rent'])} €/mes'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _metric('Entrada', _text(tenancy['start_date']), Icons.login_rounded, CohabiColors.turquoise)),
            const SizedBox(width: 10),
            Expanded(child: _metric('Fianza', '${_money(tenancy['deposit'])} €', Icons.savings_outlined, CohabiColors.purple)),
          ],
        ),
        const SizedBox(height: 22),
        _sectionTitle('Avisos del piso'),
        const SizedBox(height: 10),
        if (_announcements.isEmpty)
          _emptyCard('No hay avisos nuevos del propietario.')
        else
          ..._announcements.map((a) => _announcementCard(a)),
        const SizedBox(height: 22),
        _sectionTitle('Pagos'),
        const SizedBox(height: 10),
        if (_payments.isEmpty)
          _emptyCard('Aún no hay pagos registrados.')
        else
          ..._payments.map((p) => _paymentCard(p)),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: _sectionTitle('Incidencias')),
            TextButton.icon(
              onPressed: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => TenantNewIncidentScreen(tenancy: tenancy)),
                );
                if (changed == true) _load();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nueva'),
            ),
          ],
        ),
        if (_incidents.isEmpty)
          _emptyCard('No tienes incidencias abiertas.')
        else
          ..._incidents.map((i) => _incidentCard(i)),
      ],
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
      );

  Widget _metric(String label, String value, IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: CohabiColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color),
          const SizedBox(height: 9),
          Text(value, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900, fontSize: 17)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 11)),
        ]),
      );

  Widget _announcementCard(Map<String, dynamic> a) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: CohabiColors.border)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CircleAvatar(backgroundColor: CohabiColors.purpleSoft, child: Icon(Icons.campaign_outlined, color: CohabiColors.purple)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a['title']?.toString() ?? 'Aviso', style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(a['body']?.toString() ?? '', style: const TextStyle(color: CohabiColors.textSecondary, height: 1.35)),
          ])),
        ]),
      );

  Widget _paymentCard(Map<String, dynamic> p) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: CohabiColors.border)),
        child: Row(children: [
          CircleAvatar(backgroundColor: CohabiColors.turquoiseSoft, child: Icon(p['status'] == 'paid' ? Icons.check_rounded : Icons.euro_rounded, color: CohabiColors.turquoise)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p['concept']?.toString() ?? 'Pago', style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800)),
            Text('Vence: ${_text(p['due_date'])}', style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 12)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${_money(p['amount'])} €', style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900)),
            Text(_statusLabel(p['status']?.toString() ?? 'pending'), style: TextStyle(color: p['status'] == 'paid' ? CohabiColors.success : CohabiColors.purple, fontSize: 11, fontWeight: FontWeight.w800)),
          ]),
        ]),
      );

  Widget _incidentCard(Map<String, dynamic> i) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: CohabiColors.border)),
        child: Row(children: [
          const CircleAvatar(backgroundColor: CohabiColors.purpleSoft, child: Icon(Icons.handyman_outlined, color: CohabiColors.purple)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(i['title']?.toString() ?? 'Incidencia', style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800)),
            Text('${i['category'] ?? 'Otros'} · ${_statusLabel(i['status']?.toString() ?? 'new')}', style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 12)),
          ])),
        ]),
      );

  Widget _sectionTitle(String text) => Text(text, style: const TextStyle(color: CohabiColors.navy, fontSize: 18, fontWeight: FontWeight.w900));
  Widget _emptyCard(String text) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: CohabiColors.border)), child: Text(text, style: const TextStyle(color: CohabiColors.textSecondary)));

  String _money(dynamic value) => value is num ? value.toStringAsFixed(0) : (double.tryParse(value?.toString() ?? '') ?? 0).toStringAsFixed(0);
  String _text(dynamic value) => value?.toString().trim().isNotEmpty == true ? value.toString() : 'Sin definir';
  String _statusLabel(String status) {
    const labels = {
      'reserved': 'Reservada', 'active': 'Activa', 'ending': 'Próxima salida', 'completed': 'Finalizada',
      'pending': 'Pendiente', 'paid': 'Pagado', 'partial': 'Parcial', 'late': 'Retrasado',
      'new': 'Nueva', 'reviewing': 'En revisión', 'in_progress': 'En proceso', 'resolved': 'Resuelta', 'closed': 'Cerrada',
    };
    return labels[status] ?? status;
  }
}
