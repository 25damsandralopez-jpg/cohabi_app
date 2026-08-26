import 'package:flutter/material.dart';

import '../../../core/navigation/tenant_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tenant_bottom_navigation.dart';
import '../../tenant_profile/services/tenant_profile_service.dart';
import '../results/screens/tenant_best_matches_screen.dart';
import '../services/tenant_selection_service.dart';
import 'tenant_selection_screen.dart';

class TenantSelectionHubScreen extends StatefulWidget {
  const TenantSelectionHubScreen({super.key});

  @override
  State<TenantSelectionHubScreen> createState() =>
      _TenantSelectionHubScreenState();
}

class _TenantSelectionHubScreenState extends State<TenantSelectionHubScreen> {
  final _selectionService = TenantSelectionService();
  final _tenantProfileService = TenantProfileService();

  bool _loading = true;
  String? _error;

  Map<String, dynamic> _tenant = {};
  Map<String, dynamic> _selection = {};

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
      final results = await Future.wait([
        _tenantProfileService.load(),
        _selectionService.getOrCreate(),
      ]);

      final profileData = Map<String, dynamic>.from(
        results[0] as Map<String, dynamic>,
      );
      final selectionProfile = results[1];

      if (!mounted) return;

      setState(() {
        _tenant = Map<String, dynamic>.from(
          profileData['tenant'] as Map? ?? const {},
        );
        _selection = Map<String, dynamic>.from(
          (selectionProfile as dynamic).data as Map,
        );
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

  Future<void> _editPreferences() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const TenantSelectionScreen(editMode: true),
      ),
    );

    if (changed == true) {
      await _load();
    }
  }

  void _openMatches() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TenantBestMatchesScreen(),
      ),
    );
  }

  String get _city {
    final value = _tenant['search_city']?.toString().trim();
    return value == null || value.isEmpty ? 'Sin definir' : value;
  }

  String get _budget {
    final value = _tenant['max_monthly_budget'];
    if (value == null) return 'Sin definir';

    final number = value is num
        ? value
        : num.tryParse(value.toString().replaceAll(',', '.'));

    if (number == null) return value.toString();
    final amount = number % 1 == 0
        ? number.toInt().toString()
        : number.toStringAsFixed(2);
    return '$amount €/mes';
  }

  String get _entry {
    final months = List<String>.from(
      (_selection['entry_months'] as List?) ?? const <String>[],
    );

    if (months.isNotEmpty) {
      return months.join(' – ');
    }

    final date = _tenant['entry_date']?.toString().trim();
    if (date == null || date.isEmpty) return 'Sin definir';

    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;

    const monthNames = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];

    return '${parsed.day} ${monthNames[parsed.month - 1]} ${parsed.year}';
  }

  String get _environment {
    final value = _selection['desired_home_environment']?.toString().trim();
    return value == null || value.isEmpty ? 'Sin definir' : value;
  }

  String get _roomType {
    final value = _tenant['accommodation_type']?.toString().trim();
    return value == null || value.isEmpty ? 'Sin definir' : value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      bottomNavigationBar: TenantBottomNavigation(
        currentIndex: 1,
        onTap: (index) => handleTenantNavigation(context, index),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: CohabiColors.turquoise,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: CohabiColors.turquoise,
                    ),
                  ),
                )
              else if (_error != null)
                _buildError()
              else ...[
                _buildProfileCard(),
                const SizedBox(height: 18),
                _buildMatchesCard(),
                const SizedBox(height: 18),
                _buildHowItWorks(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cohabi Selección ✨',
                style: TextStyle(
                  color: CohabiColors.purple,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Tu selección',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 31,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gestiona lo que buscas y descubre viviendas que encajan contigo.',
                style: TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Actualizar',
          onPressed: _loading ? null : _load,
          icon: const Icon(
            Icons.refresh_rounded,
            color: CohabiColors.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CohabiColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: CohabiColors.purpleSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: CohabiColors.purple,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu perfil de compatibilidad',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Perfil completado',
                      style: TextStyle(
                        color: CohabiColors.success,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CohabiColors.turquoiseSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 15,
                      color: CohabiColors.success,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Activo',
                      style: TextStyle(
                        color: CohabiColors.success,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _summaryRow(
            Icons.location_on_outlined,
            'Ciudad',
            _city,
          ),
          _summaryRow(
            Icons.euro_rounded,
            'Presupuesto',
            _budget,
          ),
          _summaryRow(
            Icons.calendar_month_outlined,
            'Entrada',
            _entry,
          ),
          _summaryRow(
            Icons.bed_outlined,
            'Alojamiento',
            _roomType,
          ),
          _summaryRow(
            Icons.auto_awesome_outlined,
            'Ambiente',
            _environment,
            isLast: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _editPreferences,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar preferencias'),
              style: OutlinedButton.styleFrom(
                foregroundColor: CohabiColors.purple,
                side: const BorderSide(
                  color: CohabiColors.purple,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 13),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: CohabiColors.background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 18,
              color: CohabiColors.purple,
            ),
          ),
          const SizedBox(width: 11),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: CohabiColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CohabiColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CohabiColors.turquoiseSoft,
            Colors.white,
            CohabiColors.purpleSoft,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CohabiColors.purple.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: CohabiColors.purple,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pisos compatibles contigo',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'Cohabi utiliza tus preferencias de búsqueda y convivencia para enseñarte primero las opciones que mejor encajan contigo.',
            style: TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: CohabiColors.primaryGradient,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openMatches,
                  borderRadius: BorderRadius.circular(17),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ver pisos compatibles',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: CohabiColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: CohabiColors.orangeSoft,
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: CohabiColors.orange,
              size: 21,
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu selección evoluciona contigo',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Si cambian tu presupuesto, fecha de entrada o preferencias de convivencia, actualízalas aquí y Cohabi volverá a ordenar tus opciones.',
                  style: TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CohabiColors.coralSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: CohabiColors.coral,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'No se pudo cargar tu Selección.\n$_error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CohabiColors.navy,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _load,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
