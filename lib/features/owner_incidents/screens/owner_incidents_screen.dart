import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/navigation/owner_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';

class OwnerIncidentsScreen extends StatefulWidget {
  const OwnerIncidentsScreen({super.key});

  @override
  State<OwnerIncidentsScreen> createState() => _OwnerIncidentsScreenState();
}

class _OwnerIncidentsScreenState extends State<OwnerIncidentsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _rows = [];
  String _filter = 'open';

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
      final props = await client.from('properties').select('id').eq('owner_id', user.id);
      final ids = (props as List).map((e) => (e as Map)['id'].toString()).toList();
      if (ids.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final response = await client
          .from('incidents')
          .select('id, title, description, category, priority, status, created_at, property_id, room_id, properties(name), rooms(room_number), profiles!incidents_tenant_id_fkey(first_name,last_name)')
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

  Future<void> _setStatus(String id, String status) async {
    await Supabase.instance.client.from('incidents').update({'status': status, if (status == 'resolved') 'resolved_at': DateTime.now().toUtc().toIso8601String()}).eq('id', id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _rows.where((r) => _filter == 'all' || (_filter == 'open' ? !['resolved', 'closed'].contains(r['status']) : ['resolved', 'closed'].contains(r['status']))).toList();
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(backgroundColor: CohabiColors.background, elevation: 0, title: const Text('Incidencias', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900))),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CohabiColors.turquoise))
          : Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                child: SegmentedButton<String>(
                  segments: const [ButtonSegment(value: 'open', label: Text('Abiertas')), ButtonSegment(value: 'closed', label: Text('Resueltas')), ButtonSegment(value: 'all', label: Text('Todas'))],
                  selected: {_filter},
                  onSelectionChanged: (v) => setState(() => _filter = v.first),
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('No hay incidencias en este estado.', style: TextStyle(color: CohabiColors.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(18),
                          itemCount: visible.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, index) => _card(visible[index]),
                        ),
                      ),
              ),
            ]),
      bottomNavigationBar: OwnerBottomNavigation(currentIndex: 4, onTap: (i) => handleOwnerNavigation(context, i)),
    );
  }

  Widget _card(Map<String, dynamic> row) {
    final property = row['properties'] is Map ? Map<String, dynamic>.from(row['properties'] as Map) : <String, dynamic>{};
    final room = row['rooms'] is Map ? Map<String, dynamic>.from(row['rooms'] as Map) : <String, dynamic>{};
    final profile = row['profiles'] is Map ? Map<String, dynamic>.from(row['profiles'] as Map) : <String, dynamic>{};
    final name = '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();
    final status = row['status']?.toString() ?? 'new';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: CohabiColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(backgroundColor: _priorityColor(row['priority']).withOpacity(.12), child: Icon(Icons.handyman_outlined, color: _priorityColor(row['priority']))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(row['title']?.toString() ?? 'Incidencia', style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900)),
            Text('${property['name'] ?? ''}${room['room_number'] != null ? ' · Hab. ${room['room_number']}' : ''}', style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 12)),
          ])),
          Text(_status(status), style: const TextStyle(color: CohabiColors.purple, fontSize: 11, fontWeight: FontWeight.w800)),
        ]),
        if (name.isNotEmpty) ...[const SizedBox(height: 8), Text('Inquilino: $name', style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 12))],
        if (row['description']?.toString().trim().isNotEmpty == true) ...[const SizedBox(height: 8), Text(row['description'].toString(), style: const TextStyle(color: CohabiColors.navy, height: 1.35))],
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          if (status == 'new') OutlinedButton(onPressed: () => _setStatus(row['id'].toString(), 'reviewing'), child: const Text('Revisar')),
          if (status == 'reviewing') OutlinedButton(onPressed: () => _setStatus(row['id'].toString(), 'in_progress'), child: const Text('En proceso')),
          if (!['resolved', 'closed'].contains(status)) ElevatedButton(onPressed: () => _setStatus(row['id'].toString(), 'resolved'), style: ElevatedButton.styleFrom(backgroundColor: CohabiColors.turquoise, foregroundColor: Colors.white), child: const Text('Resolver')),
          if (status == 'resolved') OutlinedButton(onPressed: () => _setStatus(row['id'].toString(), 'closed'), child: const Text('Cerrar')),
        ]),
      ]),
    );
  }

  Color _priorityColor(dynamic p) => p == 'urgent' ? Colors.redAccent : p == 'high' ? Colors.orange : CohabiColors.turquoise;
  String _status(String s) => {'new': 'Nueva', 'reviewing': 'En revisión', 'in_progress': 'En proceso', 'resolved': 'Resuelta', 'closed': 'Cerrada'}[s] ?? s;
}
