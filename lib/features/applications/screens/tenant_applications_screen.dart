import 'package:flutter/material.dart';

import '../../../core/navigation/tenant_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tenant_bottom_navigation.dart';
import '../models/tenant_application.dart';
import '../services/tenant_applications_service.dart';

class TenantApplicationsScreen extends StatefulWidget {
  const TenantApplicationsScreen({super.key});

  @override
  State<TenantApplicationsScreen> createState() => _TenantApplicationsScreenState();
}

class _TenantApplicationsScreenState extends State<TenantApplicationsScreen> {
  final _service = TenantApplicationsService();

  bool _loading = true;
  String? _error;
  int _tab = 0;
  List<TenantApplication> _applications = [];
  final Map<String, String> _selectedSlots = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final values = await _service.loadApplications();
      if (!mounted) return;
      setState(() {
        _applications = values;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  List<TenantApplication> get _inProgress =>
      _applications.where((e) => e.isInProgress).toList();
  List<TenantApplication> get _finalized =>
      _applications.where((e) => e.isFinalized).toList();
  List<TenantApplication> get _discarded =>
      _applications.where((e) => e.isDiscarded).toList();

  List<TenantApplication> get _visible {
    if (_tab == 1) return _finalized;
    if (_tab == 2) return _discarded;
    return _inProgress;
  }

  Future<void> _confirmVisit(TenantApplication app) async {
    final slotId = _selectedSlots[app.id];
    if (slotId == null) {
      _snack('Selecciona primero uno de los horarios disponibles.');
      return;
    }
    try {
      await _service.confirmVisit(slotId);
      _snack('Visita confirmada.');
      await _load();
    } catch (e) {
      _snack('No se pudo confirmar la visita: $e');
    }
  }

  Future<void> _declineVisit(TenantApplication app) async {
    try {
      await _service.declineVisit(app.id);
      _snack('Has rechazado esta propuesta de visita.');
      await _load();
    } catch (e) {
      _snack('No se pudo rechazar la visita: $e');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      bottomNavigationBar: TenantBottomNavigation(
        currentIndex: 2,
        onTap: (index) => handleTenantNavigation(context, index),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: CohabiColors.turquoise,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 34),
            children: [
              _header(),
              const SizedBox(height: 22),
              _tabs(),
              const SizedBox(height: 16),
              if (_applications.any((e) => e.needsResponse)) _needsResponseBanner(),
              if (_applications.any((e) => e.needsResponse)) const SizedBox(height: 22),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(60),
                  child: Center(child: CircularProgressIndicator(color: CohabiColors.turquoise)),
                )
              else if (_error != null)
                _errorCard()
              else if (_visible.isEmpty)
                _empty()
              else
                ..._visible.map(
                  (app) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: app.needsResponse ? _responseCard(app) : _applicationCard(app),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solicitudes',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gestiona el estado de los pisos que te interesan y sigue el progreso de cada solicitud.',
                  style: TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [CohabiColors.turquoiseSoft, CohabiColors.purpleSoft],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.assignment_turned_in_outlined, size: 42, color: CohabiColors.purple),
          ),
        ],
      );

  Widget _tabs() => Row(
        children: [
          Expanded(child: _tabButton(0, 'En curso', _inProgress.length, Icons.hourglass_empty_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _tabButton(1, 'Finalizadas', _finalized.length, Icons.check_circle_outline_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _tabButton(2, 'Descartadas', _discarded.length, Icons.cancel_outlined)),
        ],
      );

  Widget _tabButton(int index, String label, int count, IconData icon) {
    final selected = _tab == index;
    return InkWell(
      onTap: () => setState(() => _tab = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? CohabiColors.purple : CohabiColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? CohabiColors.purple : CohabiColors.textSecondary, size: 20),
            const SizedBox(height: 5),
            Text(
              '$label ($count)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? CohabiColors.purple : CohabiColors.navy,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _needsResponseBanner() {
    final count = _applications.where((e) => e.needsResponse).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CohabiColors.purpleSoft.withOpacity(.85), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: CohabiColors.purple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tienes $count solicitud${count == 1 ? '' : 'es'} que necesita${count == 1 ? '' : 'n'} tu respuesta',
              style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _tab = 0),
            child: const Text('Ver ahora'),
          ),
        ],
      ),
    );
  }

