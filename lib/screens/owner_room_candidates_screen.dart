import 'package:flutter/material.dart';
import 'owner_availability_sheet.dart';
import '../core/theme/app_colors.dart';
import '../core/navigation/owner_navigation.dart';
import '../core/widgets/owner_bottom_navigation.dart';
import 'properties_dashboard_screen.dart';
import 'owner_visits_screen.dart';

class OwnerRoomCandidatesScreen extends StatefulWidget {
  final String propertyName;
  final int roomNumber;
  final int candidateCount;

  const OwnerRoomCandidatesScreen({
    super.key,
    required this.propertyName,
    required this.roomNumber,
    required this.candidateCount,
  });

  @override
  State<OwnerRoomCandidatesScreen> createState() =>
      _OwnerRoomCandidatesScreenState();
}

class _OwnerRoomCandidatesScreenState
    extends State<OwnerRoomCandidatesScreen> {
  String _sortMode = 'compatibility';

  final List<_DemoCandidate> _candidates = [
    const _DemoCandidate(
      name: 'Laura García',
      age: 26,
      profession: 'Ingeniera',
      stay: '12 meses',
      compatibility: 98,
      label: 'Muy compatible con tu piso',
      smoker: false,
      pets: false,
      verified: true,
      rank: 1,
      imageAsset: null,
    ),
    const _DemoCandidate(
      name: 'Carlos Ruiz',
      age: 28,
      profession: 'Consultor',
      stay: '9 meses',
      compatibility: 87,
      label: 'Muy compatible',
      smoker: false,
      pets: false,
      verified: true,
      rank: 2,
      imageAsset: null,
    ),
    const _DemoCandidate(
      name: 'Marta López',
      age: 24,
      profession: 'Estudiante de máster',
      stay: '10 meses',
      compatibility: 70,
      label: 'Compatible',
      smoker: false,
      pets: false,
      verified: true,
      rank: 3,
      imageAsset: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            14,
            18,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(context),

              const SizedBox(height: 18),

              _buildHero(),

              const SizedBox(height: 24),

              _buildStats(),

              const SizedBox(height: 22),

              _buildRoomSelector(),

              const SizedBox(height: 22),

              _buildToolbar(),

              const SizedBox(height: 16),

              ..._candidates.map(
                    (candidate) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildCandidateCard(candidate),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: OwnerBottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          _handleBottomNavigation(context, index);
        },
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: CohabiColors.border,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: CohabiColors.navy,
                size: 24,
              ),
            ),
          ),
        ),

        const Spacer(),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Los candidatos están ordenados según su compatibilidad.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: CohabiColors.border,
                ),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: CohabiColors.navy,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'TODO LISTO',
                    style: TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: CohabiColors.turquoise,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                'Tienes\ncandidatos ✨',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 31,
                  height: 1.04,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 13),

              const Text(
                'Hemos analizado y ordenado a los candidatos según su compatibilidad.',
                style: TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.48,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          flex: 5,
          child: Image.asset(
            'assets/images/selection_candidates_hero.png',
            height: 150,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CohabiColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStat(
              icon: Icons.workspace_premium_outlined,
              value: '4',
              label: 'Aceptados',
              accent: CohabiColors.turquoise,
            ),
          ),

          _statDivider(),

          Expanded(
            child: _buildStat(
              icon: Icons.groups_outlined,
              value: '${widget.candidateCount}',
              label: 'Recibidos',
              accent: CohabiColors.purple,
            ),
          ),

          _statDivider(),

          Expanded(
            child: _buildStat(
              icon: Icons.verified_user_outlined,
              value: '10',
              label: 'Verificados',
              accent: CohabiColors.turquoise,
            ),
          ),

          _statDivider(),

          Expanded(
            child: _buildStat(
              icon: Icons.star_outline_rounded,
              value: '8',
              label: 'Top match',
              accent: CohabiColors.purple,
            ),
          ),

          _statDivider(),

          Expanded(
            child: _buildStat(
              icon: Icons.schedule_rounded,
              value: '2',
              label: 'Visitas',
              accent: const Color(0xFFFF951F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color accent,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: accent,
          size: 21,
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            color: CohabiColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 3),

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
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

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 58,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      color: CohabiColors.border,
    );
  }

  // ============================================================
  // PISO + HABITACIÓN
  // ============================================================

  Widget _buildRoomSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.apartment_rounded,
            color: CohabiColors.navy,
            size: 23,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              widget.propertyName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CohabiColors.navy,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right_rounded,
              color: CohabiColors.textSecondary,
              size: 23,
            ),
          ),

          const Icon(
            Icons.bed_outlined,
            color: CohabiColors.navy,
            size: 23,
          ),

          const SizedBox(width: 7),

          Text(
            'Habitación ${widget.roomNumber}',
            style: const TextStyle(
              color: CohabiColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTROS
  // ============================================================

  Widget _buildToolbar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _sortMode = _sortMode == 'compatibility'
                  ? 'recent'
                  : 'compatibility';
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 2,
            ),
            child: Row(
              children: [
                Text(
                  _sortMode == 'compatibility'
                      ? 'Ordenados por compatibilidad'
                      : 'Más recientes',
                  style: const TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(width: 6),

                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: CohabiColors.navy,
                  size: 22,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterButton(
                icon: Icons.calendar_month_outlined,
                label: 'Mi disponibilidad',
                accent: CohabiColors.purple,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    barrierColor: CohabiColors.navy.withValues(
                      alpha: 0.48,
                    ),
                    builder: (_) {
                      return FractionallySizedBox(
                        heightFactor: 0.94,
                        child: const OwnerAvailabilitySheet(),
                      );
                    },
                  );
                },
              ),

              const SizedBox(width: 8),

              _filterButton(
                icon: Icons.event_available_outlined,
                label: 'Visitas',
                accent: CohabiColors.turquoise,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerVisitsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),

              _filterButton(
                icon: Icons.tune_rounded,
                label: 'Filtros',
                accent: CohabiColors.purple,
              ),

              const SizedBox(width: 8),

              _filterButton(
                icon: Icons.delete_outline_rounded,
                label: 'Descartados',
                accent: const Color(0xFFFF6674),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterButton({
    required IconData icon,
    required String label,
    required Color accent,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ??
              () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(label),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          },
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: accent.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: accent,
              size: 17,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CANDIDATO
  // ============================================================

  Widget _buildCandidateCard(_DemoCandidate candidate) {
    final accent = _compatibilityColor(candidate.compatibility);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CohabiColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRank(candidate.rank),

              const SizedBox(width: 10),

              _buildAvatar(candidate),

              const SizedBox(width: 12),

              Expanded(
                child: _buildCandidateInfo(candidate),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildCompatibilityLabel(
                  candidate.label,
                  accent,
                ),
              ),

              const SizedBox(width: 8),

              Text(
                '${candidate.compatibility}%',
                style: TextStyle(
                  color: accent,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          _buildCompatibilityBar(
            candidate.compatibility,
            accent,
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _candidateActionButton(
                  icon: Icons.calendar_month_rounded,
                  label: 'Proponer visita',
                  accent: CohabiColors.purple,
                  onTap: () {
                    _showCandidateMessage(
                      'Proponer visita a ${candidate.name}',
                    );
                  },
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _candidateActionButton(
                  icon: Icons.close_rounded,
                  label: 'Descartar',
                  accent: const Color(0xFFFF6674),
                  onTap: () {
                    _showCandidateMessage(
                      'Descartar a ${candidate.name}',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRank(int rank) {
    final Color background;
    final Color foreground;

    if (rank == 1) {
      background = const Color(0xFFFFF2CE);
      foreground = const Color(0xFFFFA000);
    } else if (rank == 2) {
      background = const Color(0xFFF1ECFF);
      foreground = CohabiColors.purple;
    } else {
      background = const Color(0xFFFFEEE5);
      foreground = const Color(0xFFFF8A45);
    }

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          color: foreground,
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildAvatar(_DemoCandidate candidate) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF1ECFF),
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: candidate.imageAsset != null
              ? ClipOval(
            child: Image.asset(
              candidate.imageAsset!,
              fit: BoxFit.cover,
            ),
          )
              : Icon(
            candidate.rank == 2
                ? Icons.person_rounded
                : Icons.person_outline_rounded,
            color: CohabiColors.purple,
            size: 38,
          ),
        ),

        if (candidate.verified)
          Positioned(
            right: -2,
            bottom: 0,
            child: Container(
              width: 21,
              height: 21,
              decoration: const BoxDecoration(
                color: CohabiColors.turquoise,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCandidateInfo(_DemoCandidate candidate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${candidate.name}, ${candidate.age}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            if (candidate.verified)
              const Icon(
                Icons.verified_rounded,
                color: CohabiColors.turquoise,
                size: 18,
              ),
          ],
        ),

        const SizedBox(height: 7),

        _candidateDataLine(
          Icons.work_outline_rounded,
          candidate.profession,
        ),

        const SizedBox(height: 5),

        _candidateDataLine(
          Icons.calendar_today_outlined,
          'Estancia: ${candidate.stay}',
        ),

        const SizedBox(height: 5),

        _candidateDataLine(
          Icons.home_outlined,
          '${candidate.smoker ? 'Fuma' : 'No fuma'} · '
              '${candidate.pets ? 'Con mascotas' : 'Sin mascotas'}',
        ),
      ],
    );
  }

  Widget _candidateDataLine(
      IconData icon,
      String text,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: CohabiColors.textSecondary,
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilityLabel(
      String label,
      Color accent,
      ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildCompatibilityBar(
      int compatibility,
      Color accent,
      ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 9,
            color: const Color(0xFFECECF4),
          ),

          FractionallySizedBox(
            widthFactor: compatibility / 100,
            child: Container(
              height: 9,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CohabiColors.turquoise,
                    Color(0xFF288FFF),
                    CohabiColors.purple,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _candidateActionButton({
    required IconData icon,
    required String label,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: accent.withValues(alpha: 0.35),
            width: 1.3,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: accent,
              size: 18,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _compatibilityColor(int compatibility) {
    if (compatibility >= 90) {
      return CohabiColors.purple;
    }

    if (compatibility >= 80) {
      return const Color(0xFF7556F5);
    }

    return const Color(0xFF8A62F4);
  }

  void _showCandidateMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // NAVEGACIÓN INFERIOR
  // ============================================================

  void _handleBottomNavigation(
      BuildContext context,
      int index,
      ) {
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

    handleOwnerNavigation(
      context,
      index,
    );
  }
}

// ============================================================
// MODELO TEMPORAL
// ============================================================

class _DemoCandidate {
  final String name;
  final int age;
  final String profession;
  final String stay;
  final int compatibility;
  final String label;
  final bool smoker;
  final bool pets;
  final bool verified;
  final int rank;
  final String? imageAsset;

  const _DemoCandidate({
    required this.name,
    required this.age,
    required this.profession,
    required this.stay,
    required this.compatibility,
    required this.label,
    required this.smoker,
    required this.pets,
    required this.verified,
    required this.rank,
    required this.imageAsset,
  });
}