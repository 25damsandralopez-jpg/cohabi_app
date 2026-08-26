import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../services/tenant_preferences_service.dart';

class TenantPreferencesScreen extends StatefulWidget {
  const TenantPreferencesScreen({super.key});

  @override
  State<TenantPreferencesScreen> createState() => _TenantPreferencesScreenState();
}

class _TenantPreferencesScreenState extends State<TenantPreferencesScreen> {
  final _service = TenantPreferencesService();

  bool _loading = true;
  bool _saving = false;

  final _city = TextEditingController();
  final _zone = TextEditingController();
  final _previousHousingReason = TextEditingController();
  final _additionalInfo = TextEditingController();

  Map<String, dynamic> _tenantRaw = {};
  Map<String, dynamic> _selectionRaw = {};

  DateTime? _entryDate;
  double _budget = 450;

  String _accommodationType = 'Habitación';
  String _stayDuration = '6 a 12 meses';
  String _roomSize = 'Indiferente';
  String _occupation = 'Ambos';
  String _monthlyIncome = 'Selecciona una opción';
  String _desiredEnvironment = 'Tranquilo';

  bool _smoker = false;
  bool _hasPet = false;
  bool _hasGuarantor = true;
  bool _shareRoom = false;

  String _entryFlexibility = 'flexible';
  List<String> _entryMonths = [];
  String _selectionIncome = '1.000 € - 1.500 €';
  bool _incomeVerifiable = false;
  bool _sharedBefore = false;
  bool _canProvideReference = false;
  String _cleanlinessStyle = 'Flexible pero recojo';
  String _scheduleType = 'Diurnos';
  String _worksFromHome = 'Algunos días';
  String _conflictStyle = 'Hablarlo directamente';
  String _alcoholFrequency = 'Ocasionalmente';
  String _partyFrequency = 'Pocas veces';
  bool _receivesVisitors = true;
  bool _visitorsSleepOver = false;
  int _sleepoverNightsPerMonth = 0;
  String _selectionEnvironment = 'Tranquilo';
  List<String> _hobbies = [];
  String _freeTimeStyle = 'Planes tranquilos';
  List<String> _personalityTraits = [];
  String _preferredSocialStyle = 'Compartir algunos momentos';
  List<String> _preferredRoommateValues = [];

  static const _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _city.dispose();
    _zone.dispose();
    _previousHousingReason.dispose();
    _additionalInfo.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _service.load();
      final tenant = Map<String, dynamic>.from(data['tenant'] as Map);
      final selection = Map<String, dynamic>.from(data['selection'] as Map);

      _tenantRaw = tenant;
      _selectionRaw = selection;

      _city.text = tenant['search_city']?.toString() ?? '';
      _zone.text = tenant['search_zone']?.toString() ?? '';
      _entryDate = _parseDate(tenant['entry_date']);
      _budget = _number(tenant['max_monthly_budget'], 450).clamp(200, 2000).toDouble();
      _accommodationType = _string(tenant['accommodation_type'], 'Habitación');
      _stayDuration = _string(tenant['stay_duration'], '6 a 12 meses');
      _roomSize = _string(tenant['room_size'], 'Indiferente');
      _occupation = _string(tenant['occupation'], 'Ambos');
      _monthlyIncome = _string(tenant['monthly_income'], 'Selecciona una opción');
      _desiredEnvironment = _string(tenant['desired_environment'], 'Tranquilo');
      _smoker = _bool(tenant['smoker']);
      _hasPet = _bool(tenant['has_pet']);
      _hasGuarantor = _bool(tenant['has_guarantor'], fallback: true);
      _shareRoom = _bool(tenant['share_room']);