  Widget _responseCard(TenantApplication app) {
    return _baseCard(
      app,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: CohabiColors.purpleSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '✨ El propietario quiere conocerte 💜',
              style: TextStyle(color: CohabiColors.purple, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Has sido seleccionado para una visita. Elige uno de los horarios disponibles.',
            style: TextStyle(color: CohabiColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          if (app.visitSlots.isEmpty)
            const Text('El propietario todavía no ha añadido horarios.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: app.visitSlots.map((slot) {
                final selected = _selectedSlots[app.id] == slot.id;
                return ChoiceChip(
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedSlots[app.id] = slot.id),
                  label: Text(_dateTime(slot.scheduledAt)),
                  selectedColor: CohabiColors.purpleSoft,
                  side: BorderSide(color: selected ? CohabiColors.purple : CohabiColors.border),
                  labelStyle: TextStyle(
                    color: selected ? CohabiColors.purple : CohabiColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: CohabiColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextButton(
                    onPressed: app.visitSlots.isEmpty ? null : () => _confirmVisit(app),
                    child: const Text(
                      'Confirmar horario',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _declineVisit(app),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Rechazar visita'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CohabiColors.coral,
                    side: const BorderSide(color: CohabiColors.coral),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _applicationCard(TenantApplication app) => _baseCard(
        app,
        body: _statusBox(app),
      );

  Widget _baseCard(TenantApplication app, {required Widget body}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CohabiColors.border),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: app.imageUrl == null
                      ? Container(
                          width: 104,
                          height: 84,
                          color: CohabiColors.purpleSoft,
                          child: const Icon(Icons.apartment_rounded, color: CohabiColors.purple),
                        )
                      : Image.network(
                          app.imageUrl!,
                          width: 104,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 104,
                            height: 84,
                            color: CohabiColors.purpleSoft,
                            child: const Icon(Icons.apartment_rounded),
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.propertyName,
                        style: const TextStyle(
                          color: CohabiColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Habitación ${app.roomNumber} · ${app.city}',
                        style: const TextStyle(color: CohabiColors.textSecondary),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${app.monthlyPrice.toStringAsFixed(0)} €/mes',
                        style: const TextStyle(color: CohabiColors.turquoise, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert_rounded, color: CohabiColors.textSecondary),
              ],
            ),
            const SizedBox(height: 14),
            body,
          ],
        ),
      );

  Widget _statusBox(TenantApplication app) {
    final data = _statusData(app.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: data.$2.withOpacity(.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(data.$3, color: data.$2),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.$1, style: TextStyle(color: data.$2, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(data.$4, style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData, String) _statusData(String status) {
    switch (status) {
      case 'under_review':
        return ('Solicitud en revisión', CohabiColors.purple, Icons.manage_search_rounded, 'El propietario está revisando tu perfil.');
      case 'visit_proposed':
        return ('Visita propuesta', CohabiColors.purple, Icons.calendar_month_rounded, 'Selecciona uno de los horarios propuestos.');
      case 'visit_confirmed':
        return ('Visita confirmada', CohabiColors.success, Icons.event_available_rounded, 'Tu visita está reservada.');
      case 'accepted':
        return ('¡Habitación conseguida!', CohabiColors.success, Icons.check_circle_rounded, 'Tu solicitud ha sido aceptada.');
      case 'rejected':
        return ('Solicitud no seleccionada', CohabiColors.coral, Icons.person_off_outlined, 'El propietario ha continuado con otro candidato.');
      case 'withdrawn':
        return ('Solicitud retirada', CohabiColors.textSecondary, Icons.undo_rounded, 'Retiraste tu interés en esta habitación.');
      case 'visit_declined':
        return ('Visita rechazada', CohabiColors.coral, Icons.event_busy_rounded, 'Has rechazado la propuesta de visita.');
      default:
        return ('Solicitud enviada', CohabiColors.blue, Icons.send_rounded, 'Tu interés se ha enviado al propietario.');
    }
  }

  Widget _errorCard() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: CohabiColors.coral, size: 44),
            const SizedBox(height: 10),
            Text(_error ?? '', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Reintentar')),
          ],
        ),
      );

  Widget _empty() => Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Column(
          children: [
            Icon(Icons.assignment_outlined, size: 52, color: CohabiColors.purple),
            SizedBox(height: 12),
            Text('Todavía no hay solicitudes en esta sección.', textAlign: TextAlign.center),
          ],
        ),
      );

  String _dateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month  $hour:$minute';
  }
}
