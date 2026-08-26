import 'package:flutter/material.dart';

import '../core/navigation/owner_navigation.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/owner_bottom_navigation.dart';
import 'owner_availability_sheet.dart';
import 'properties_dashboard_screen.dart';

class OwnerVisitsScreen extends StatefulWidget {
  const OwnerVisitsScreen({super.key});

  @override
  State<OwnerVisitsScreen> createState() => _OwnerVisitsScreenState();
}

class _OwnerVisitsScreenState extends State<OwnerVisitsScreen> {
  // ============================================================
  // TEMPORAL PARA PROBAR EL DISEÑO
  // false -> todos los estados usan listas vacías.
  // true  -> usa visitas demo de próximas / realizadas / canceladas.
  // Más adelante se sustituye por datos reales de Supabase.
  // ============================================================
  static const bool debugShowVisits = false;

  _VisitFilter _selectedFilter = _VisitFilter.upcoming;

  final List<_DemoVisit> _demoVisits = const [
    _DemoVisit(
      name: 'Laura García',
      age: 26,
      property: 'Piso Gran Vía',
      room: 'Habitación 2',
      date: 'Mañana, 24 may',
      time: '11:00 – 11:30',
      status: _VisitStatus.upcoming,
    ),
    _DemoVisit(
      name: 'Carlos Ruiz',
      age: 28,
      property: 'Piso Gran Vía',
      room: 'Habitación 3',
      date: 'Sábado, 25 may',
      time: '17:00 – 17:30',
      status: _VisitStatus.upcoming,
    ),
    _DemoVisit(
      name: 'Marta López',
      age: 24,
      property: 'Piso Gran Vía',
      room: 'Habitación 1',
      date: 'Lunes, 27 may',
      time: '10:00 – 10:30',
      status: _VisitStatus.upcoming,
    ),
    _DemoVisit(
      name: 'Laura García',
      age: 26,
      property: 'Piso Gran Vía',
      room: 'Habitación 2',
      date: '22 may 2026',
      time: '11:00 – 11:30',
      status: _VisitStatus.completed,
      result: _CompletedVisitResult.pendingConfirmation,
    ),
    _DemoVisit(
      name: 'Carlos Ruiz',
      age: 28,
      property: 'Piso Gran Vía',
      room: 'Habitación 3',
      date: '21 may 2026',
      time: '17:00 – 17:30',
      status: _VisitStatus.completed,
      result: _CompletedVisitResult.attended,
    ),
    _DemoVisit(
      name: 'Marta López',
      age: 24,
      property: 'Piso Gran Vía',
      room: 'Habitación 1',
      date: '20 may 2026',
      time: '10:00 – 10:30',
      status: _VisitStatus.completed,
      result: _CompletedVisitResult.noShow,
    ),
    _DemoVisit(
      name: 'Paula Sánchez',
      age: 22,
      property: 'Piso Universidad',
      room: 'Habitación 2',
      date: '18 may 2026',
      time: '12:00 – 12:30',
      status: _VisitStatus.completed,
      result: _CompletedVisitResult.accepted,
    ),
    _DemoVisit(
      name: 'Andrés López',
      age: 27,
      property: 'Piso Universidad',
      room: 'Habitación 4',
      date: '16 may 2026',
      time: '18:30 – 19:00',
      status: _VisitStatus.cancelled,
    ),
  ];

  List<_DemoVisit> get _visits =>
      debugShowVisits ? _demoVisits : const <_DemoVisit>[];

