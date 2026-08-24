import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../selection/screens/tenant_selection_screen.dart';
import '../services/tenant_profile_service.dart';

class TenantProfileEditScreen extends StatefulWidget {
  const TenantProfileEditScreen({super.key});

  @override
  State<TenantProfileEditScreen> createState() =>
      _TenantProfileEditScreenState();
}

class _TenantProfileEditScreenState extends State<TenantProfileEditScreen> {
  final _service = TenantProfileService();
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _birthDate = TextEditingController();
  final _searchCity = TextEditingController();
  final _searchZone = TextEditingController();

  String _gender = 'Prefiero no decirlo';
  String _accommodationType = 'Habitación';
  String _stayDuration = '6 a 12 meses';
  String _occupation = 'Ambos';
  String _monthlyIncome = 'Selecciona una opción';
  String _desiredEnvironment = 'Tranquilo';
  String _smoker = 'No';
  String _hasPet = 'No';
  String _hasGuarantor = 'Sí';
  DateTime? _entryDate;
  double _maxBudget = 450;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _birthDate.dispose();
    _searchCity.dispose();
    _searchZone.dispose();
    super.dispose();
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString();

    final iso = DateTime.tryParse(text);
    if (iso != null) return iso;

    final parts = text.split('/');
    if (parts.length == 3) {
      return DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
    }

    return null;
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _date(DateTime value) =>
      '${_two(value.day)}/${_two(value.month)}/${value.year}';

  String _isoDate(DateTime value) =>
      '${value.year}-${_two(value.month)}-${_two(value.day)}';

  String _safeOption(
    dynamic value,
    List<String> options,
    String fallback,
  ) {
    final text = value?.toString() ?? '';
    return options.contains(text) ? text : fallback;
  }

  String _yesNoValue(dynamic value, String fallback) {
    if (value == true) return 'Sí';
    if (value == false) return 'No';
    final text = value?.toString().trim().toLowerCase() ?? '';
    if (const ['sí', 'si', 'yes', 'true'].contains(text)) return 'Sí';
    if (const ['no', 'false'].contains(text)) return 'No';
    return fallback;
  }

  Future<void> _load() async {
    try {
      final data = await _service.load();
      final p = Map<String, dynamic>.from(data['profile'] as Map);
      final t = Map<String, dynamic>.from(data['tenant'] as Map);

      _firstName.text = p['first_name']?.toString() ?? '';
      _lastName.text = p['last_name']?.toString() ?? '';
      _phone.text = p['phone']?.toString() ?? '';
      final birth = _parseDate(t['birth_date']);
      _birthDate.text = birth == null ? '' : _date(birth);
      _searchCity.text = t['search_city']?.toString() ?? '';
      _searchZone.text = t['search_zone']?.toString() ?? '';

      const genders = [
        'Hombre',
        'Mujer',
        'No binario',
        'Prefiero no decirlo',
      ];
      const accommodation = ['Habitación', 'Piso completo'];
      const stays = [
        'Menos de 3 meses',
        '3 a 6 meses',
        '6 a 12 meses',
        'Más de 12 meses',
      ];
      const occupations = ['Estudiante', 'Trabajador', 'Ambos'];
      const environments = ['Tranquilo', 'Social', 'Indiferente'];

      _gender = _safeOption(
        t['gender'],
        genders,
        'Prefiero no decirlo',
      );
      _accommodationType = _safeOption(
        t['accommodation_type'],
        accommodation,
        'Habitación',
      );
      _stayDuration = _safeOption(
        t['stay_duration'],
        stays,
        '6 a 12 meses',
      );
      _occupation = _safeOption(
        t['occupation'],
        occupations,
        'Ambos',
      );
      const incomes = [
        'Selecciona una opción',
        'Menos de 1.000 €',
        '1.000 € - 1.500 €',
        '1.500 € - 2.000 €',
        '2.000 € - 2.500 €',
        '2.500 € - 3.000 €',
        'Más de 3.000 €',
      ];
      _monthlyIncome = _safeOption(
        t['monthly_income'],
        incomes,
        'Selecciona una opción',
      );
      _desiredEnvironment = _safeOption(
        t['desired_environment'],
        environments,
        'Tranquilo',
      );

      _smoker = _yesNoValue(t['smoker'], 'No');
      _hasPet = _yesNoValue(t['has_pet'], 'No');
      _hasGuarantor = _yesNoValue(t['has_guarantor'], 'Sí');

      _entryDate = _parseDate(t['entry_date']);

      final budget = t['max_monthly_budget'];
      if (budget is num) {
        _maxBudget = budget.toDouble().clamp(200.0, 2000.0).toDouble();
      }

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _error('No se pudo cargar el perfil: $e');
    }
  }

