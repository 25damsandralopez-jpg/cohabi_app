import 'package:flutter/material.dart';

import '../../../core/navigation/owner_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';
import '../services/owner_applications_service.dart';

class OwnerVisitsScreen extends StatefulWidget {
  const OwnerVisitsScreen({super.key});
  @override
  State<OwnerVisitsScreen> createState() => _OwnerVisitsScreenState();
}

class _OwnerVisitsScreenState extends State<OwnerVisitsScreen> {
  final _service = OwnerApplicationsService();
  bool _loading = true;
  String? _error;
  List<dynamic> _visits = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final apps = await _service.loadApplications();
      if (!mounted) return;
      setState(() {
        _visits = apps.where((a) => a.visitScheduledAt != null).toList();
        _loading = false; _error = null;
      });
    } catch (e) { if (mounted) setState(() { _loading = false; _error = e.toString(); }); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: CohabiColors.background,
    bottomNavigationBar: OwnerBottomNavigation(currentIndex: 3, onTap: (i) => handleOwnerNavigation(context, i)),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Visitas', style: TextStyle(color: CohabiColors.navy, fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 20),
      if (_loading) const Center(child: CircularProgressIndicator()),
      if (_error != null) Text(_error!),
      if (!_loading && _error == null && _visits.isEmpty) const Text('No tienes visitas confirmadas.'),
      ..._visits.map((a) => Card(child: ListTile(
        leading: const Icon(Icons.calendar_month_outlined, color: CohabiColors.purple),
        title: Text(a.tenantName),
        subtitle: Text('${a.propertyName} · Habitación ${a.roomNumber}\n${a.visitScheduledAt!.toLocal()}'),
      ))),
    ])),
  );
}
