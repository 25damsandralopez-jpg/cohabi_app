import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';

class TenantNewIncidentScreen extends StatefulWidget {
  final Map<String, dynamic> tenancy;

  const TenantNewIncidentScreen({super.key, required this.tenancy});

  @override
  State<TenantNewIncidentScreen> createState() => _TenantNewIncidentScreenState();
}

class _TenantNewIncidentScreenState extends State<TenantNewIncidentScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _category = 'Otros';
  String _priority = 'normal';
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No hay sesión.');
      await client.from('incidents').insert({
        'tenancy_id': widget.tenancy['id'],
        'property_id': widget.tenancy['property_id'],
        'room_id': widget.tenancy['room_id'],
        'tenant_id': user.id,
        'created_by': user.id,
        'category': _category,
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'priority': _priority,
        'status': 'new',
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo crear la incidencia: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const categories = ['Fontanería', 'Electricidad', 'Electrodomésticos', 'Mobiliario', 'Internet', 'Limpieza', 'Otros'];
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(backgroundColor: CohabiColors.background, elevation: 0, title: const Text('Nueva incidencia', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
            items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _category = v ?? 'Otros'),
          ),
          const SizedBox(height: 14),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Título', hintText: 'Ej. La persiana no baja', border: OutlineInputBorder())),
          const SizedBox(height: 14),
          TextField(controller: _description, minLines: 4, maxLines: 7, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder())),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _priority,
            decoration: const InputDecoration(labelText: 'Prioridad', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'low', child: Text('Baja')),
              DropdownMenuItem(value: 'normal', child: Text('Normal')),
              DropdownMenuItem(value: 'high', child: Text('Alta')),
              DropdownMenuItem(value: 'urgent', child: Text('Urgente')),
            ],
            onChanged: (v) => setState(() => _priority = v ?? 'normal'),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(backgroundColor: CohabiColors.turquoise, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            icon: const Icon(Icons.send_rounded),
            label: Text(_saving ? 'Enviando...' : 'Enviar incidencia'),
          ),
        ],
      ),
    );
  }
}
