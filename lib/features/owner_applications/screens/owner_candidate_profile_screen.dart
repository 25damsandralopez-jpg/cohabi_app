import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/owner_candidate_profile.dart';
import '../services/owner_applications_service.dart';
import 'owner_propose_visit_screen.dart';

class OwnerCandidateProfileScreen extends StatefulWidget {
  final String applicationId;

  const OwnerCandidateProfileScreen({
    super.key,
    required this.applicationId,
  });

  @override
  State<OwnerCandidateProfileScreen> createState() =>
      _OwnerCandidateProfileScreenState();
}

class _OwnerCandidateProfileScreenState
    extends State<OwnerCandidateProfileScreen> {
  final _service = OwnerApplicationsService();

  OwnerCandidateProfile? _candidate;
  bool _loading = true;
  bool _working = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final candidate =
          await _service.loadCandidateProfile(widget.applicationId);
      if (!mounted) return;
      setState(() {
        _candidate = candidate;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _validateCandidate() async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await _service.markUnderReview(widget.applicationId);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Candidato validado y marcado como en revisión.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo validar: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _openVisitProposal() async {
    final candidate = _candidate;
    if (candidate == null) return;

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerProposeVisitScreen(
          applicationId: candidate.applicationId,
          candidateName: candidate.tenantName,
          propertyName: candidate.propertyName,
          roomNumber: candidate.roomNumber,
        ),
      ),
    );

    if (changed == true && mounted) {
      await _load();
    }
  }

  String _text(dynamic value, [String empty = 'No indicado']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? empty : text;
  }

  String _yesNo(dynamic value) {
    if (value == true) return 'Sí';
    if (value == false) return 'No';
    return _text(value);
  }

  String _list(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.map((e) => e.toString()).join(', ');
    }
    return 'No indicado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(
        backgroundColor: CohabiColors.background,
        elevation: 0,
        title: const Text(
          'Perfil del candidato',
          style: TextStyle(
            color: CohabiColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: CohabiColors.navy,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: CohabiColors.turquoise,
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final c = _candidate!;
    final tp = c.tenantProfile;
    final sp = c.selectionProfile;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 34),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: CohabiColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.tenantName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${c.propertyName} · Habitación ${c.roomNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (c.monthlyPrice > 0) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${c.monthlyPrice.toStringAsFixed(0)} €/mes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _section(
          'Datos personales',
          Icons.badge_outlined,
          [
            _row('Teléfono', _text(c.phone)),
            _row('Email', _text(c.email)),
            _row('Nacimiento', _text(tp['birth_date'])),
            _row('Género', _text(tp['gender'])),
            _row('Nacionalidad', _text(tp['nationality'])),
            _row('Idioma', _text(tp['language'])),
          ],
        ),

        _section(
          'Situación y búsqueda',
          Icons.work_outline_rounded,
          [
            _row('Ocupación', _text(tp['occupation'])),
            _row('Ingresos', _text(tp['monthly_income'])),
            _row('Avalista', _yesNo(tp['has_guarantor'])),
            _row('Ciudad', _text(tp['search_city'])),
            _row('Zona', _text(tp['search_zone'])),
            _row('Tipo de alojamiento', _text(tp['accommodation_type'])),
            _row('Entrada', _text(tp['entry_date'])),
            _row('Duración', _text(tp['stay_duration'])),
            _row(
              'Presupuesto máximo',
              tp['max_monthly_budget'] == null
                  ? 'No indicado'
                  : '${tp['max_monthly_budget']} €/mes',
            ),
            _row('Fumador', _yesNo(tp['smoker'])),
            _row('Mascota', _yesNo(tp['has_pet'])),
            _row('Ambiente deseado', _text(tp['desired_environment'])),
          ],
        ),

        _section(
          'Experiencia compartiendo piso',
          Icons.home_work_outlined,
          [
            _row('Ha compartido antes', _yesNo(sp['shared_before'])),
            _row('Motivo vivienda anterior', _text(sp['previous_housing_reason'])),
            _row('Puede aportar referencias', _yesNo(sp['can_provide_reference'])),
          ],
        ),

        _section(
          'Rutina y convivencia',
          Icons.groups_2_outlined,
          [
            _row('Limpieza y orden', _text(sp['cleanliness_style'])),
            _row('Horario', _text(sp['schedule_type'])),
            _row('Trabaja/estudia desde casa', _yesNo(sp['works_from_home'])),
            _row('Gestiona conflictos', _text(sp['conflict_style'])),
            _row('Alcohol', _text(sp['alcohol_frequency'])),
            _row('Fiestas', _text(sp['party_frequency'])),
            _row('Recibe visitas', _yesNo(sp['receives_visitors'])),
            _row('Visitas duermen', _yesNo(sp['visitors_sleep_over'])),
            _row(
              'Noches de visita/mes',
              _text(sp['sleepover_nights_per_month']),
            ),
            _row('Tiene mascotas', _yesNo(sp['has_pets'])),
            _row(
              'Ambiente de hogar',
              _text(sp['desired_home_environment']),
            ),
          ],
        ),

        _section(
          'Afinidad y preferencias',
          Icons.auto_awesome_outlined,
          [
            _row('Aficiones', _list(sp['hobbies'])),
            _row('Tiempo libre', _text(sp['free_time_style'])),
            _row('Rasgos', _list(sp['personality_traits'])),
            _row(
              'Estilo social del hogar',
              _text(sp['preferred_home_social_style']),
            ),
            _row(
              'Valores del compañero',
              _list(sp['preferred_roommate_values']),
            ),
            _row('Información adicional', _text(sp['additional_info'])),
          ],
        ),

        const SizedBox(height: 4),
        if (c.status == 'pending')
          OutlinedButton.icon(
            onPressed: _working ? null : _validateCandidate,
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text('Validar perfil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: CohabiColors.purple,
              side: const BorderSide(color: CohabiColors.purple),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        if (c.status == 'pending') const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _working ? null : _openVisitProposal,
          icon: const Icon(Icons.calendar_month_rounded),
          label: Text(
            c.status == 'visit_proposed'
                ? 'Editar propuesta de visita'
                : 'Proponer visita',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: CohabiColors.turquoise,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              Icon(icon, color: CohabiColors.purple, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
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
              style: const TextStyle(
                color: CohabiColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
