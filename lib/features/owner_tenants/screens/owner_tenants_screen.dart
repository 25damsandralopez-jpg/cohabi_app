import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/navigation/owner_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';

class OwnerTenantsScreen extends StatefulWidget {
  const OwnerTenantsScreen({super.key});

  @override
  State<OwnerTenantsScreen> createState() => _OwnerTenantsScreenState();
}

class _OwnerTenantsScreenState extends State<OwnerTenantsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;

      final propsResponse = await client.from('properties').select('id').eq('owner_id', user.id);
      final ids = (propsResponse as List).map((e) => (e as Map)['id'].toString()).toList();
      if (ids.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final response = await client
          .from('tenancies')
          .select('id, tenant_id, property_id, room_id, start_date, end_date, monthly_rent, deposit, status, profiles!tenancies_tenant_id_fkey(first_name,last_name,phone), properties(name,city), rooms(room_number,status)')
          .inFilter('property_id', ids)
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _rows = List<Map<String, dynamic>>.from((response as List).map((e) => Map<String, dynamic>.from(e as Map)));
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkIn(Map<String, dynamic> row) async {
    await Supabase.instance.client.rpc('owner_confirm_check_in', params: {'target_tenancy_id': row['id']});
    await _load();
  }

  Future<void> _checkOut(Map<String, dynamic> row) async {
    await Supabase.instance.client.rpc('owner_confirm_check_out', params: {'target_tenancy_id': row['id']});
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(backgroundColor: CohabiColors.background, elevation: 0, title: const Text('Inquilinos', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900))),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CohabiColors.turquoise))
          : _rows.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(28), child: Text('Todavía no hay estancias. Cuando aceptes un candidato aparecerá aquí como reserva.', textAlign: TextAlign.center, style: TextStyle(color: CohabiColors.textSecondary, height: 1.4))))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(18),
                    itemCount: _rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) => _card(_rows[index]),
                  ),
                ),
      bottomNavigationBar: OwnerBottomNavigation(currentIndex: 3, onTap: (i) => handleOwnerNavigation(context, i)),
    );
  }

  Widget _card(Map<String, dynamic> row) {
    final profile = row['profiles'] is Map ? Map<String, dynamic>.from(row['profiles'] as Map) : <String, dynamic>{};
    final property = row['properties'] is Map ? Map<String, dynamic>.from(row['properties'] as Map) : <String, dynamic>{};
    final room = row['rooms'] is Map ? Map<String, dynamic>.from(row['rooms'] as Map) : <String, dynamic>{};
    final status = row['status']?.toString() ?? 'reserved';
    final name = '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: CohabiColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(backgroundColor: CohabiColors.turquoiseSoft, child: Icon(Icons.person_rounded, color: CohabiColors.turquoise)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name.isEmpty ? 'Inquilino Cohabi' : name, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text('${property['name'] ?? ''} · Hab. ${room['room_number'] ?? '-'}', style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 12)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: status == 'active' ? CohabiColors.turquoiseSoft : CohabiColors.purpleSoft, borderRadius: BorderRadius.circular(20)), child: Text(_status(status), style: TextStyle(color: status == 'active' ? CohabiColors.turquoise : CohabiColors.purple, fontSize: 11, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 6, children: [
          _small(Icons.calendar_today_outlined, 'Entrada ${row['start_date'] ?? 'sin definir'}'),
          _small(Icons.euro_rounded, '${_money(row['monthly_rent'])} €/mes'),
          _small(Icons.savings_outlined, 'Fianza ${_money(row['deposit'])} €'),
        ]),
        const SizedBox(height: 12),
        if (status == 'reserved')
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _checkIn(row), icon: const Icon(Icons.login_rounded), label: const Text('Confirmar entrada'), style: ElevatedButton.styleFrom(backgroundColor: CohabiColors.turquoise, foregroundColor: Colors.white)))
        else if (status == 'active' || status == 'ending')
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _checkOut(row), icon: const Icon(Icons.logout_rounded), label: const Text('Finalizar estancia'))),
      ]),
    );
  }

  Widget _small(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: CohabiColors.textSecondary), const SizedBox(width: 5), Text(text, style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 11.5))]);
  String _money(dynamic v) => v is num ? v.toStringAsFixed(0) : (double.tryParse(v?.toString() ?? '') ?? 0).toStringAsFixed(0);
  String _status(String s) => {'reserved': 'Reserva', 'active': 'Activa', 'ending': 'Próxima salida', 'completed': 'Finalizada', 'cancelled': 'Cancelada'}[s] ?? s;
}
