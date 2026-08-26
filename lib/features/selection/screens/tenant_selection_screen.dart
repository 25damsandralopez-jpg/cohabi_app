import 'package:flutter/material.dart';

import '../../../core/navigation/tenant_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tenant_bottom_navigation.dart';
import '../../selection/services/tenant_selection_service.dart';
import '../widgets/selection_widgets.dart';
import '../results/screens/tenant_best_matches_screen.dart';
class TenantSelectionScreen extends StatefulWidget {
  const TenantSelectionScreen({
    super.key,
    this.editMode = false,
  });

  /// Reutiliza exactamente el mismo cuestionario inicial para editar
  /// las preferencias ya guardadas.
  final bool editMode;

  @override
  State<TenantSelectionScreen> createState() => _TenantSelectionScreenState();
}

class _TenantSelectionScreenState extends State<TenantSelectionScreen> {
  final _service = TenantSelectionService();

  bool _loading = true;
  bool _saving = false;
  bool _completed = false;
  int _step = 1;

  final Map<String, dynamic> _data = {};
  final _previousHousingController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _previousHousingController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await _service.getOrCreate();
      _data.addAll(profile.data);
      _previousHousingController.text = (_data['previous_housing_reason'] ?? '').toString();
      _additionalInfoController.text = (_data['additional_info'] ?? '').toString();
      if (!mounted) return;
      setState(() {
        _step = widget.editMode ? 1 : profile.currentStep.clamp(1, 8);
        _completed = widget.editMode ? false : profile.completed;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _error('No se pudo cargar Cohabi Selección: $e');
    }
  }

  void _error(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
  }

  void _set(String key, dynamic value) => setState(() => _data[key] = value);

  List<String> _list(String key) => List<String>.from((_data[key] as List?) ?? const <String>[]);

  void _toggleList(String key, String value, {int? max}) {
    final values = _list(key);
    if (values.contains(value)) {
      values.remove(value);
    } else {
      if (max != null && values.length >= max) {
        _error('Puedes seleccionar hasta $max opciones.');
        return;
      }
      values.add(value);
    }
    _set(key, values);
  }

  bool _validateStep() {
    switch (_step) {
      case 1:
        final flexibility = _data['entry_flexibility']?.toString();
        final entryMonths = _list('entry_months');

        if (flexibility == null || flexibility.isEmpty) {
          _error('Indica cuándo te gustaría entrar.');
          return false;
        }

        if (flexibility == 'single_month' && entryMonths.length != 1) {
          _error('Selecciona el mes en el que te gustaría entrar.');
          return false;
        }

        if (flexibility == 'range' && entryMonths.length != 2) {
          _error('Selecciona el mes de inicio y el mes de fin.');
          return false;
        }

        if (_data['monthly_income_range'] == null ||
            _data['income_verifiable'] == null ||
            _data['has_guarantor'] == null) {
          _error('Completa las preguntas del paso 1.');
          return false;
        }

        return true;
      case 2:
        if (_data['shared_before'] == null || _data['can_provide_reference'] == null) {
          _error('Completa las preguntas del paso 2.');
          return false;
        }
        return true;
      case 3:
        if (_data['cleanliness_style'] == null || _data['schedule_type'] == null || _data['works_from_home'] == null) {
          _error('Completa las preguntas del paso 3.');
          return false;
        }
        return true;
      case 4:
        if (_data['conflict_style'] == null || _data['alcohol_frequency'] == null || _data['party_frequency'] == null) {
          _error('Completa las preguntas del paso 4.');
          return false;
        }
        return true;
      case 5:
        if (_data['receives_visitors'] == null || _data['has_pets'] == null || _data['desired_home_environment'] == null) {
          _error('Completa las preguntas del paso 5.');
          return false;
        }
        if (_data['receives_visitors'] == true && _data['visitors_sleep_over'] == null) {
          _error('Indica si tus visitas suelen quedarse a dormir.');
          return false;
        }
        return true;
      case 6:
        if (_list('hobbies').isEmpty) {
          _error('Selecciona al menos una afición.');
          return false;
        }
        return true;
      case 7:
        if (_data['free_time_style'] == null || _list('personality_traits').isEmpty) {
          _error('Completa las preguntas del paso 7.');
          return false;
        }
        return true;
      case 8:
        if (_data['preferred_home_social_style'] == null || _list('preferred_roommate_values').isEmpty) {
          _error('Completa las preguntas del paso 8.');
          return false;
        }
        return true;
    }
    return true;
  }

