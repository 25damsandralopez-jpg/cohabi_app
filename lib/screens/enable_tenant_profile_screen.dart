import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/widgets.dart';
import '../features/account/services/account_service.dart';
import 'tenant_home_screen.dart';

class EnableTenantProfileScreen extends StatefulWidget {
  const EnableTenantProfileScreen({super.key});

  @override
  State<EnableTenantProfileScreen> createState() =>
      _EnableTenantProfileScreenState();
}

class _EnableTenantProfileScreenState extends State<EnableTenantProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountService = AccountService();

  final _birthDateController = TextEditingController();
  final _cityController = TextEditingController();
  final _searchZoneController = TextEditingController();

  String _gender = 'Prefiero no decirlo';
  String _nationality = 'España';
  String _nationalityCode = 'ES';
  String _language = 'Español';
  String _accommodationType = 'Habitación';
  String _stayDuration = '6 a 12 meses';
  String _roomSize = 'Indiferente';
  String _smoker = 'No';
  String _hasPet = 'No';
  String _occupation = 'Ambos';
  String _monthlyIncome = 'Selecciona una opción';
  String _hasGuarantor = 'Sí';
  String _shareRoom = 'No';
  String _desiredEnvironment = 'Tranquilo';
  DateTime? _entryDate;
  double _maxBudget = 450;
  bool _isLoading = false;

  @override
  void dispose() {
    _birthDateController.dispose();
    _cityController.dispose();
    _searchZoneController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 18),
    );
    if (date != null) {
      setState(() => _birthDateController.text = _formatDate(date));
    }
  }

  Future<void> _selectEntryDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (date != null) setState(() => _entryDate = date);
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio';
    return null;
  }

  Future<void> _enableTenantMode() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) return;

    if (_birthDateController.text.trim().isEmpty) {
      CohabiSnackbar.error(context, 'Selecciona tu fecha de nacimiento.');
      return;
    }
    if (_entryDate == null) {
      CohabiSnackbar.error(context, 'Selecciona una fecha de entrada.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (Supabase.instance.client.auth.currentUser == null) {
        throw StateError('No hay una sesión iniciada.');
      }

      await _accountService.enableTenantProfile({
        'birth_date': _birthDateController.text.trim(),
        'gender': _gender,
        'nationality': _nationality,
        'nationality_code': _nationalityCode,
        'language': _language,
        'search_city': _cityController.text.trim(),
        'accommodation_type': _accommodationType,
        'entry_date': _formatDate(_entryDate!),
        'stay_duration': _stayDuration,
        'max_monthly_budget': _maxBudget,
        'search_zone': _searchZoneController.text.trim(),
        'room_size': _roomSize,
        'smoker': _smoker,
        'has_pet': _hasPet,
        'occupation': _occupation,
        'monthly_income': _monthlyIncome,
        'has_guarantor': _hasGuarantor,
        'share_room': _shareRoom,
        'desired_environment': _desiredEnvironment,
      });

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TenantHomeScreen()),
        (_) => false,
      );
    } on PostgrestException catch (error) {
      if (mounted) CohabiSnackbar.error(context, error.message);
    } catch (error) {
      if (mounted) {
        CohabiSnackbar.error(context, 'No se pudo activar el modo inquilino: $error');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      appBar: AppBar(
        backgroundColor: CohabiColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: CohabiColors.navy),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 35),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      color: CohabiColors.purpleSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_search_outlined,
                      color: CohabiColors.purple,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const CohabiSectionHeader(
                  title: 'Activa el modo inquilino',
                  subtitle:
                      'Cuéntanos qué estás buscando para preparar tu perfil y encontrar opciones que encajen contigo.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                CohabiTextField(
                  controller: _birthDateController,
                  label: 'Fecha de nacimiento',
                  hint: 'Selecciona una fecha',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _selectBirthDate,
                ),
                const SizedBox(height: 18),
                _dropdown(
                  label: 'Género',
                  value: _gender,
                  values: const ['Hombre', 'Mujer', 'No binario', 'Prefiero no decirlo'],
                  onChanged: (value) => setState(() => _gender = value),
                ),
                const SizedBox(height: 18),
                CohabiTextField(
                  controller: _cityController,
                  label: 'Ciudad donde buscas',
                  hint: 'Ej. Zaragoza',
                  icon: Icons.location_on_outlined,
                  validator: _required,
                ),
                const SizedBox(height: 18),
                _dropdown(
                  label: '¿Qué buscas?',
                  value: _accommodationType,
                  values: const ['Habitación', 'Piso completo'],
                  onChanged: (value) => setState(() => _accommodationType = value),
                ),
                const SizedBox(height: 18),
                _dateSelector(),
                const SizedBox(height: 18),
                _dropdown(
                  label: 'Duración de la estancia',
                  value: _stayDuration,
                  values: const [
                    'Menos de 3 meses',
                    '3 a 6 meses',
                    '6 a 12 meses',
                    'Más de 12 meses',
                  ],
                  onChanged: (value) => setState(() => _stayDuration = value),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Presupuesto máximo',
                      style: TextStyle(
                        color: CohabiColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_maxBudget.round()} €/mes',
                      style: const TextStyle(
                        color: CohabiColors.turquoise,
                        fontWeight: FontWeight.w800,
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
                  onChanged: (value) => setState(() => _maxBudget = value),
                ),
                const SizedBox(height: 12),
                CohabiTextField(
                  controller: _searchZoneController,
                  label: 'Zona de búsqueda',
                  hint: 'Centro, Universidad...',
                  icon: Icons.map_outlined,
                ),
                const SizedBox(height: 18),
                _dropdown(
                  label: 'Ocupación',
                  value: _occupation,
                  values: const ['Estudiante', 'Trabajador', 'Ambos'],
                  onChanged: (value) => setState(() => _occupation = value),
                ),
                const SizedBox(height: 18),
                _dropdown(
                  label: 'Ambiente deseado',
                  value: _desiredEnvironment,
                  values: const ['Tranquilo', 'Social', 'Indiferente'],
                  onChanged: (value) => setState(() => _desiredEnvironment = value),
                ),
                const SizedBox(height: 30),
                CohabiPrimaryButton(
                  text: 'Activar modo inquilino',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _enableTenantMode,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tu perfil de propietario y tus propiedades seguirán guardados. Podrás volver al modo propietario cuando quieras.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }

  Widget _dateSelector() {
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
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
          onTap: _selectEntryDate,
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: CohabiColors.textMuted),
              const SizedBox(width: 12),
              Text(
                _entryDate == null ? 'Selecciona una fecha' : _formatDate(_entryDate!),
                style: TextStyle(
                  color: _entryDate == null
                      ? CohabiColors.textMuted
                      : CohabiColors.navy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
