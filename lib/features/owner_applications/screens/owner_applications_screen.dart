import 'package:flutter/material.dart';

import '../../../core/navigation/owner_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/owner_bottom_navigation.dart';
import '../models/owner_application.dart';
import 'owner_candidate_profile_screen.dart';
import 'owner_visits_screen.dart';
import '../services/owner_applications_service.dart';

class OwnerApplicationsScreen extends StatefulWidget {
  final String? roomId;
  final String? propertyName;
  final int? roomNumber;

  const OwnerApplicationsScreen({
    super.key,
    this.roomId,
    this.propertyName,
    this.roomNumber,
  });

  @override
  State<OwnerApplicationsScreen> createState() => _OwnerApplicationsScreenState();
}

class _OwnerApplicationsScreenState extends State<OwnerApplicationsScreen> {
  final _service = OwnerApplicationsService();

  bool _loading = true;
  String? _error;
  List<OwnerApplication> _applications = [];
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.loadApplications();
      if (!mounted) return;
      setState(() {
        _applications = data;
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

  List<OwnerApplication> get _visible {
    final scoped = widget.roomId == null
        ? _applications
        : _applications.where((e) => e.roomId == widget.roomId).toList();

    switch (_tab) {
      case 1:
        return scoped.where((e) => e.isAccepted).toList();
      case 2:
        return scoped.where((e) => e.isRejected).toList();
      default:
        return scoped.where((e) => e.isOpen).toList();
    }
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success), behavior: SnackBarBehavior.floating),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo completar la acción: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  Future<void> _openCandidate(OwnerApplication app) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerCandidateProfileScreen(
          applicationId: app.id,
        ),
      ),
    );

    if (changed == true && mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      bottomNavigationBar: OwnerBottomNavigation(
        currentIndex: 2,
        onTap: (index) => handleOwnerNavigation(context, index),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: CohabiColors.turquoise,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
            children: [
              Row(
                children: [
                  if (widget.roomId != null) ...[
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      widget.roomId == null
                          ? 'Solicitudes'
                          : 'Candidatos · Habitación ${widget.roomNumber ?? ''}',
                      style: const TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OwnerVisitsScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.event_available_outlined, size: 18),
                    label: const Text('Visitas'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.roomId == null
                    ? 'Gestiona las personas interesadas en tus habitaciones.'
                    : '${widget.propertyName ?? 'Propiedad'} · Solicitudes reales de esta habitación.',
                style: const TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _tabButton(0, 'En curso')),
                  const SizedBox(width: 8),
                  Expanded(child: _tabButton(1, 'Aceptadas')),
                  const SizedBox(width: 8),
                  Expanded(child: _tabButton(2, 'Descartadas')),
                ],
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(color: CohabiColors.turquoise),
                  ),
                )
              else if (_error != null)
                _errorCard()
              else if (_visible.isEmpty)
                _emptyCard()
              else
                ..._visible.map(
                  (app) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _applicationCard(app),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(int index, String label) {
    final selected = _tab == index;
    return OutlinedButton(
      onPressed: () => setState(() => _tab = index),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? CohabiColors.turquoise : CohabiColors.navy,
        backgroundColor: selected ? CohabiColors.turquoiseSoft : Colors.white,
        side: BorderSide(
          color: selected ? CohabiColors.turquoise : CohabiColors.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }

  Widget _applicationCard(OwnerApplication app) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CohabiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: CohabiColors.purpleSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: CohabiColors.purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.tenantName,
                      style: const TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${app.propertyName} · Habitación ${app.roomNumber}',
                      style: const TextStyle(color: CohabiColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _statusPill(app.status),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _info(Icons.location_on_outlined, app.city),
              _info(Icons.euro_rounded, '${app.monthlyPrice.toStringAsFixed(0)} €/mes'),
              if (app.visitScheduledAt != null)
                _info(Icons.event_available_outlined, _dateTime(app.visitScheduledAt!)),
            ],
          ),
          if (app.status == 'pending' || app.status == 'under_review') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _run(
                      () => _service.rejectApplication(app.id),
                      'Solicitud descartada.',
                    ),
                    child: const Text('Descartar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openCandidate(app),
                    icon: const Icon(Icons.person_search_rounded),
                    label: Text(
                      app.status == 'pending'
                          ? 'Revisar perfil'
                          : 'Ver perfil',
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (app.status == 'visit_proposed') ...[
            const SizedBox(height: 14),
            const Text(
              'Esperando a que el inquilino elija uno de los horarios propuestos.',
              style: TextStyle(color: CohabiColors.textSecondary),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _openCandidate(app),
              icon: const Icon(Icons.person_outline_rounded),
              label: const Text('Ver perfil / editar visita'),
            ),
          ],
          if (app.status == 'visit_confirmed') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _run(
                      () => _service.rejectApplication(app.id),
                      'Solicitud rechazada.',
                    ),
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: CohabiColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextButton(
                      onPressed: () => _run(
                        () => _service.acceptApplication(app.id),
                        'Solicitud aceptada. Habitación marcada como ocupada.',
                      ),
                      child: const Text(
                        'Aceptar candidato',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    final label = switch (status) {
      'pending' => 'Nueva',
      'under_review' => 'En revisión',
      'visit_proposed' => 'Visita propuesta',
      'visit_confirmed' => 'Visita confirmada',
      'accepted' => 'Aceptada',
      'rejected' => 'Rechazada',
      'withdrawn' => 'Retirada',
      'visit_declined' => 'Visita rechazada',
      _ => status,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CohabiColors.purpleSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: CohabiColors.purple,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: CohabiColors.turquoise),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: CohabiColors.textSecondary)),
        ],
      );

  Widget _errorCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CohabiColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 42),
            const SizedBox(height: 10),
            Text(_error ?? 'Error desconocido', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Reintentar')),
          ],
        ),
      );

  Widget _emptyCard() => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CohabiColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.assignment_outlined, color: CohabiColors.turquoise, size: 48),
            SizedBox(height: 10),
            Text(
              'No hay solicitudes en esta sección.',
              style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );

  String _dateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month · $hour:$minute';
  }
}