  Future<void> _continue() async {
    if (!_validateStep() || _saving) return;
    setState(() => _saving = true);
    try {
      if (_step == 2) _data['previous_housing_reason'] = _previousHousingController.text.trim();
      if (_step == 5) _data['additional_info'] = _additionalInfoController.text.trim();

      final values = _valuesForStep(_step);
      if (_step == 8) {
        await _service.complete(values);
        if (!mounted) return;

        if (widget.editMode) {
          Navigator.pop(context, true);
          return;
        }

        setState(() => _completed = true);
      } else {
        await _service.saveStep(_step, values);
        if (!mounted) return;
        setState(() => _step++);
      }
    } catch (e) {
      _error('No se pudo guardar el progreso: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Map<String, dynamic> _valuesForStep(int step) {
    final keys = <int, List<String>>{
      1: ['entry_months', 'entry_flexibility', 'monthly_income_range', 'income_verifiable', 'has_guarantor'],
      2: ['shared_before', 'previous_housing_reason', 'can_provide_reference'],
      3: ['cleanliness_style', 'schedule_type', 'works_from_home'],
      4: ['conflict_style', 'alcohol_frequency', 'party_frequency'],
      5: ['receives_visitors', 'visitors_sleep_over', 'sleepover_nights_per_month', 'has_pets', 'desired_home_environment', 'additional_info'],
      6: ['hobbies'],
      7: ['free_time_style', 'personality_traits'],
      8: ['preferred_home_social_style', 'preferred_roommate_values'],
    };
    return {for (final key in keys[step] ?? const <String>[]) key: _data[key]};
  }

  void _back() {
    if (_completed) {
      handleTenantNavigation(context, 0);
      return;
    }
    if (_step > 1) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
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
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: CohabiColors.turquoise))
            : _completed
            ? _buildCompleted()
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: _back,
                          borderRadius: BorderRadius.circular(40),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CohabiColors.border,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.025),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: CohabiColors.navy,
                              size: 20,
                            ),
                          ),
                        ),

                        const Expanded(
                          child: Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xFFF7F3FF),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 17,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Cohabi Selección ✨',
                                  style: TextStyle(
                                    color: CohabiColors.purple,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 46),
                      ],
                    ),

                    const SizedBox(height: 12),
                    SelectionProgress(step: _step),
                    const SizedBox(height: 17),
                    _stepHeader(),
                    const SizedBox(height: 20),
                    _stepBody(),
                    const SizedBox(height: 18),
                    SelectionPrimaryButton(
                      text: _step == 8 ? 'Completar mi perfil ✨' : 'Continuar',
                      loading: _saving,
                      onPressed: _continue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepHeader() {
    // En el paso 4 usamos una sola imagen como cabecera completa.
    // Esa imagen ya incluye:
    // - icono del corazón
    // - título "Tu forma de convivir 💜"
    // - texto descriptivo
    // - foto de los amigos
    //
    // Así evitamos duplicar título y subtítulo debajo.
    if (_step == 4) {
      return SizedBox(
        width: double.infinity,
        child: Image.asset(
          'assets/images/tenant_selection_lifestyle.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      );
    }

    if (_step == 6) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: CohabiColors.purple.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: CohabiColors.purple,
                size: 40,
              ),
            ),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cuéntanos qué te gusta ✨',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                      letterSpacing: -0.45,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tus aficiones pueden ayudarnos a encontrar personas con las que tengas más cosas en común.',
                    style: TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.42,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_step == 7) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: Color(0xFFE8FBFA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_outlined,
                color: CohabiColors.turquoise,
                size: 44,
              ),
            ),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Cómo es tu estilo de vida?',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                      letterSpacing: -0.35,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Queremos encontrar una convivencia que vaya con tu ritmo.',
                    style: TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.42,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    const titles = [
      'Un poco más sobre ti',
      'Tu experiencia\ncompartiendo piso 🏠',
      'Así es tu día a día',
      'Tu forma de convivir 💜',
      'La convivencia que buscas ✨',
      'Cuéntanos qué te gusta ✨',
      '¿Cómo es tu estilo de vida? 🌿',
      '¿Con quién te gustaría\ncompartir hogar? 💜',
    ];

    const subtitles = [
      'Esta información nos ayuda a encontrar viviendas donde tu perfil encaje.',
      'Queremos conocerte mejor para encontrar el piso y los compañeros ideales para ti.',
      'Queremos conocer tu rutina para encontrar compañeros con un estilo de vida compatible.',
      'Estas preguntas nos ayudan a entender qué es importante para ti en la convivencia diaria.',
      'Estas últimas preguntas nos ayudan a encontrar el hogar donde te sentirás más a gusto.',
      'Tus aficiones pueden ayudarnos a encontrar personas con las que tengas más cosas en común.',
      'Queremos encontrar una convivencia que vaya con tu ritmo.',
      'Queremos encontrar una convivencia que se adapte a lo que buscas.',
    ];

    final image = _headerImage();

    return Column(
      children: [
        if (image != null) ...[
          SizedBox(
            height: 105,
            width: 125,
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
        ] else ...[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: CohabiColors.purple.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _headerIcon(),
              color: CohabiColors.purple,
              size: 34,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          titles[_step - 1],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CohabiColors.navy,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.12,
            letterSpacing: -0.45,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            subtitles[_step - 1],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  String? _headerImage() {
    switch (_step) {
      case 1:
        return 'assets/images/tenant_selection_profile.png';
      case 2:
        return 'assets/images/tenant_selection_home.png';
      case 3:
        return 'assets/images/tenant_selection_routine.png';
      case 5:
        return 'assets/images/tenant_selection_coexistence.png';
      default:
        return null;
    }
  }

  IconData _headerIcon() {
    return [Icons.account_balance_wallet_outlined, Icons.home_outlined, Icons.wb_sunny_outlined, Icons.favorite_border_rounded, Icons.house_outlined, Icons.favorite_outline_rounded, Icons.eco_outlined, Icons.people_outline_rounded][_step - 1];
  }

  Widget _stepBody() {
    switch (_step) {
      case 1: return _step1();
      case 2: return _step2();
      case 3: return _step3();
      case 4: return _step4();
      case 5: return _step5();
      case 6: return _step6();
      case 7: return _step7();
      case 8: return _step8();
      default: return const SizedBox.shrink();
    }
  }

  Widget _step1() {
    final incomes = const [
      'Menos de 800 €',
      '1.000 €',
      '1.200 €',
      '1.500 €',
      '1.800 €',
      '2.000 €',
      '2.200 €',
      '2.500 € o más',
    ];

    return Column(
      children: [
        SelectionSection(
          title: '¿Cuándo te gustaría entrar? 📅',
          subtitle: 'Elige la opción que mejor encaje contigo.',
          icon: Icons.calendar_month_outlined,
          iconColor: CohabiColors.turquoise,
          iconBackground: const Color(0xFFE8FBFA),
          child: Column(
            children: [
              SizedBox(
                height: 86,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _entryModeCard(
                        label: 'Un mes',
                        icon: Icons.calendar_today_outlined,
                        selected: _data['entry_flexibility'] == 'single_month',
                        onTap: () {
                          setState(() {
                            _data['entry_flexibility'] = 'single_month';
                            _data['entry_months'] = <String>[];
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _entryModeCard(
                        label: 'Intervalo',
                        icon: Icons.date_range_outlined,
                        selected: _data['entry_flexibility'] == 'range',
                        onTap: () {
                          setState(() {
                            _data['entry_flexibility'] = 'range';
                            _data['entry_months'] = <String>[];
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _entryModeCard(
                        label: 'Me da igual',
                        icon: Icons.all_inclusive_rounded,
                        selected: _data['entry_flexibility'] == 'flexible',
                        onTap: () {
                          setState(() {
                            _data['entry_flexibility'] = 'flexible';
                            _data['entry_months'] = <String>[];
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (_data['entry_flexibility'] == 'single_month') ...[
                const SizedBox(height: 14),
                _singleMonthSelector(),
              ],
              if (_data['entry_flexibility'] == 'range') ...[
                const SizedBox(height: 14),
                _monthRangeSelector(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        SelectionSection(
          title: '¿Cuál es tu nivel aproximado de ingresos mensuales?',
          subtitle: 'Desliza para ver todas las opciones.',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: CohabiColors.turquoise,
          iconBackground: const Color(0xFFE8FBFA),
          child: SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: incomes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                const icons = <IconData>[
                  Icons.bar_chart_rounded,
                  Icons.monetization_on_outlined,
                  Icons.account_balance_wallet_outlined,
                  Icons.payments_outlined,
                  Icons.savings_outlined,
                  Icons.account_balance_rounded,
                  Icons.local_atm_outlined,
                  Icons.currency_exchange_rounded,
                ];
                return SizedBox(
                  width: 104,
                  child: _incomeOptionCard(
                    label: incomes[index],
                    icon: icons[index],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        _yesNoSection(
          '¿Puedes acreditar esos ingresos?',
          'income_verifiable',
          Icons.description_outlined,
          subtitle: 'Por ejemplo, con nómina, contrato o declaración.',
          iconColor: CohabiColors.purple,
          iconBackground: const Color(0xFFF1EBFF),
        ),
        const SizedBox(height: 14),
        _yesNoSection(
          '¿Dispones de avalista?',
          'has_guarantor',
          Icons.people_outline_rounded,
          subtitle: 'Alguien que pueda respaldar tu alquiler si es necesario.',
          iconColor: const Color(0xFFFF9B32),
          iconBackground: const Color(0xFFFFF2E3),
        ),
      ],
    );
  }

  Widget _entryModeCard({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.055)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? CohabiColors.turquoise : CohabiColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 23,
                color: selected ? CohabiColors.turquoise : CohabiColors.purple,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _incomeOptionCard({
    required String label,
    required IconData icon,
  }) {
    final selected = _data['monthly_income_range'] == label;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _set('monthly_income_range', label),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? CohabiColors.turquoise : CohabiColors.border,
              width: selected ? 1.7 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: selected ? CohabiColors.turquoise : CohabiColors.purple,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 11.5,
                  height: 1.18,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _entryMonthOptions() {
    return const [
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
    ];
  }

  Widget _singleMonthSelector() {
    final months = _entryMonthOptions();
    final selectedMonths = _list('entry_months');

    String? selected;
    if (selectedMonths.isNotEmpty && months.contains(selectedMonths.first)) {
      selected = selectedMonths.first;
    }

    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      decoration: _input('Selecciona un mes'),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: CohabiColors.purple,
      ),
      items: months
          .map(
            (month) => DropdownMenuItem<String>(
          value: month,
          child: Text(month, overflow: TextOverflow.ellipsis),
        ),
      )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        _set('entry_months', <String>[value]);
      },
    );
  }

  Widget _monthRangeSelector() {
    final months = _entryMonthOptions();
    final selectedMonths = _list('entry_months');

    String? from;
    String? to;

    if (selectedMonths.isNotEmpty && months.contains(selectedMonths.first)) {
      from = selectedMonths.first;
    }
    if (selectedMonths.length > 1 && months.contains(selectedMonths[1])) {
      to = selectedMonths[1];
    }

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: from,
            isExpanded: true,
            decoration: _input('Desde'),
            items: months
                .map(
                  (month) => DropdownMenuItem<String>(
                value: month,
                child: Text(month, overflow: TextOverflow.ellipsis),
              ),
            )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              final current = _list('entry_months');
              final currentTo =
              current.length > 1 && months.contains(current[1])
                  ? current[1]
                  : null;
              _set(
                'entry_months',
                <String>[
                  value,
                  if (currentTo != null) currentTo,
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: to,
            isExpanded: true,
            decoration: _input('Hasta'),
            items: months
                .map(
                  (month) => DropdownMenuItem<String>(
                value: month,
                child: Text(month, overflow: TextOverflow.ellipsis),
              ),
            )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              final current = _list('entry_months');
              final currentFrom =
              current.isNotEmpty && months.contains(current.first)
                  ? current.first
                  : null;
              _set(
                'entry_months',
                <String>[
                  if (currentFrom != null) currentFrom,
                  value,
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _step2() {
    final sharedBefore = _data['shared_before'] == true;

    return Column(
      children: [
        SelectionSection(
          title: '¿Has compartido piso anteriormente?',
          icon: Icons.groups_outlined,
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      child: _experienceOptionCard(
                        selected: _data['shared_before'] == true,
                        icon: Icons.home_work_outlined,
                        title: 'Sí, ya he\ncompartido piso',
                        subtitle: 'Tengo experiencia\nviviendo con otras\npersonas.',
                        onTap: () => _set('shared_before', true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _experienceOptionCard(
                        selected: _data['shared_before'] == false,
                        icon: Icons.auto_awesome_rounded,
                        title: 'No, sería mi\nprimera vez',
                        subtitle: 'Es la primera vez que\nvoy a compartir piso.',
                        onTap: () => _set('shared_before', false),
                      ),
                    ),
                  ],
                ),
              ),
              if (sharedBefore) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  decoration: BoxDecoration(
                    color: CohabiColors.turquoise.withValues(alpha: 0.055),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Cuéntanos un poco más sobre tu experiencia 😎',
                    style: TextStyle(
                      color: CohabiColors.turquoise,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _previousHousingController,
                  maxLength: 300,
                  maxLines: 4,
                  decoration: _input('¿Por qué dejaste tu anterior alojamiento?'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _yesNoSection(
          '¿Podrías aportar referencias de un propietario anterior?',
          'can_provide_reference',
          Icons.person_outline_rounded,
          subtitle: 'Si es así, podremos contactarle para conocer tu experiencia.',
        ),
      ],
    );
  }

  Widget _experienceOptionCard({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          height: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? CohabiColors.turquoise : CohabiColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: selected
                      ? CohabiColors.turquoise.withValues(alpha: 0.10)
                      : CohabiColors.purple.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 25,
                  color: selected ? CohabiColors.turquoise : CohabiColors.purple,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 13,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 10.8,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step3() {
    return Column(
      children: [
        SelectionSection(
          title: '¿Cómo eres con el orden?',
          subtitle: 'Elige la opción que mejor te describa.',
          icon: Icons.cleaning_services_outlined,
          iconColor: CohabiColors.purple,
          iconBackground: const Color(0xFFF1EBFF),
          child: Column(
            children: [
              _cleanlinessOption(
                value: 'Muy ordenado',
                title: 'Me gusta que las zonas comunes estén siempre limpias y ordenadas.',
                icon: Icons.cleaning_services_rounded,
                iconColor: CohabiColors.turquoise,
                iconBackground: const Color(0xFFE7FBF9),
              ),
              const SizedBox(height: 8),
              _cleanlinessOption(
                value: 'Flexible pero recojo',
                title: 'Soy flexible, pero procuro recoger lo que ensucio.',
                icon: Icons.auto_awesome_rounded,
                iconColor: CohabiColors.purple,
                iconBackground: const Color(0xFFF2ECFF),
              ),
              const SizedBox(height: 8),
              _cleanlinessOption(
                value: 'No me importa algo de desorden',
                title: 'No me importa que haya algo de desorden.',
                icon: Icons.sentiment_satisfied_alt_rounded,
                iconColor: const Color(0xFFFF9B32),
                iconBackground: const Color(0xFFFFF2E3),
              ),
              const SizedBox(height: 8),
              _cleanlinessOption(
                value: 'No suelo prestar mucha atención',
                title: 'No suelo prestar mucha atención al orden.',
                icon: Icons.sentiment_neutral_rounded,
                iconColor: const Color(0xFFFF6F91),
                iconBackground: const Color(0xFFFFEDF3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SelectionSection(
          title: '¿Cómo son normalmente tus horarios?',
          subtitle: 'Cuéntanos para entender mejor tu ritmo del día a día.',
          icon: Icons.schedule_outlined,
          child: SizedBox(
            height: 108,
            child: Row(
              children: [
                Expanded(
                  child: _routineOptionCard(
                    keyName: 'schedule_type',
                    value: 'Diurnos',
                    label: 'Diurnos',
                    icon: Icons.wb_sunny_outlined,
                    iconColor: const Color(0xFFFFA43B),
                    iconBackground: const Color(0xFFFFF2E3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _routineOptionCard(
                    keyName: 'schedule_type',
                    value: 'Nocturnos',
                    label: 'Nocturnos',
                    icon: Icons.nightlight_round,
                    iconColor: CohabiColors.purple,
                    iconBackground: const Color(0xFFF1EBFF),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _routineOptionCard(
                    keyName: 'schedule_type',
                    value: 'Variables',
                    label: 'Variables',
                    icon: Icons.sync_rounded,
                    iconColor: CohabiColors.turquoise,
                    iconBackground: const Color(0xFFE7FBF9),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SelectionSection(
          title: '¿Trabajas o estudias desde casa?',
          subtitle: 'Esto nos ayuda a conocer tus necesidades de espacio y tranquilidad.',
          icon: Icons.home_work_outlined,
          child: SizedBox(
            height: 108,
            child: Row(
              children: [
                Expanded(
                  child: _routineOptionCard(
                    keyName: 'works_from_home',
                    value: 'Todos los días',
                    label: 'Todos los días',
                    icon: Icons.home_outlined,
                    iconColor: CohabiColors.turquoise,
                    iconBackground: const Color(0xFFE7FBF9),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _routineOptionCard(
                    keyName: 'works_from_home',
                    value: 'Algunos días',
                    label: 'Algunos días',
                    icon: Icons.laptop_mac_outlined,
                    iconColor: CohabiColors.purple,
                    iconBackground: const Color(0xFFF1EBFF),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _routineOptionCard(
                    keyName: 'works_from_home',
                    value: 'No',
                    label: 'No',
                    icon: Icons.directions_walk_rounded,
                    iconColor: const Color(0xFFFFA43B),
                    iconBackground: const Color(0xFFFFF2E3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cleanlinessOption({
    required String value,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    final selected = _data['cleanliness_style'] == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _set('cleanliness_style', value),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? CohabiColors.turquoise : CohabiColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routineOptionCard({
    required String keyName,
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    final selected = _data[keyName] == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _set(keyName, value),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.045)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? CohabiColors.turquoise : CohabiColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 11.5,
                  height: 1.15,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step4() {
    return Column(
      children: [
        SelectionSection(
          title: 'Si surge algún problema con un compañero, ¿cómo sueles afrontarlo?',
          subtitle: 'Elige la opción que más se parezca a ti.',
          icon: Icons.forum_outlined,
          iconColor: CohabiColors.purple,
          iconBackground: const Color(0xFFF1EBFF),
          child: SizedBox(
            height: 190,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(
                  width: 150,
                  child: _conflictOptionCard(
                    value: 'Prefiero hablarlo',
                    title: 'Prefiero hablarlo',
                    subtitle: 'Hablo directamente con la otra persona de forma tranquila.',
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: CohabiColors.turquoise,
                    iconBackground: const Color(0xFFE7FBF9),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: _conflictOptionCard(
                    value: 'Evito el conflicto',
                    title: 'Evito el conflicto',
                    subtitle: 'Prefiero evitarlo si es posible.',
                    icon: Icons.nightlight_round,
                    iconColor: CohabiColors.purple,
                    iconBackground: const Color(0xFFF1EBFF),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: _conflictOptionCard(
                    value: 'Prefiero mediación',
                    title: 'Prefiero mediación',
                    subtitle: 'Me resulta más cómodo que otra persona ayude.',
                    icon: Icons.people_outline_rounded,
                    iconColor: const Color(0xFFFF9B32),
                    iconBackground: const Color(0xFFFFF2E3),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: _conflictOptionCard(
                    value: 'Otra forma',
                    title: 'Otra forma',
                    subtitle: 'Tengo otra manera de afrontarlo.',
                    icon: Icons.edit_outlined,
                    iconColor: const Color(0xFFFF6F91),
                    iconBackground: const Color(0xFFFFEDF3),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        SelectionSection(
          title: '¿Consumes alcohol con frecuencia?',
          subtitle: 'Sé honesto/a, no hay respuestas buenas ni malas.',
          icon: Icons.local_bar_outlined,
          iconColor: CohabiColors.purple,
          iconBackground: const Color(0xFFF1EBFF),
          child: SizedBox(
            height: 66,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(
                  width: 122,
                  child: _compactLifestyleCard(
                    keyName: 'alcohol_frequency',
                    value: 'Nunca',
                    label: 'Nunca',
                    icon: Icons.eco_outlined,
                    iconColor: CohabiColors.turquoise,
                    iconBackground: const Color(0xFFE7FBF9),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 150,
                  child: _compactLifestyleCard(
                    keyName: 'alcohol_frequency',
                    value: 'Ocasionalmente',
                    label: 'Ocasionalmente',
                    icon: Icons.local_bar_outlined,
                    iconColor: CohabiColors.purple,
                    iconBackground: const Color(0xFFF1EBFF),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 156,
                  child: _compactLifestyleCard(
                    keyName: 'alcohol_frequency',
                    value: 'Con frecuencia',
                    label: 'Con frecuencia',
                    icon: Icons.wine_bar_outlined,
                    iconColor: const Color(0xFFFF9B32),
                    iconBackground: const Color(0xFFFFF2E3),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        SelectionSection(
          title: '¿Sueles organizar fiestas o reuniones en casa?',
          subtitle: 'Piénsalo en tu día a día habitual.',
          icon: Icons.celebration_outlined,
          iconColor: CohabiColors.purple,
          iconBackground: const Color(0xFFF1EBFF),
          child: SizedBox(
            height: 66,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(
                  width: 122,
                  child: _compactLifestyleCard(
                    keyName: 'party_frequency',
                    value: 'Nunca',
                    label: 'Nunca',
                    icon: Icons.weekend_outlined,
                    iconColor: CohabiColors.turquoise,
                    iconBackground: const Color(0xFFE7FBF9),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 150,
                  child: _compactLifestyleCard(
                    keyName: 'party_frequency',
                    value: 'Ocasionalmente',
                    label: 'Ocasionalmente',
                    icon: Icons.celebration_outlined,
                    iconColor: CohabiColors.purple,
                    iconBackground: const Color(0xFFF1EBFF),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 150,
                  child: _compactLifestyleCard(
                    keyName: 'party_frequency',
                    value: 'Frecuentemente',
                    label: 'Frecuentemente',
                    icon: Icons.music_note_rounded,
                    iconColor: const Color(0xFFFF9B32),
                    iconBackground: const Color(0xFFFFF2E3),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F5FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEDE7FF)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0E8FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: CohabiColors.purple,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu privacidad es importante',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Usamos esta información solo para mejorar la compatibilidad y tu experiencia en Cohabi.',
                      style: TextStyle(
                        color: CohabiColors.textSecondary,
                        fontSize: 11.8,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.lock_outline_rounded,
                color: CohabiColors.purple,
                size: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _conflictOptionCard({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    final selected = _data['conflict_style'] == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _set('conflict_style', value),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? CohabiColors.turquoise : CohabiColors.border,
              width: selected ? 1.7 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 12.5,
                  height: 1.2,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CohabiColors.textSecondary,
                  fontSize: 10.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactLifestyleCard({
    required String keyName,
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    final selected = _data[keyName] == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _set(keyName, value),
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.055)
                : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected
                  ? CohabiColors.turquoise
                  : CohabiColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 11.2,
                    height: 1,
                    fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step5() {
    final receives = _data['receives_visitors'] == true;
    final sleepover = _data['visitors_sleep_over'] == true;
    final nights =
        (_data['sleepover_nights_per_month'] as num?)?.toInt() ?? 0;

    return Column(
      children: [
        // ============================================================
        // VISITAS + DORMIR + FRECUENCIA EN UNA SOLA TARJETA
        // ============================================================
        SelectionSection(
          title: '¿Recibes visitas habitualmente?',
          icon: Icons.groups_outlined,
          iconColor: CohabiColors.purple,
          iconBackground: const Color(0xFFF1EBFF),
          child: Column(
            children: [
              _inlineYesNo(
                keyName: 'receives_visitors',
              ),

              if (receives) ...[
                const SizedBox(height: 18),

                _subQuestionHeader(
                  icon: Icons.nightlight_round,
                  title: '¿Suelen quedarse a dormir?',
                ),

                const SizedBox(height: 10),

                _inlineYesNo(
                  keyName: 'visitors_sleep_over',
                ),

                if (sleepover) ...[
                  const SizedBox(height: 18),

                  _subQuestionHeader(
                    icon: Icons.calendar_month_outlined,
                    title: '¿Con qué frecuencia?',
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 52,
                      constraints: const BoxConstraints(maxWidth: 250),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: CohabiColors.turquoise,
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: nights > 0
                                ? () => _set(
                              'sleepover_nights_per_month',
                              nights - 1,
                            )
                                : null,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                            child: SizedBox(
                              width: 48,
                              height: double.infinity,
                              child: Icon(
                                Icons.remove_rounded,
                                color: nights > 0
                                    ? CohabiColors.navy
                                    : CohabiColors.textMuted,
                                size: 22,
                              ),
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 30,
                            color: CohabiColors.border,
                          ),

                          Expanded(
                            child: Text(
                              '$nights ${nights == 1 ? 'noche' : 'noches'} al mes',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: CohabiColors.navy,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 30,
                            color: CohabiColors.border,
                          ),

                          InkWell(
                            onTap: () => _set(
                              'sleepover_nights_per_month',
                              nights + 1,
                            ),
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12),
                            ),
                            child: const SizedBox(
                              width: 48,
                              height: double.infinity,
                              child: Icon(
                                Icons.add_rounded,
                                color: CohabiColors.navy,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ============================================================
        // MASCOTAS
        // ============================================================
        SelectionSection(
          title: '¿Tienes mascotas a tu cargo?',
          icon: Icons.pets_outlined,
          iconColor: CohabiColors.purple,
          iconBackground: const Color(0xFFF1EBFF),
          child: _inlineYesNo(
            keyName: 'has_pets',
          ),
        ),

        const SizedBox(height: 14),

        // ============================================================
        // AMBIENTE DEL HOGAR
        // ============================================================
        SelectionSection(
          title: '¿Qué ambiente te gustaría encontrar en casa?',
          subtitle: 'Elige el ambiente que mejor se adapta a ti.',
          icon: Icons.auto_awesome_outlined,
          iconColor: CohabiColors.purple,
          iconBackground: const Color(0xFFF1EBFF),
          child: SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                const values = <String>[
                  'Muy tranquilo',
                  'Tranquilo, con algo de vida social',
                  'Equilibrado',
                  'Sociable y con buen ambiente',
                  'Muy sociable',
                ];

                const icons = <IconData>[
                  Icons.eco_outlined,
                  Icons.local_cafe_outlined,
                  Icons.balance_outlined,
                  Icons.music_note_rounded,
                  Icons.celebration_outlined,
                ];

                const iconColors = <Color>[
                  Color(0xFF5DBB63),
                  CohabiColors.turquoise,
                  Color(0xFFFF9B32),
                  CohabiColors.purple,
                  Color(0xFFFF6F91),
                ];

                const iconBackgrounds = <Color>[
                  Color(0xFFEEF8ED),
                  Color(0xFFE7FBF9),
                  Color(0xFFFFF2E3),
                  Color(0xFFF1EBFF),
                  Color(0xFFFFEDF3),
                ];

                return SizedBox(
                  width: 132,
                  child: _homeEnvironmentCard(
                    value: values[index],
                    icon: icons[index],
                    iconColor: iconColors[index],
                    iconBackground: iconBackgrounds[index],
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ============================================================
        // INFORMACIÓN ADICIONAL
        // ============================================================
        SelectionSection(
          title: '¿Quieres contarnos algo más sobre ti?',
          subtitle:
          'Cuéntanos brevemente cómo eres, qué valoras al compartir piso o cualquier cosa que creas que pueda ayudarnos a conocerte.',
          icon: Icons.edit_outlined,
          iconColor: CohabiColors.purple,
          iconBackground: const Color(0xFFF1EBFF),
          child: TextField(
            controller: _additionalInfoController,
            maxLength: 500,
            maxLines: 4,
            decoration: _input('Escribe aquí...'),
          ),
        ),
      ],
    );
  }

  Widget _inlineYesNo({
    required String keyName,
  }) {
    final value = _data[keyName];

    return Row(
      children: [
        Expanded(
          child: _simpleSelectCard(
            label: 'Sí',
            selected: value == true,
            onTap: () => _set(keyName, true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _simpleSelectCard(
            label: 'No',
            selected: value == false,
            onTap: () => _set(keyName, false),
          ),
        ),
      ],
    );
  }

  Widget _simpleSelectCard({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 52,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.055)
                : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected
                  ? CohabiColors.turquoise
                  : CohabiColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 13.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _subQuestionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFF1EBFF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: CohabiColors.purple,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: CohabiColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _homeEnvironmentCard({
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    final selected = _data['desired_home_environment'] == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _set('desired_home_environment', value),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? CohabiColors.turquoise
                  : CohabiColors.border,
              width: selected ? 1.7 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 11.5,
                  height: 1.17,
                  fontWeight:
                  selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step6() {
    const interests = <Map<String, String>>[
      {
        'label': 'Deporte',
        'asset': 'assets/images/interest_sport.png',
      },
      {
        'label': 'Videojuegos',
        'asset': 'assets/images/interest_gaming.png',
      },
      {
        'label': 'Cine y series',
        'asset': 'assets/images/interest_movies.png',
      },
      {
        'label': 'Música',
        'asset': 'assets/images/interest_music.png',
      },
      {
        'label': 'Leer',
        'asset': 'assets/images/interest_reading.png',
      },
      {
        'label': 'Cocinar',
        'asset': 'assets/images/interest_cooking.png',
      },
      {
        'label': 'Viajar',
        'asset': 'assets/images/interest_travel.png',
      },
      {
        'label': 'Naturaleza',
        'asset': 'assets/images/interest_nature.png',
      },
      {
        'label': 'Arte y cultura',
        'asset': 'assets/images/interest_art.png',
      },
      {
        'label': 'Salir / vida social',
        'asset': 'assets/images/interest_social.png',
      },
      {
        'label': 'Vida sana',
        'asset': 'assets/images/interest_healthy_living.png',
      },
      {
        'label': 'Ver deportes',
        'asset': 'assets/images/interest_watch_sports.png',
      },
    ];

    final selected = _list('hobbies');

    return SelectionSection(
      title: '¿Qué te gusta hacer en tu tiempo libre?',
      subtitle: 'Elige hasta 4 opciones.',
      icon: Icons.favorite_border_rounded,
      iconColor: CohabiColors.purple,
      iconBackground: const Color(0xFFF1EBFF),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: interests.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              final item = interests[index];
              final label = item['label']!;
              final asset = item['asset']!;

              return _interestCard(
                label: label,
                asset: asset,
                selected: selected.contains(label),
                onTap: () => _toggleList('hobbies', label, max: 4),
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: CohabiColors.purple.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: CohabiColors.purple,
                  size: 20,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Selecciona hasta 4 opciones que más te representen.',
                    style: TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${selected.length}/4 seleccionadas',
                  style: const TextStyle(
                    color: CohabiColors.purple,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _interestCard({
    required String label,
    required String asset,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.045)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? CohabiColors.turquoise : CohabiColors.border,
              width: selected ? 1.7 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 66,
                      height: 66,
                      child: Image.asset(
                        asset,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 11.5,
                        height: 1.1,
                        fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 20,
                    height: 20,
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
          ),
        ),
      ),
    );
  }

  Widget _step7() {
    const lifestyleOptions = <Map<String, String>>[
      {
        'value': 'Plan casero',
        'asset': 'assets/images/lifestyle_home.png',
      },
      {
        'value': 'Un poco de todo',
        'asset': 'assets/images/lifestyle_mixed.png',
      },
      {
        'value': 'Soy de salir',
        'asset': 'assets/images/lifestyle_outgoing.png',
      },
      {
        'value': 'Muy social',
        'asset': 'assets/images/lifestyle_social.png',
      },
    ];

    const traitOptions = <Map<String, dynamic>>[
      {
        'label': 'Tranquilo',
        'icon': Icons.eco_outlined,
        'color': Color(0xFF18B8B0),
        'background': Color(0xFFE8FBFA),
      },
      {
        'label': 'Activo',
        'icon': Icons.bolt_rounded,
        'color': Color(0xFFFFB21A),
        'background': Color(0xFFFFF5DD),
      },
      {
        'label': 'Sociable',
        'icon': Icons.people_alt_outlined,
        'color': Color(0xFF5B79E8),
        'background': Color(0xFFEEF1FF),
      },
      {
        'label': 'Organizado',
        'icon': Icons.track_changes_rounded,
        'color': Color(0xFFFF607D),
        'background': Color(0xFFFFEDF2),
      },
      {
        'label': 'Creativo',
        'icon': Icons.palette_outlined,
        'color': Color(0xFFFF8B37),
        'background': Color(0xFFFFF0E4),
      },
      {
        'label': 'Deportivo',
        'icon': Icons.fitness_center_rounded,
        'color': Color(0xFF5ABF64),
        'background': Color(0xFFEDF8EE),
      },
      {
        'label': 'Estudioso',
        'icon': Icons.menu_book_outlined,
        'color': Color(0xFF398BD8),
        'background': Color(0xFFEAF5FF),
      },
      {
        'label': 'Profesional',
        'icon': Icons.work_outline_rounded,
        'color': Color(0xFFAA734C),
        'background': Color(0xFFF6EEE8),
      },
      {
        'label': 'Nocturno',
        'icon': Icons.nightlight_round,
        'color': CohabiColors.purple,
        'background': Color(0xFFF1EBFF),
      },
      {
        'label': 'Madrugador',
        'icon': Icons.wb_twilight_rounded,
        'color': Color(0xFFFFA43B),
        'background': Color(0xFFFFF2E3),
      },
      {
        'label': 'Espontáneo',
        'icon': Icons.celebration_outlined,
        'color': Color(0xFFFF6F91),
        'background': Color(0xFFFFEDF3),
      },
      {
        'label': 'Independiente',
        'icon': Icons.self_improvement_rounded,
        'color': CohabiColors.turquoise,
        'background': Color(0xFFE8FBFA),
      },
    ];

    final selectedTraits = _list('personality_traits');

    return Column(
      children: [
        SelectionSection(
          title: '¿Cómo disfrutas más de tu tiempo libre?',
          subtitle: 'Elige 1 opción.',
          icon: Icons.weekend_outlined,
          iconColor: CohabiColors.turquoise,
          iconBackground: const Color(0xFFE8FBFA),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lifestyleOptions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1672 / 941,
            ),
            itemBuilder: (context, index) {
              final item = lifestyleOptions[index];
              final value = item['value']!;
              final asset = item['asset']!;

              return _lifestyleImageCard(
                value: value,
                asset: asset,
                selected: _data['free_time_style'] == value,
                onTap: () => _set('free_time_style', value),
              );
            },
          ),
        ),

        const SizedBox(height: 14),

        SelectionSection(
          title: '¿Cómo te definirías?',
          subtitle: 'Elige hasta 3 opciones.',
          icon: Icons.eco_outlined,
          iconColor: CohabiColors.turquoise,
          iconBackground: const Color(0xFFE8FBFA),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: traitOptions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  childAspectRatio: 2.65,
                ),
                itemBuilder: (context, index) {
                  final item = traitOptions[index];
                  final label = item['label'] as String;
                  final icon = item['icon'] as IconData;
                  final color = item['color'] as Color;
                  final background = item['background'] as Color;
                  final selected = selectedTraits.contains(label);

                  return _traitCard(
                    label: label,
                    icon: icon,
                    iconColor: color,
                    iconBackground: background,
                    selected: selected,
                    onTap: () =>
                        _toggleList('personality_traits', label, max: 3),
                  );
                },
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: CohabiColors.purple.withValues(alpha: 0.055),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: CohabiColors.purple,
                      size: 20,
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'Selecciona hasta 3 características que mejor te representen.',
                        style: TextStyle(
                          color: CohabiColors.textSecondary,
                          fontSize: 11.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${selectedTraits.length}/3 seleccionadas',
                      style: const TextStyle(
                        color: CohabiColors.purple,
                        fontSize: 11.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _lifestyleImageCard({
    required String value,
    required String asset,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? CohabiColors.turquoise : Colors.transparent,
              width: selected ? 2 : 0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(selected ? 14 : 16),
            child: Image.asset(
              asset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _traitCard({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? CohabiColors.turquoise.withValues(alpha: 0.055)
                : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? CohabiColors.turquoise : CohabiColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 11.5,
                    fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: CohabiColors.turquoise,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step8() {
    const social = ['Cada uno a lo suyo', 'Compartir algunos momentos', 'Hacer bastante vida juntos', 'Me adapto'];
    const values = ['Limpieza y orden', 'Respeto', 'Comunicación', 'Buen ambiente', 'Tranquilidad', 'Hacer planes juntos', 'Privacidad e independencia', 'Respetar horarios', 'Confianza'];
    return Column(children: [
      _singleSection('Cuando estás en casa con tus compañeros, ¿qué te gustaría?', 'preferred_home_social_style', social, Icons.groups_outlined),
      const SizedBox(height: 14),
      SelectionSection(
        title: '¿Qué valoras más en las personas con las que vives?',
        subtitle: 'Elige las 3 más importantes.',
        icon: Icons.favorite_border_rounded,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (v) => SizedBox(
              width: 210,
              child: ChoiceTile(
                label: v,
                selected: _list('preferred_roommate_values').contains(v),
                onTap: () => _toggleList('preferred_roommate_values', v, max: 3),
              ),
            ),
          )
              .toList(),
        ),
      ),
    ]);
  }

  Widget _yesNoSection(
      String title,
      String key,
      IconData icon, {
        String? subtitle,
        Color? iconColor,
        Color? iconBackground,
      }) {
    return SelectionSection(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      iconBackground: iconBackground,
      child: Row(
        children: [
          Expanded(
            child: ChoiceTile(
              label: 'Sí',
              selected: _data[key] == true,
              onTap: () => _set(key, true),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ChoiceTile(
              label: 'No',
              selected: _data[key] == false,
              onTap: () => _set(key, false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _singleSection(String title, String key, List<String> options, IconData icon) {
    return SelectionSection(
      title: title,
      icon: icon,
      child: Column(children: options.map((v) => Padding(padding: const EdgeInsets.only(bottom: 8), child: ChoiceTile(label: v, selected: _data[key] == v, onTap: () => _set(key, v)))).toList()),
    );
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: CohabiColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: CohabiColors.turquoise, width: 1.4)),
    );
  }

  Widget _buildCompleted() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      child: Column(
        children: [
          const Text('Cohabi Selección ✨', style: TextStyle(color: CohabiColors.purple, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(gradient: CohabiColors.primaryGradient, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 70),
          ),
          const SizedBox(height: 24),
          const Text('¡Felicidades!', style: TextStyle(color: CohabiColors.navy, fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Has completado tu perfil 💜', textAlign: TextAlign.center, style: TextStyle(color: CohabiColors.navy, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          const Text('Ya tenemos todo lo necesario para analizar tu compatibilidad y ayudarte a encontrar opciones que encajen contigo.', textAlign: TextAlign.center, style: TextStyle(color: CohabiColors.textSecondary, fontSize: 15, height: 1.5)),
          const SizedBox(height: 30),
          SelectionSection(
            title: 'Cohabi Selección está listo ✨',
            subtitle:
            'El motor de matching utilizará este perfil junto con tus preferencias de búsqueda.',
            icon: Icons.auto_awesome_rounded,
            child: SelectionPrimaryButton(
              text: 'Ver mis mejores opciones',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TenantBestMatchesScreen(),
                  ),
                      (_) => false,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _completed = false;
                _step = 1;
              });
            },
            child: const Text(
              'Editar mi perfil de Selección',
              style: TextStyle(
                color: CohabiColors.purple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
