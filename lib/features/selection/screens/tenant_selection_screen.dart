import 'package:flutter/material.dart';

import '../../../core/navigation/tenant_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tenant_bottom_navigation.dart';
import '../../selection/services/tenant_selection_service.dart';
import '../results/screens/tenant_best_matches_screen.dart';
import '../widgets/selection_widgets.dart';

class TenantSelectionScreen extends StatefulWidget {
  const TenantSelectionScreen({super.key});

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
        _step = profile.currentStep.clamp(1, 8);
        _completed = profile.completed;
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
        if (_list('entry_months').isEmpty || _data['monthly_income_range'] == null || _data['income_verifiable'] == null || _data['has_guarantor'] == null) {
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
                                  IconButton(onPressed: _back, icon: const Icon(Icons.arrow_back_ios_new_rounded, color: CohabiColors.navy)),
                                  const Expanded(
                                    child: Center(
                                      child: Text('Cohabi Selección ✨', style: TextStyle(color: CohabiColors.purple, fontSize: 18, fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SelectionProgress(step: _step),
                              const SizedBox(height: 24),
                              _stepHeader(),
                              const SizedBox(height: 24),
                              _stepBody(),
                              const SizedBox(height: 24),
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
    const titles = [
      'Un poco más sobre ti',
      'Tu experiencia compartiendo piso 🏠',
      'Así es tu día a día',
      'Tu forma de convivir 💜',
      'La convivencia que buscas ✨',
      'Cuéntanos qué te gusta ✨',
      '¿Cómo es tu estilo de vida? 🌿',
      '¿Con quién te gustaría compartir hogar? 💜',
    ];
    const subtitles = [
      'Esta información nos ayuda a encontrar viviendas donde tu perfil encaje.',
      'Queremos conocerte mejor para encontrar el piso y los compañeros ideales para ti.',
      'Queremos conocer tu rutina para encontrar compañeros con un estilo de vida compatible.',
      'Estas preguntas nos ayudan a entender qué es importante para ti en la convivencia diaria.',
      'Estas preguntas nos ayudan a encontrar el hogar donde te sentirás más a gusto.',
      'Tus aficiones pueden ayudarnos a encontrar personas con las que tengas más cosas en común.',
      'Queremos encontrar una convivencia que vaya con tu ritmo.',
      'Queremos encontrar una convivencia que se adapte a lo que buscas.',
    ];
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(color: CohabiColors.purpleSoft, shape: BoxShape.circle),
          child: Icon(_headerIcon(), color: CohabiColors.purple, size: 36),
        ),
        const SizedBox(height: 14),
        Text(titles[_step - 1], textAlign: TextAlign.center, style: const TextStyle(color: CohabiColors.navy, fontSize: 29, fontWeight: FontWeight.w800, height: 1.15)),
        const SizedBox(height: 8),
        Text(subtitles[_step - 1], textAlign: TextAlign.center, style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 14, height: 1.45)),
      ],
    );
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
    final months = const ['Agosto', 'Septiembre', 'Octubre', 'Noviembre'];
    final incomes = const ['Hasta 800 €', '801 € - 1.200 €', '1.201 € - 1.800 €', '1.801 € - 2.500 €', 'Más de 2.500 €'];
    return Column(children: [
      SelectionSection(
        title: '¿Cuándo te gustaría entrar? 📅',
        subtitle: 'Puedes seleccionar uno o varios meses.',
        icon: Icons.calendar_month_outlined,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: months.map((m) => SizedBox(width: 170, child: ChoiceTile(label: m, selected: _list('entry_months').contains(m), onTap: () => _toggleList('entry_months', m), icon: Icons.calendar_today_outlined))).toList(),
        ),
      ),
      const SizedBox(height: 14),
      SelectionSection(
        title: '¿Cuál es tu nivel aproximado de ingresos mensuales?',
        icon: Icons.account_balance_wallet_outlined,
        child: Column(children: incomes.map((v) => Padding(padding: const EdgeInsets.only(bottom: 8), child: ChoiceTile(label: v, selected: _data['monthly_income_range'] == v, onTap: () => _set('monthly_income_range', v)))).toList()),
      ),
      const SizedBox(height: 14),
      _yesNoSection('¿Puedes acreditar esos ingresos?', 'income_verifiable', Icons.description_outlined),
      const SizedBox(height: 14),
      _yesNoSection('¿Dispones de avalista?', 'has_guarantor', Icons.people_outline_rounded),
    ]);
  }

  Widget _step2() {
    return Column(children: [
      _yesNoSection('¿Has compartido piso anteriormente?', 'shared_before', Icons.groups_outlined),
      if (_data['shared_before'] == true) ...[
        const SizedBox(height: 14),
        SelectionSection(
          title: '¿Por qué dejaste tu anterior alojamiento?',
          subtitle: 'Cuéntanos brevemente el motivo principal.',
          icon: Icons.chat_bubble_outline_rounded,
          child: TextField(
            controller: _previousHousingController,
            maxLength: 300,
            maxLines: 4,
            decoration: _input('Escribe aquí...'),
          ),
        ),
      ],
      const SizedBox(height: 14),
      _yesNoSection('¿Podrías aportar referencias de un propietario anterior?', 'can_provide_reference', Icons.person_outline_rounded),
    ]);
  }

  Widget _step3() {
    return Column(children: [
      _singleSection('¿Cómo eres con el orden?', 'cleanliness_style', const ['Muy ordenado', 'Flexible pero recojo', 'No me importa algo de desorden', 'No suelo prestar mucha atención'], Icons.cleaning_services_outlined),
      const SizedBox(height: 14),
      _singleSection('¿Cómo son normalmente tus horarios?', 'schedule_type', const ['Diurnos', 'Nocturnos', 'Variables'], Icons.schedule_outlined),
      const SizedBox(height: 14),
      _singleSection('¿Trabajas o estudias desde casa?', 'works_from_home', const ['Todos los días', 'Algunos días', 'No'], Icons.laptop_outlined),
    ]);
  }

  Widget _step4() {
    return Column(children: [
      _singleSection('Si surge algún problema con un compañero, ¿cómo sueles afrontarlo?', 'conflict_style', const ['Prefiero hablarlo', 'Evito el conflicto', 'Prefiero mediación', 'Otra forma'], Icons.forum_outlined),
      const SizedBox(height: 14),
      _singleSection('¿Consumes alcohol con frecuencia?', 'alcohol_frequency', const ['Nunca', 'Ocasionalmente', 'Con frecuencia'], Icons.local_bar_outlined),
      const SizedBox(height: 14),
      _singleSection('¿Sueles organizar fiestas o reuniones en casa?', 'party_frequency', const ['Nunca', 'Ocasionalmente', 'Frecuentemente'], Icons.celebration_outlined),
    ]);
  }

  Widget _step5() {
    final receives = _data['receives_visitors'] == true;
    final sleepover = _data['visitors_sleep_over'] == true;
    final nights = (_data['sleepover_nights_per_month'] as num?)?.toInt() ?? 0;
    return Column(children: [
      _yesNoSection('¿Recibes visitas habitualmente?', 'receives_visitors', Icons.groups_outlined),
      if (receives) ...[
        const SizedBox(height: 14),
        _yesNoSection('¿Suelen quedarse a dormir?', 'visitors_sleep_over', Icons.night_shelter_outlined),
        if (sleepover) ...[
          const SizedBox(height: 14),
          SelectionSection(
            title: '¿Con qué frecuencia?',
            icon: Icons.calendar_month_outlined,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(onPressed: nights > 0 ? () => _set('sleepover_nights_per_month', nights - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
              Text('$nights noches al mes', style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w700, fontSize: 16)),
              IconButton(onPressed: () => _set('sleepover_nights_per_month', nights + 1), icon: const Icon(Icons.add_circle_outline)),
            ]),
          ),
        ],
      ],
      const SizedBox(height: 14),
      _yesNoSection('¿Tienes mascotas a tu cargo?', 'has_pets', Icons.pets_outlined),
      const SizedBox(height: 14),
      _singleSection('¿Qué ambiente te gustaría encontrar en casa?', 'desired_home_environment', const ['Muy tranquilo', 'Tranquilo, con algo de vida social', 'Equilibrado', 'Sociable y con buen ambiente', 'Muy sociable'], Icons.auto_awesome_outlined),
      const SizedBox(height: 14),
      SelectionSection(
        title: '¿Quieres contarnos algo más sobre ti?',
        subtitle: 'Cualquier cosa que creas que pueda ayudarnos a conocerte.',
        icon: Icons.edit_outlined,
        child: TextField(controller: _additionalInfoController, maxLength: 500, maxLines: 4, decoration: _input('Escribe aquí...')),
      ),
    ]);
  }

  Widget _step6() {
    const hobbies = ['Deporte', 'Videojuegos', 'Cine y series', 'Música', 'Leer', 'Cocinar', 'Viajar', 'Naturaleza', 'Arte y cultura', 'Salir / vida social', 'Bienestar / yoga', 'Ver deportes'];
    return SelectionSection(
      title: '¿Qué te gusta hacer en tu tiempo libre?',
      subtitle: 'Elige hasta 4 opciones.',
      icon: Icons.favorite_border_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: hobbies
            .map(
              (v) => SizedBox(
                width: 210,
                child: ChoiceTile(
                  label: v,
                  selected: _list('hobbies').contains(v),
                  onTap: () => _toggleList('hobbies', v, max: 4),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _step7() {
    const styles = ['Plan casero', 'Un poco de todo', 'Soy de salir', 'Muy social'];
    const traits = ['Tranquilo', 'Activo', 'Sociable', 'Organizado', 'Creativo', 'Deportivo', 'Estudioso', 'Profesional', 'Nocturno', 'Madrugador', 'Espontáneo', 'Independiente'];
    return Column(children: [
      _singleSection('¿Cómo disfrutas más de tu tiempo libre?', 'free_time_style', styles, Icons.weekend_outlined),
      const SizedBox(height: 14),
      SelectionSection(
        title: '¿Cómo te definirías?',
        subtitle: 'Elige hasta 3 opciones.',
        icon: Icons.eco_outlined,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: traits
              .map(
                (v) => SizedBox(
                  width: 210,
                  child: ChoiceTile(
                    label: v,
                    selected: _list('personality_traits').contains(v),
                    onTap: () => _toggleList('personality_traits', v, max: 3),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ]);
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

  Widget _yesNoSection(String title, String key, IconData icon) {
    return SelectionSection(
      title: title,
      icon: icon,
      child: Row(children: [
        Expanded(child: ChoiceTile(label: 'Sí', selected: _data[key] == true, onTap: () => _set(key, true))),
        const SizedBox(width: 10),
        Expanded(child: ChoiceTile(label: 'No', selected: _data[key] == false, onTap: () => _set(key, false))),
      ]),
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
            subtitle: 'El motor de matching utilizará este perfil junto con tus preferencias de búsqueda.',
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
            onPressed: () async {
              await _service.restart();
              if (!mounted) return;
              setState(() {
                _completed = false;
                _step = 1;
              });
            },
            child: const Text('Editar mi perfil de Selección', style: TextStyle(color: CohabiColors.purple, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