  List<_DemoVisit> get _filteredVisits {
    return _visits.where((visit) {
      switch (_selectedFilter) {
        case _VisitFilter.upcoming:
          return visit.status == _VisitStatus.upcoming;
        case _VisitFilter.completed:
          return visit.status == _VisitStatus.completed;
        case _VisitFilter.cancelled:
          return visit.status == _VisitStatus.cancelled;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visits = _visits;
    final filtered = _filteredVisits;

    final upcomingCount = visits
        .where((visit) => visit.status == _VisitStatus.upcoming)
        .length;
    final completedCount = visits
        .where((visit) => visit.status == _VisitStatus.completed)
        .length;
    final cancelledCount = visits
        .where((visit) => visit.status == _VisitStatus.cancelled)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 18),
                    _buildHeader(),
                    const SizedBox(height: 22),
                    _buildStats(
                      upcoming: upcomingCount,
                      completed: completedCount,
                      cancelled: cancelledCount,
                    ),
                    const SizedBox(height: 18),
                    _buildFilters(),
                    const SizedBox(height: 18),
                    _buildCurrentSection(filtered),
                    const SizedBox(height: 18),
                    _buildBottomInfoCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: OwnerBottomNavigation(
        currentIndex: 2,
        onTap: (index) => _handleBottomNavigation(context, index),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================
  Widget _buildTopBar() {
    return Row(
      children: [
        _circleButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        _circleButton(
          icon: Icons.help_outline_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: CohabiColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: CohabiColors.navy, size: 23),
      ),
    );
  }

  // ============================================================
  // HERO DINÁMICO SEGÚN LA PESTAÑA
  // ============================================================
  Widget _buildHeader() {
    final completed = _selectedFilter == _VisitFilter.completed;
    final cancelled = _selectedFilter == _VisitFilter.cancelled;

    final String title;
    final String subtitle;
    final String asset;
    final IconData icon;
    final Color accent;

    if (completed) {
      title = 'Visitas\nrealizadas ✦';
      subtitle =
      'Consulta el resultado de tus visitas y decide qué candidatos continúan.';
      asset = 'assets/images/visits_completed_hero.png';
      icon = Icons.verified_user_outlined;
      accent = const Color(0xFF14B88A);
    } else if (cancelled) {
      title = 'Visitas\ncanceladas';
      subtitle =
      'Consulta las visitas que se cancelaron y reorganízalas si lo necesitas.';
      asset = 'assets/images/visits_cancelled_hero.png';
      icon = Icons.event_busy_outlined;
      accent = const Color(0xFFFF6674);
    } else {
      title = 'Visitas\nconcertadas ✦';
      subtitle =
      'Consulta y gestiona todas las visitas que tienes programadas con candidatos.';
      asset = 'assets/images/owner_visits_header.png';
      icon = Icons.calendar_month_rounded;
      accent = CohabiColors.purple;
    }

    return SizedBox(
      height: 155,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent.withValues(alpha: 0.15),
                            CohabiColors.turquoise.withValues(alpha: 0.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: accent, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: CohabiColors.navy,
                          fontSize: 25,
                          height: 1.03,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================
  Widget _buildStats({
    required int upcoming,
    required int completed,
    required int cancelled,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 5),
      decoration: _cardDecoration(radius: 20),
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              icon: Icons.calendar_month_rounded,
              iconColor: CohabiColors.purple,
              value: '$upcoming',
              label: 'Próximas',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _statItem(
              icon: Icons.check_circle_outline,
              iconColor: CohabiColors.turquoise,
              value: '$completed',
              label: 'Realizadas',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _statItem(
              icon: Icons.cancel_outlined,
              iconColor: const Color(0xFFFF6674),
              value: '$cancelled',
              label: 'Canceladas',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _statItem(
              icon: Icons.schedule_rounded,
              iconColor: const Color(0xFFFFA31A),
              value: '30 min',
              label: 'Duración',
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 23),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: CohabiColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CohabiColors.textSecondary,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 62, color: CohabiColors.border);
  }

  // ============================================================
  // FILTROS
  // ============================================================
  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: _filterButton(
            filter: _VisitFilter.upcoming,
            icon: Icons.calendar_month_rounded,
            label: 'Próximas',
            accent: CohabiColors.purple,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _filterButton(
            filter: _VisitFilter.completed,
            icon: Icons.check_circle_outline,
            label: 'Realizadas',
            accent: CohabiColors.turquoise,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _filterButton(
            filter: _VisitFilter.cancelled,
            icon: Icons.cancel_outlined,
            label: 'Canceladas',
            accent: const Color(0xFFFF6674),
          ),
        ),
      ],
    );
  }

  Widget _filterButton({
    required _VisitFilter filter,
    required IconData icon,
    required String label,
    required Color accent,
  }) {
    final selected = _selectedFilter == filter;
    final Color selectedStart = filter == _VisitFilter.completed
        ? const Color(0xFF16C79A)
        : filter == _VisitFilter.cancelled
        ? const Color(0xFFFF7A86)
        : CohabiColors.purple;

    final Color selectedEnd = filter == _VisitFilter.completed
        ? CohabiColors.turquoise
        : filter == _VisitFilter.cancelled
        ? const Color(0xFFFF9A76)
        : CohabiColors.turquoise;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [selectedStart, selectedEnd])
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? selectedStart : accent.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : accent,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : CohabiColors.navy,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONTENIDO ACTUAL
  // ============================================================
  Widget _buildCurrentSection(List<_DemoVisit> filtered) {
    switch (_selectedFilter) {
      case _VisitFilter.upcoming:
        return filtered.isEmpty
            ? _buildUpcomingEmptyState()
            : _buildVisitsList(filtered);
      case _VisitFilter.completed:
        return filtered.isEmpty
            ? _buildCompletedEmptyState()
            : _buildCompletedVisitsList(filtered);
      case _VisitFilter.cancelled:
        return filtered.isEmpty
            ? _buildCancelledEmptyState()
            : _buildVisitsList(filtered);
    }
  }

  // ============================================================
  // VACÍO: PRÓXIMAS
  // ============================================================
  Widget _buildUpcomingEmptyState() {
    return _buildSectionShell(
      title: 'Próximas visitas',
      count: 0,
      accent: CohabiColors.purple,
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: Image.asset(
              'assets/images/owner_no_visits.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aún no tienes visitas ✦',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando un candidato reserve uno de tus horarios disponibles, aparecerá aquí su visita.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          _buildAvailabilityButton(),
          const SizedBox(height: 18),
          Container(height: 1, color: CohabiColors.border),
          const SizedBox(height: 17),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoCircle(
                icon: Icons.lightbulb_outline_rounded,
                accent: CohabiColors.purple,
                background: Color(0xFFF1ECFF),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Tus candidatos podrán elegir\n',
                        style: TextStyle(
                          color: CohabiColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text:
                        'entre los horarios que hayas configurado en tu disponibilidad.',
                        style: TextStyle(
                          color: CohabiColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 11.5, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VACÍO: REALIZADAS
  // ============================================================
  Widget _buildCompletedEmptyState() {
    const green = Color(0xFF14B88A);

    return _buildSectionShell(
      title: 'Visitas realizadas',
      count: 0,
      accent: green,
      child: Column(
        children: [
          SizedBox(
            height: 205,
            child: Image.asset(
              'assets/images/visits_completed_empty.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Aún no tienes visitas realizadas ✦',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando completes una visita con un candidato, aparecerá aquí para que puedas registrar cómo ha ido.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: CohabiColors.border),
          const SizedBox(height: 17),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoCircle(
                icon: Icons.emoji_events_outlined,
                accent: green,
                background: Color(0xFFE7F9F3),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Aquí decidirás quién ha encajado mejor\n',
                        style: TextStyle(
                          color: CohabiColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text:
                        'Confirma la visita y decide si aceptas, descartas o quieres pensarlo un poco más.',
                        style: TextStyle(
                          color: CohabiColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 11.5, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VACÍO: CANCELADAS
  // ============================================================
  Widget _buildCancelledEmptyState() {
    return _buildSectionShell(
      title: 'Visitas canceladas',
      count: 0,
      accent: const Color(0xFFFF6674),
      child:  Padding(
        padding: EdgeInsets.symmetric(vertical: 34, horizontal: 18),
        child: Column(
          children: [
            Image.asset(
              'assets/images/visits_cancelled_empty.png',
              height: 190,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 14),
            SizedBox(height: 14),
            Text(
              'No tienes visitas canceladas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CohabiColors.navy,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'Las visitas que se cancelen aparecerán aquí para que puedas consultarlas o volver a concertarlas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CohabiColors.textSecondary,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionShell({
    required String title,
    required int count,
    required Color accent,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: CohabiColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 7),
            Container(
              constraints: const BoxConstraints(minWidth: 25),
              height: 25,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: _cardDecoration(radius: 22),
          child: child,
        ),
      ],
    );
  }

  // ============================================================
  // LISTA GENÉRICA (PRÓXIMAS / CANCELADAS)
  // ============================================================
  Widget _buildVisitsList(List<_DemoVisit> visits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildListTitle(visits.length),
        const SizedBox(height: 12),
        ...visits.map(_buildVisitCard),
      ],
    );
  }

  Widget _buildListTitle(int count) {
    final title = _selectedFilter == _VisitFilter.cancelled
        ? 'Visitas canceladas'
        : 'Próximas visitas';
    final accent = _selectedFilter == _VisitFilter.cancelled
        ? const Color(0xFFFF6674)
        : CohabiColors.purple;

    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: CohabiColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 7),
        _countBadge(count, accent),
        const Spacer(),
        const Text(
          'Ordenar por fecha',
          style: TextStyle(
            color: CohabiColors.purple,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: CohabiColors.purple,
          size: 18,
        ),
      ],
    );
  }

  Widget _countBadge(int count, Color accent) {
    return Container(
      constraints: const BoxConstraints(minWidth: 25),
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildVisitCard(_DemoVisit visit) {
    final cancelled = visit.status == _VisitStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(radius: 17),
      child: Row(
        children: [
          _avatar(visit),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${visit.name}, ${visit.age}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${visit.property} · ${visit.room}',
                  style: const TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: CohabiColors.border),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _miniRow(Icons.calendar_month_rounded, visit.date),
                const SizedBox(height: 7),
                _miniRow(Icons.schedule_rounded, visit.time),
              ],
            ),
          ),
          if (!cancelled)
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.close_rounded, size: 17),
              label: const Text('Cancelar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF6674),
                textStyle: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // LISTA DE REALIZADAS
  // ============================================================
  Widget _buildCompletedVisitsList(List<_DemoVisit> visits) {
    const green = Color(0xFF14B88A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              'Visitas realizadas',
              style: TextStyle(
                color: CohabiColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 7),
            _countBadge(visits.length, green),
            const Spacer(),
            const Text(
              'Más recientes',
              style: TextStyle(
                color: CohabiColors.purple,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: CohabiColors.purple,
              size: 18,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...visits.map(_buildCompletedVisitCard),
      ],
    );
  }

  Widget _buildCompletedVisitCard(_DemoVisit visit) {
    const green = Color(0xFF14B88A);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(radius: 18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(visit),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${visit.name}, ${visit.age}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CohabiColors.navy,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.verified_rounded,
                          color: CohabiColors.turquoise,
                          size: 17,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${visit.property} · ${visit.room}',
                      style: const TextStyle(
                        color: CohabiColors.textSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: CohabiColors.purple,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            visit.date,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CohabiColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: CohabiColors.purple,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            visit.time,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CohabiColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _completedResultBadge(visit.result),
            ],
          ),
          const SizedBox(height: 12),
          _completedActions(visit, green),
        ],
      ),
    );
  }

  Widget _completedResultBadge(_CompletedVisitResult? result) {
    final r = result ?? _CompletedVisitResult.pendingConfirmation;

    switch (r) {
      case _CompletedVisitResult.pendingConfirmation:
        return _pill(
          'Pendiente',
          const Color(0xFFFFA31A),
          const Color(0xFFFFF4D8),
        );
      case _CompletedVisitResult.attended:
        return _pill(
          'Realizada',
          const Color(0xFF078E80),
          const Color(0xFFE3F8F3),
        );
      case _CompletedVisitResult.noShow:
        return _pill(
          'No acudió',
          const Color(0xFF6E7291),
          const Color(0xFFF0F1F7),
        );
      case _CompletedVisitResult.accepted:
        return _pill(
          'Aceptado',
          const Color(0xFF078E80),
          const Color(0xFFE3F8F3),
        );
    }
  }

  Widget _pill(String text, Color foreground, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _completedActions(_DemoVisit visit, Color green) {
    final result = visit.result ?? _CompletedVisitResult.pendingConfirmation;

    if (result == _CompletedVisitResult.pendingConfirmation) {
      return Align(
        alignment: Alignment.centerRight,
        child: _smallActionButton(
          icon: Icons.check_rounded,
          label: 'Confirmar visita',
          accent: CohabiColors.purple,
          filled: true,
          onTap: () {},
        ),
      );
    }

    if (result == _CompletedVisitResult.noShow) {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'El candidato no acudió a la visita.',
                style: TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _smallActionButton(
            icon: Icons.calendar_month_rounded,
            label: 'Volver a concertar',
            accent: CohabiColors.purple,
            onTap: () {},
          ),
        ],
      );
    }

    if (result == _CompletedVisitResult.accepted) {
      return Align(
        alignment: Alignment.centerRight,
        child: _pill(
          '✓ Candidato aceptado',
          const Color(0xFF078E80),
          const Color(0xFFE3F8F3),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _smallActionButton(
            icon: Icons.home_outlined,
            label: 'Aceptar',
            accent: green,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _smallActionButton(
            icon: Icons.schedule_rounded,
            label: 'Pensarlo',
            accent: CohabiColors.purple,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _smallActionButton(
            icon: Icons.delete_outline_rounded,
            label: 'Descartar',
            accent: const Color(0xFFFF6674),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _smallActionButton({
    required IconData icon,
    required String label,
    required Color accent,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
            colors: [
              CohabiColors.purple,
              Color(0xFF7A54F8),
            ],
          )
              : null,
          color: filled ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled ? CohabiColors.purple : accent.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: filled ? Colors.white : accent, size: 16),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: filled ? Colors.white : accent,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(_DemoVisit visit) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECFF),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
      ),
      child: Center(
        child: Text(
          visit.name.substring(0, 1),
          style: const TextStyle(
            color: CohabiColors.purple,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _miniRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: CohabiColors.purple, size: 15),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DISPONIBILIDAD
  // ============================================================
  Widget _buildAvailabilityButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            CohabiColors.purple,
            Color(0xFF347FF4),
            CohabiColors.turquoise,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openAvailability,
          borderRadius: BorderRadius.circular(15),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 9),
                Text(
                  'Mi disponibilidad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 9),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAvailability() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: CohabiColors.navy.withValues(alpha: 0.48),
      builder: (_) {
        return const FractionallySizedBox(
          heightFactor: 0.94,
          child: OwnerAvailabilitySheet(),
        );
      },
    );
  }

  // ============================================================
  // TARJETA INFERIOR DINÁMICA
  // ============================================================
  Widget _buildBottomInfoCard() {
    final completed = _selectedFilter == _VisitFilter.completed;
    final cancelled = _selectedFilter == _VisitFilter.cancelled;

    final IconData icon;
    final String title;
    final String subtitle;
    final Color accent;

    if (completed) {
      icon = Icons.emoji_events_outlined;
      title = 'Revisa el resultado después de cada visita';
      subtitle =
      'Podrás aceptar al candidato, descartarlo o decidirlo más adelante.';
      accent = const Color(0xFF14B88A);
    } else if (cancelled) {
      icon = Icons.event_repeat_rounded;
      title = 'Puedes volver a concertar una visita';
      subtitle =
      'Si la cancelación fue puntual, puedes proponer o abrir nuevos horarios.';
      accent = const Color(0xFFFF6674);
    } else {
      icon = Icons.notifications_active_outlined;
      title = 'Te notificaremos antes de cada visita';
      subtitle = 'Recibirás un recordatorio antes de cada visita programada.';
      accent = CohabiColors.purple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            accent.withValues(alpha: 0.06),
            CohabiColors.turquoise.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CohabiColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            child: Text(
              completed ? 'Consejos' : 'Configurar',
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVEGACIÓN INFERIOR
  // ============================================================
  void _handleBottomNavigation(BuildContext context, int index) {
    if (index == 2) return;

    if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const PropertiesDashboardScreen(),
        ),
            (route) => false,
      );
      return;
    }

    handleOwnerNavigation(context, index);
  }

  // ============================================================
  // DECORACIÓN
  // ============================================================
  BoxDecoration _cardDecoration({double radius = 18}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: CohabiColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class _InfoCircle extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final Color background;

  const _InfoCircle({
    required this.icon,
    required this.accent,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: accent, size: 22),
    );
  }
}

enum _VisitFilter {
  upcoming,
  completed,
  cancelled,
}

enum _VisitStatus {
  upcoming,
  completed,
  cancelled,
}

enum _CompletedVisitResult {
  pendingConfirmation,
  attended,
  noShow,
  accepted,
}

class _DemoVisit {
  final String name;
  final int age;
  final String property;
  final String room;
  final String date;
  final String time;
  final _VisitStatus status;
  final _CompletedVisitResult? result;

  const _DemoVisit({
    required this.name,
    required this.age,
    required this.property,
    required this.room,
    required this.date,
    required this.time,
    required this.status,
    this.result,
  });
}
