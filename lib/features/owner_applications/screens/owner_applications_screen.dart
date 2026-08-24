import 'package:flutter/material.dart';

import '../../../core/navigation/owner_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';
import '../models/owner_application.dart';
import '../services/owner_applications_service.dart';

class OwnerApplicationsScreen extends StatefulWidget {
  const OwnerApplicationsScreen({super.key});

  @override
  State<OwnerApplicationsScreen> createState() => _OwnerApplicationsScreenState();
}

class _OwnerApplicationsScreenState extends State<OwnerApplicationsScreen> {
  final _service = OwnerApplicationsService();
  bool _loading = true;
  String? _error;
  List<OwnerApplication> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _service.loadApplications();
      if (!mounted) return;
      setState(() { _items = items; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _action(Future<void> Function() action) async {
    try { await action(); await _load(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
  }

  List<DateTime> _defaultSlots() {
    final now = DateTime.now();
    return [
      DateTime(now.year, now.month, now.day + 1, 18, 0),
      DateTime(now.year, now.month, now.day + 2, 17, 30),
      DateTime(now.year, now.month, now.day + 3, 12, 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      bottomNavigationBar: OwnerBottomNavigation(
        currentIndex: 2,
        onTap: (i) => handleOwnerNavigation(context, i),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text('Solicitudes', style: TextStyle(color: CohabiColors.navy, fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('Candidatos interesados en tus habitaciones.', style: TextStyle(color: CohabiColors.textSecondary)),
              const SizedBox(height: 24),
              if (_loading) const Center(child: CircularProgressIndicator()),
              if (_error != null) _errorCard(),
              if (!_loading && _error == null && _items.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('Todavía no tienes solicitudes.'))),
              ..._items.map(_card),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorCard() => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Text(_error ?? 'Error'), TextButton(onPressed: _load, child: const Text('Reintentar'))])));

  Widget _card(OwnerApplication app) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(app.tenantName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: CohabiColors.navy)),
          const SizedBox(height: 4),
          Text('${app.propertyName} · Habitación ${app.roomNumber}'),
          const SizedBox(height: 8),
          Text('Estado: ${app.status}', style: const TextStyle(fontWeight: FontWeight.w700, color: CohabiColors.purple)),
          if (app.visitScheduledAt != null) Text('Visita: ${app.visitScheduledAt!.toLocal()}'),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (app.status == 'pending') OutlinedButton(onPressed: () => _action(() => _service.markUnderReview(app.id)), child: const Text('Revisar')),
            if (app.status == 'pending' || app.status == 'under_review') ElevatedButton(onPressed: () => _action(() => _service.proposeVisit(app.id, _defaultSlots())), child: const Text('Proponer visita')),
            if (app.status == 'visit_confirmed') ElevatedButton(onPressed: () => _action(() => _service.accept(app.id)), child: const Text('Aceptar')),
            if (app.isOpen) OutlinedButton(onPressed: () => _action(() => _service.reject(app.id)), child: const Text('Rechazar')),
          ]),
        ]),
      ),
    );
  }
}
