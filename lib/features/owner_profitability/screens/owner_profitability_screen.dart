import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/navigation/owner_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';

class OwnerProfitabilityScreen extends StatefulWidget {
  const OwnerProfitabilityScreen({super.key});

  @override
  State<OwnerProfitabilityScreen> createState() => _OwnerProfitabilityScreenState();
}

class _OwnerProfitabilityScreenState extends State<OwnerProfitabilityScreen> {
  bool _loading = true;
  int _rooms = 0;
  int _occupied = 0;
  double _monthly = 0;

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
      final roomsResponse = await client.from('rooms').select('status, monthly_price').inFilter('property_id', ids);
      final rows = List<Map<String, dynamic>>.from((roomsResponse as List).map((e) => Map<String, dynamic>.from(e as Map)));
      final occupied = rows.where((e) => e['status'] == 'Ocupada').toList();
      final monthly = occupied.fold<double>(0, (sum, row) {
        final v = row['monthly_price'];
        return sum + (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);
      });
      if (!mounted) return;
      setState(() {
        _rooms = rows.length;
        _occupied = occupied.length;
        _monthly = monthly;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final occupancy = _rooms == 0 ? 0 : ((_occupied / _rooms) * 100).round();
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(
        backgroundColor: CohabiColors.background,
        elevation: 0,
        title: const Text('Rentabilidad', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CohabiColors.turquoise))
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _card('Ingresos mensuales actuales', '${_monthly.toStringAsFixed(0)} €', Icons.euro_rounded, CohabiColors.turquoise),
                const SizedBox(height: 12),
                _card('Ocupación actual', '$occupancy%', Icons.donut_large_rounded, CohabiColors.purple),
                const SizedBox(height: 12),
                _card('Habitaciones ocupadas', '$_occupied / $_rooms', Icons.bed_rounded, CohabiColors.blue),
                const SizedBox(height: 18),
                const Text(
                  'Esta primera versión calcula la rentabilidad con las habitaciones marcadas como Ocupada. Gastos, fianzas e histórico mensual se añadirán cuando tengamos el módulo de estancias y pagos.',
                  style: TextStyle(color: CohabiColors.textSecondary, height: 1.45),
                ),
              ],
            ),
      bottomNavigationBar: OwnerBottomNavigation(currentIndex: 5, onTap: (i) => handleOwnerNavigation(context, i)),
    );
  }

  Widget _card(String label, String value, IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: CohabiColors.border)),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w700))),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}