  void _error(String message) {
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

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final current =
        _parseDate(_birthDate.text) ?? DateTime(now.year - 25, 1, 1);

    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 18, now.month, now.day),
    );

    if (selected != null) {
      setState(() => _birthDate.text = _date(selected));
    }
  }

  Future<void> _selectEntryDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _entryDate != null && _entryDate!.isAfter(now)
          ? _entryDate!
          : now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );

    if (selected != null) {
      setState(() => _entryDate = selected);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _saving) return;

    if (_birthDate.text.trim().isEmpty) {
      _error('Selecciona tu fecha de nacimiento.');
      return;
    }

    if (_entryDate == null) {
      _error('Selecciona tu fecha de entrada.');
      return;
    }

    setState(() => _saving = true);

    try {
      await _service.update(
        profile: {
          'first_name': _firstName.text.trim(),
          'last_name': _lastName.text.trim(),
          'phone': _phone.text.trim(),
        },
        tenant: {
          'birth_date': _isoDate(_parseDate(_birthDate.text)!),
          'gender': _gender,
          'search_city': _searchCity.text.trim(),
          'search_zone': _searchZone.text.trim(),
          'accommodation_type': _accommodationType,
          'entry_date': _isoDate(_entryDate!),
          'stay_duration': _stayDuration,
          'max_monthly_budget': _maxBudget,
          'occupation': _occupation,
          'monthly_income': _monthlyIncome,
          'desired_environment': _desiredEnvironment,
          'smoker': _smoker,
          'has_pet': _hasPet,
          'has_guarantor': _hasGuarantor,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil de inquilino actualizado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) _error('No se pudo guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(
        backgroundColor: CohabiColors.background,
        elevation: 0,
        title: const Text(
          'Perfil de inquilino',
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
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                children: [
                  const CohabiSectionHeader(
                    title: 'Tus datos',
                    subtitle:
                        'Mantén actualizados tus datos personales y tus preferencias de búsqueda.',
                  ),
                  const SizedBox(height: 22),
                  CohabiTextField(
                    controller: _firstName,
                    label: 'Nombre',
                    hint: 'Nombre',
                    icon: Icons.person_outline_rounded,
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  CohabiTextField(
                    controller: _lastName,
                    label: 'Apellidos',
                    hint: 'Apellidos',
                    icon: Icons.badge_outlined,
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  CohabiTextField(
                    controller: _phone,
                    label: 'Teléfono',
                    hint: 'Teléfono',
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 14),
                  CohabiTextField(
                    controller: _birthDate,
                    label: 'Fecha de nacimiento',
                    hint: 'Selecciona una fecha',
                    icon: Icons.cake_outlined,
                    readOnly: true,
                    onTap: _selectBirthDate,
                  ),
                  const SizedBox(height: 14),
                  _dropdown(
                    label: 'Género',
                    value: _gender,
                    values: const [
                      'Hombre',
                      'Mujer',
                      'No binario',
                      'Prefiero no decirlo',
                    ],
                    onChanged: (v) => setState(() => _gender = v),
                  ),

                  const SizedBox(height: 28),
                  const CohabiSectionHeader(
                    title: 'Preferencias de búsqueda',
                    subtitle:
                        'Estos datos se utilizan para enseñarte viviendas compatibles.',
                  ),
                  const SizedBox(height: 20),

                  CohabiTextField(
                    controller: _searchCity,
                    label: 'Ciudad donde buscas',
                    hint: 'Ej. Zaragoza',
                    icon: Icons.location_on_outlined,
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  CohabiTextField(
                    controller: _searchZone,
                    label: 'Zona preferida',
                    hint: 'Centro, Universidad...',
                    icon: Icons.map_outlined,
                  ),
                  const SizedBox(height: 14),
                  _dropdown(
                    label: 'Tipo de alojamiento',
                    value: _accommodationType,
                    values: const ['Habitación', 'Piso completo'],
                    onChanged: (v) =>
                        setState(() => _accommodationType = v),
                  ),
                  const SizedBox(height: 14),
                  _entryDateCard(),
                  const SizedBox(height: 14),
                  _dropdown(
                    label: 'Duración',
                    value: _stayDuration,
                    values: const [
                      'Menos de 3 meses',
                      '3 a 6 meses',
                      '6 a 12 meses',
                      'Más de 12 meses',
                    ],
                    onChanged: (v) => setState(() => _stayDuration = v),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Presupuesto máximo',
                        style: TextStyle(
                          color: CohabiColors.navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_maxBudget.round()} €/mes',
                        style: const TextStyle(
                          color: CohabiColors.turquoise,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _maxBudget,
                    min: 200,
                    max: 2000,
                    divisions: 36,
                    activeColor: CohabiColors.turquoise,
                    onChanged: (v) => setState(() => _maxBudget = v),
                  ),
                  _dropdown(
                    label: 'Ocupación',
                    value: _occupation,
                    values: const ['Estudiante', 'Trabajador', 'Ambos'],
                    onChanged: (v) => setState(() => _occupation = v),
                  ),
                  const SizedBox(height: 14),
                  _dropdown(
                    label: 'Ingresos mensuales aproximados',
                    value: _monthlyIncome,
                    values: const [
                      'Selecciona una opción',
                      'Menos de 1.000 €',
                      '1.000 € - 1.500 €',
                      '1.500 € - 2.000 €',
                      '2.000 € - 2.500 €',
                      '2.500 € - 3.000 €',
                      'Más de 3.000 €',
                    ],
                    onChanged: (v) => setState(() => _monthlyIncome = v),
                  ),
                  const SizedBox(height: 14),
                  _dropdown(
                    label: 'Ambiente deseado',
                    value: _desiredEnvironment,
                    values: const ['Tranquilo', 'Social', 'Indiferente'],
                    onChanged: (v) =>
                        setState(() => _desiredEnvironment = v),
                  ),
                  const SizedBox(height: 14),
                  _dropdown(
                    label: '¿Fumas?',
                    value: _smoker,
                    values: const ['Sí', 'No'],
                    onChanged: (v) => setState(() => _smoker = v),
                  ),
                  const SizedBox(height: 14),
                  _dropdown(
                    label: '¿Tienes mascota?',
                    value: _hasPet,
                    values: const ['Sí', 'No'],
                    onChanged: (v) => setState(() => _hasPet = v),
                  ),
                  const SizedBox(height: 14),
                  _dropdown(
                    label: '¿Tienes avalista?',
                    value: _hasGuarantor,
                    values: const ['Sí', 'No'],
                    onChanged: (v) => setState(() => _hasGuarantor = v),
                  ),

                  const SizedBox(height: 26),
                  CohabiPrimaryButton(
                    text: 'Guardar cambios',
                    isLoading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                  const SizedBox(height: 14),

                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TenantSelectionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Editar Cohabi Selección'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CohabiColors.purple,
                      side: const BorderSide(color: CohabiColors.purple),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _entryDateCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de entrada',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        CohabiCard(
          withShadow: false,
          onTap: _selectEntryDate,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 17,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: CohabiColors.purple,
              ),
              const SizedBox(width: 12),
              Text(
                _entryDate == null
                    ? 'Selecciona una fecha'
                    : _date(_entryDate!),
                style: TextStyle(
                  color: _entryDate == null
                      ? CohabiColors.textMuted
                      : CohabiColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return CohabiDropdown<String>(
      label: label,
      value: value,
      items: values
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