      _entryFlexibility = _string(selection['entry_flexibility'], 'flexible');
      _entryMonths = _stringList(selection['entry_months']);
      _selectionIncome = _string(selection['monthly_income_range'], '1.000 € - 1.500 €');
      _incomeVerifiable = _bool(selection['income_verifiable']);
      _sharedBefore = _bool(selection['shared_before']);
      _canProvideReference = _bool(selection['can_provide_reference']);
      _previousHousingReason.text = selection['previous_housing_reason']?.toString() ?? '';
      _cleanlinessStyle = _string(selection['cleanliness_style'], 'Flexible pero recojo');
      _scheduleType = _string(selection['schedule_type'], 'Diurnos');
      _worksFromHome = _string(selection['works_from_home'], 'Algunos días');
      _conflictStyle = _string(selection['conflict_style'], 'Hablarlo directamente');
      _alcoholFrequency = _string(selection['alcohol_frequency'], 'Ocasionalmente');
      _partyFrequency = _string(selection['party_frequency'], 'Pocas veces');
      _receivesVisitors = _bool(selection['receives_visitors'], fallback: true);
      _visitorsSleepOver = _bool(selection['visitors_sleep_over']);
      _sleepoverNightsPerMonth = (selection['sleepover_nights_per_month'] as num?)?.toInt() ?? 0;
      _selectionEnvironment = _string(selection['desired_home_environment'], _desiredEnvironment);
      _additionalInfo.text = selection['additional_info']?.toString() ?? '';
      _hobbies = _stringList(selection['hobbies']);
      _freeTimeStyle = _string(selection['free_time_style'], 'Planes tranquilos');
      _personalityTraits = _stringList(selection['personality_traits']);
      _preferredSocialStyle = _string(selection['preferred_home_social_style'], 'Compartir algunos momentos');
      _preferredRoommateValues = _stringList(selection['preferred_roommate_values']);

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _error('No se pudieron cargar tus preferencias: $e');
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_city.text.trim().isEmpty) {
      _error('Indica la ciudad en la que buscas vivienda.');
      return;
    }
    if (_entryDate == null) {
      _error('Selecciona una fecha de entrada aproximada.');
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.save(
        tenant: {
          'search_city': _city.text.trim(),
          'search_zone': _zone.text.trim(),
          'accommodation_type': _accommodationType,
          'entry_date': _isoDate(_entryDate!),
          'stay_duration': _stayDuration,
          'max_monthly_budget': _budget.round(),
          'room_size': _roomSize,
          'occupation': _occupation,
          'monthly_income': _monthlyIncome,
          'desired_environment': _desiredEnvironment,
          'smoker': _encodeLikeOriginal(_tenantRaw['smoker'], _smoker),
          'has_pet': _encodeLikeOriginal(_tenantRaw['has_pet'], _hasPet),
          'has_guarantor': _encodeLikeOriginal(_tenantRaw['has_guarantor'], _hasGuarantor),
          'share_room': _encodeLikeOriginal(_tenantRaw['share_room'], _shareRoom),
        },
        selection: {
          'entry_months': _entryMonths,
          'entry_flexibility': _entryFlexibility,
          'monthly_income_range': _selectionIncome,
          'income_verifiable': _incomeVerifiable,
          'has_guarantor': _hasGuarantor,
          'shared_before': _sharedBefore,
          'previous_housing_reason': _previousHousingReason.text.trim(),
          'can_provide_reference': _canProvideReference,
          'cleanliness_style': _cleanlinessStyle,
          'schedule_type': _scheduleType,
          'works_from_home': _worksFromHome,
          'conflict_style': _conflictStyle,
          'alcohol_frequency': _alcoholFrequency,
          'party_frequency': _partyFrequency,
          'receives_visitors': _receivesVisitors,
          'visitors_sleep_over': _visitorsSleepOver,
          'sleepover_nights_per_month': _sleepoverNightsPerMonth,
          'has_pets': _hasPet,
          'desired_home_environment': _selectionEnvironment,
          'additional_info': _additionalInfo.text.trim(),
          'hobbies': _hobbies,
          'free_time_style': _freeTimeStyle,
          'personality_traits': _personalityTraits,
          'preferred_home_social_style': _preferredSocialStyle,
          'preferred_roommate_values': _preferredRoommateValues,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferencias actualizadas. Recalculando tus opciones…'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _error('No se pudieron guardar tus preferencias: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  dynamic _encodeLikeOriginal(dynamic original, bool value) {
    if (original is bool) return value;
    return value ? 'Sí' : 'No';
  }

  Future<void> _pickEntryDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _entryDate != null && !_entryDate!.isBefore(now) ? _entryDate! : now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );
    if (selected != null) setState(() => _entryDate = selected);
  }

  void _error(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _string(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  double _number(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  bool _bool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    final text = value?.toString().trim().toLowerCase() ?? '';
    if (['sí', 'si', 'true', 'yes', '1'].contains(text)) return true;
    if (['no', 'false', '0'].contains(text)) return false;
    return fallback;
  }

  List<String> _stringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return <String>[];
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _two(int value) => value.toString().padLeft(2, '0');
  String _isoDate(DateTime value) => '${value.year}-${_two(value.month)}-${_two(value.day)}';
  String _displayDate(DateTime value) => '${_two(value.day)}/${_two(value.month)}/${value.year}';

  List<String> _optionsWithCurrent(List<String> values, String current) {
    return values.contains(current) ? values : [current, ...values];
  }

  void _toggleList(List<String> target, String value, {int? max}) {
    setState(() {
      if (target.contains(value)) {
        target.remove(value);
      } else {
        if (max != null && target.length >= max) {
          _error('Puedes seleccionar hasta $max opciones.');
          return;
        }
        target.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(
        backgroundColor: CohabiColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: CohabiColors.navy),
        ),
        title: const Text(
          'Mis preferencias',
          style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CohabiColors.turquoise))
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
              children: [
                _intro(),
                const SizedBox(height: 18),
                _section(
                  title: 'Búsqueda',
                  subtitle: 'Define dónde, cuándo y cuánto quieres pagar.',
                  icon: Icons.search_rounded,
                  children: [
                    _textField(_city, 'Ciudad', Icons.location_city_outlined),
                    const SizedBox(height: 12),
                    _textField(_zone, 'Zona preferida', Icons.location_on_outlined, optional: true),
                    const SizedBox(height: 12),
                    _dropdown('Tipo de alojamiento', _accommodationType, const ['Habitación', 'Piso completo'], (v) => setState(() => _accommodationType = v)),
                    const SizedBox(height: 12),
                    _dateTile(),
                    const SizedBox(height: 12),
                    _dropdown('Duración prevista', _stayDuration, const ['Menos de 3 meses', '3 a 6 meses', '6 a 12 meses', 'Más de 12 meses'], (v) => setState(() => _stayDuration = v)),
                    const SizedBox(height: 14),
                    _budgetSlider(),
                    const SizedBox(height: 12),
                    _dropdown('Tamaño de habitación', _roomSize, const ['Pequeña', 'Mediana', 'Grande', 'Indiferente'], (v) => setState(() => _roomSize = v)),
                    const SizedBox(height: 12),
                    _yesNo('¿Compartirías habitación?', _shareRoom, (v) => setState(() => _shareRoom = v)),
                  ],
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Economía',
                  subtitle: 'Datos que ayudan a validar los requisitos de cada piso.',
                  icon: Icons.account_balance_wallet_outlined,
                  children: [
                    _dropdown('Situación', _occupation, const ['Estudiante', 'Trabajador', 'Ambos'], (v) => setState(() => _occupation = v)),
                    const SizedBox(height: 12),
                    _dropdown('Ingresos mensuales', _monthlyIncome, const ['Selecciona una opción', 'Menos de 1.000 €', '1.000 € - 1.500 €', '1.500 € - 2.000 €', '2.000 € - 2.500 €', '2.500 € - 3.000 €', 'Más de 3.000 €'], (v) => setState(() => _monthlyIncome = v)),
                    const SizedBox(height: 12),
                    _dropdown('Rango usado en Cohabi Selección', _selectionIncome, const ['Menos de 1.000 €', '1.000 € - 1.500 €', '1.500 € - 2.000 €', '2.000 € - 2.500 €', '2.500 € - 3.000 €', 'Más de 3.000 €'], (v) => setState(() => _selectionIncome = v)),
                    const SizedBox(height: 12),
                    _yesNo('¿Puedes justificar ingresos?', _incomeVerifiable, (v) => setState(() => _incomeVerifiable = v)),
                    const SizedBox(height: 10),
                    _yesNo('¿Tienes avalista?', _hasGuarantor, (v) => setState(() => _hasGuarantor = v)),
                  ],
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Entrada',
                  subtitle: 'Ajusta la flexibilidad con la que puedes mudarte.',
                  icon: Icons.calendar_month_outlined,
                  children: [
                    _dropdown('Flexibilidad', _entryFlexibility, const ['single_month', 'range', 'flexible'], (v) => setState(() => _entryFlexibility = v), labels: const {'single_month': 'Un mes concreto', 'range': 'Rango de meses', 'flexible': 'Soy flexible'}),
                    const SizedBox(height: 12),
                    _multiChoice('Meses posibles', _months, _entryMonths, max: _entryFlexibility == 'single_month' ? 1 : (_entryFlexibility == 'range' ? 2 : null)),
                  ],
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Vivienda y convivencia',
                  subtitle: 'Preferencias que afectan al día a día en casa.',
                  icon: Icons.home_outlined,
                  children: [
                    _yesNo('¿Fumas?', _smoker, (v) => setState(() => _smoker = v)),
                    const SizedBox(height: 10),
                    _yesNo('¿Tienes mascota?', _hasPet, (v) => setState(() => _hasPet = v)),
                    const SizedBox(height: 12),
                    _dropdown('Ambiente que buscas', _desiredEnvironment, const ['Tranquilo', 'Social', 'Indiferente'], (v) => setState(() { _desiredEnvironment = v; _selectionEnvironment = v; })),
                    const SizedBox(height: 12),
                    _dropdown('Orden y limpieza', _cleanlinessStyle, const ['Muy ordenado', 'Flexible pero recojo', 'No me importa algo de desorden', 'No suelo prestar mucha atención'], (v) => setState(() => _cleanlinessStyle = v)),
                    const SizedBox(height: 12),
                    _dropdown('Horarios', _scheduleType, const ['Diurnos', 'Nocturnos', 'Variables'], (v) => setState(() => _scheduleType = v)),
                    const SizedBox(height: 12),
                    _dropdown('Trabajo/estudio desde casa', _worksFromHome, const ['Todos los días', 'Algunos días', 'Nunca'], (v) => setState(() => _worksFromHome = v)),
                    const SizedBox(height: 12),
                    _dropdown('Cómo resuelves conflictos', _conflictStyle, const ['Hablarlo directamente', 'Evito el conflicto', 'Prefiero mediación', 'Otra forma'], (v) => setState(() => _conflictStyle = v)),
                    const SizedBox(height: 12),
                    _dropdown('Alcohol', _alcoholFrequency, const ['Nunca', 'Ocasionalmente', 'Con frecuencia'], (v) => setState(() => _alcoholFrequency = v)),
                    const SizedBox(height: 12),
                    _dropdown('Fiestas', _partyFrequency, const ['Nunca', 'Pocas veces', 'A menudo'], (v) => setState(() => _partyFrequency = v)),
                  ],
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Visitas',
                  subtitle: 'Cómo te gustaría gestionar visitas y personas que se quedan a dormir.',
                  icon: Icons.group_outlined,
                  children: [
                    _yesNo('¿Recibes visitas?', _receivesVisitors, (v) => setState(() => _receivesVisitors = v)),
                    if (_receivesVisitors) ...[
                      const SizedBox(height: 10),
                      _yesNo('¿Suelen quedarse a dormir?', _visitorsSleepOver, (v) => setState(() => _visitorsSleepOver = v)),
                      if (_visitorsSleepOver) ...[
                        const SizedBox(height: 12),
                        _numberSlider('Noches al mes', _sleepoverNightsPerMonth.toDouble(), 0, 15, (v) => setState(() => _sleepoverNightsPerMonth = v.round())),
                      ],
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Experiencia compartiendo piso',
                  subtitle: 'Tu experiencia previa también ayuda a entender qué convivencia buscas.',
                  icon: Icons.people_outline_rounded,
                  children: [
                    _yesNo('¿Has compartido piso antes?', _sharedBefore, (v) => setState(() => _sharedBefore = v)),
                    const SizedBox(height: 10),
                    _yesNo('¿Puedes aportar referencia?', _canProvideReference, (v) => setState(() => _canProvideReference = v)),
                    const SizedBox(height: 12),
                    _textField(_previousHousingReason, 'Motivo de salida de tu vivienda anterior', Icons.edit_note_outlined, optional: true, maxLines: 3),
                  ],
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Aficiones y personalidad',
                  subtitle: 'Nos ayuda a encontrar entornos con más puntos en común.',
                  icon: Icons.auto_awesome_outlined,
                  children: [
                    _multiChoice('Aficiones', const ['Deporte', 'Cine', 'Series', 'Música', 'Viajes', 'Videojuegos', 'Cocina', 'Lectura', 'Tecnología', 'Naturaleza', 'Fotografía', 'Arte'], _hobbies, max: 4),
                    const SizedBox(height: 14),
                    _dropdown('Tiempo libre', _freeTimeStyle, const ['Planes tranquilos', 'Salir y socializar', 'Deporte y aire libre', 'Cultura y ocio', 'Me adapto'], (v) => setState(() => _freeTimeStyle = v)),
                    const SizedBox(height: 14),
                    _multiChoice('Rasgos de personalidad', const ['Sociable', 'Tranquilo', 'Responsable', 'Ordenado', 'Creativo', 'Deportista', 'Nocturno', 'Madrugador', 'Espontáneo', 'Independiente'], _personalityTraits, max: 3),
                  ],
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Compañero ideal',
                  subtitle: 'Qué esperas de las personas con las que vas a convivir.',
                  icon: Icons.favorite_border_rounded,
                  children: [
                    _dropdown('Vida social en casa', _preferredSocialStyle, const ['Cada uno a lo suyo', 'Compartir algunos momentos', 'Hacer bastante vida juntos', 'Me adapto'], (v) => setState(() => _preferredSocialStyle = v)),
                    const SizedBox(height: 14),
                    _multiChoice('Valores más importantes', const ['Limpieza y orden', 'Respeto', 'Comunicación', 'Buen ambiente', 'Tranquilidad', 'Hacer planes juntos', 'Privacidad e independencia', 'Respetar horarios', 'Confianza'], _preferredRoommateValues, max: 3),
                    const SizedBox(height: 14),
                    _textField(_additionalInfo, 'Algo más que quieras contar', Icons.notes_outlined, optional: true, maxLines: 4),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: CohabiColors.border)),
          ),
          child: SizedBox(
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: CohabiColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: _saving ? null : _save,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                    : const Text('Guardar preferencias', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _intro() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF5F2FF), Color(0xFFF0FCFB)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CohabiColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tune_rounded, color: CohabiColors.purple, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estas preferencias deciden qué pisos ves primero', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900, fontSize: 17)),
                SizedBox(height: 5),
                Text('Puedes cambiar aquí tu búsqueda y todas las respuestas de Cohabi Selección sin repetir el cuestionario completo.', style: TextStyle(color: CohabiColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required String subtitle, required IconData icon, required List<Widget> children}) {
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
          Row(children: [
            Container(width: 42, height: 42, decoration: const BoxDecoration(color: CohabiColors.purpleSoft, shape: BoxShape.circle), child: Icon(icon, color: CohabiColors.purple, size: 22)),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w900, fontSize: 17)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 12.5, height: 1.35)),
            ])),
          ]),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, IconData icon, {bool optional = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: optional ? '$label (opcional)' : label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFFBFCFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: CohabiColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: CohabiColors.border)),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> options, ValueChanged<String> onChanged, {Map<String, String>? labels}) {
    final values = _optionsWithCurrent(options, value);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFBFCFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: CohabiColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: CohabiColors.border)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: values.map((v) => DropdownMenuItem(value: v, child: Text(labels?[v] ?? v, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  Widget _dateTile() {
    return InkWell(
      onTap: _pickEntryDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(color: const Color(0xFFFBFCFF), borderRadius: BorderRadius.circular(14), border: Border.all(color: CohabiColors.border)),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, color: CohabiColors.purple),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Fecha de entrada', style: TextStyle(color: CohabiColors.textSecondary, fontSize: 11.5)),
            const SizedBox(height: 3),
            Text(_entryDate == null ? 'Seleccionar fecha' : _displayDate(_entryDate!), style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: CohabiColors.textMuted),
        ]),
      ),
    );
  }

  Widget _budgetSlider() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(color: const Color(0xFFFBFCFF), borderRadius: BorderRadius.circular(14), border: Border.all(color: CohabiColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Presupuesto máximo mensual', style: TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800))),
          Text('${_budget.round()} €', style: const TextStyle(color: CohabiColors.turquoise, fontWeight: FontWeight.w900, fontSize: 16)),
        ]),
        Slider(value: _budget, min: 200, max: 2000, divisions: 36, activeColor: CohabiColors.turquoise, onChanged: (v) => setState(() => _budget = v)),
      ]),
    );
  }

  Widget _numberSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(color: const Color(0xFFFBFCFF), borderRadius: BorderRadius.circular(14), border: Border.all(color: CohabiColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(label, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800))), Text('${value.round()}', style: const TextStyle(color: CohabiColors.purple, fontWeight: FontWeight.w900))]),
        Slider(value: value, min: min, max: max, divisions: (max - min).round(), activeColor: CohabiColors.purple, onChanged: onChanged),
      ]),
    );
  }

  Widget _yesNo(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(color: const Color(0xFFFBFCFF), borderRadius: BorderRadius.circular(14), border: Border.all(color: CohabiColors.border)),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w700))),
        SegmentedButton<bool>(segments: const [ButtonSegment(value: true, label: Text('Sí')), ButtonSegment(value: false, label: Text('No'))], selected: {value}, onSelectionChanged: (set) => onChanged(set.first), showSelectedIcon: false),
      ]),
    );
  }

  Widget _multiChoice(String label, List<String> options, List<String> selected, {int? max}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: CohabiColors.navy, fontWeight: FontWeight.w800)),
      if (max != null) Padding(padding: const EdgeInsets.only(top: 3), child: Text('Selecciona hasta $max.', style: const TextStyle(color: CohabiColors.textSecondary, fontSize: 11.5))),
      const SizedBox(height: 9),
      Wrap(spacing: 8, runSpacing: 8, children: options.map((option) {
        final active = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: active,
          onSelected: (_) => _toggleList(selected, option, max: max),
          selectedColor: CohabiColors.turquoiseSoft,
          checkmarkColor: CohabiColors.turquoise,
          side: BorderSide(color: active ? CohabiColors.turquoise : CohabiColors.border),
          labelStyle: TextStyle(color: active ? CohabiColors.turquoise : CohabiColors.navy, fontWeight: FontWeight.w700),
        );
      }).toList()),
    ]);
  }
}
