import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';
import 'tenant_home_screen.dart';

class EnableTenantProfileScreen
    extends StatefulWidget {
  const EnableTenantProfileScreen({
    super.key,
  });

  @override
  State<EnableTenantProfileScreen>
      createState() =>
          _EnableTenantProfileScreenState();
}

class _EnableTenantProfileScreenState
    extends State<EnableTenantProfileScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _birthDateController =
      TextEditingController();

  final _cityController =
      TextEditingController();

  final _searchZoneController =
      TextEditingController();

  String _gender =
      'Prefiero no decirlo';

  String _nationality = 'España';

  String _nationalityCode = 'ES';

  String _language = 'Español';

  String _accommodationType =
      'Habitación';

  DateTime? _entryDate;

  String _stayDuration =
      '6 a 12 meses';

  double _maxBudget = 450;

  String _roomSize = 'Indiferente';

  String _smoker = 'No';

  String _hasPet = 'No';

  String _occupation = 'Ambos';

  String _monthlyIncome =
      'Selecciona una opción';

  String _hasGuarantor = 'Sí';

  String _shareRoom = 'No';

  String _desiredEnvironment =
      'Tranquilo';

  bool _isLoading = false;

  @override
  void dispose() {
    _birthDateController.dispose();
    _cityController.dispose();
    _searchZoneController.dispose();

    super.dispose();
  }

  // ============================================================
  // FECHA NACIMIENTO
  // ============================================================

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();

    final date =
        await showDatePicker(
      context: context,
      initialDate:
          DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate:
          DateTime(now.year - 18),
    );

    if (date == null) return;

    setState(() {
      _birthDateController.text =
          _formatDate(date);
    });
  }

  // ============================================================
  // FECHA ENTRADA
  // ============================================================

  Future<void> _selectEntryDate() async {
    final now = DateTime.now();

    final date =
        await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate:
          DateTime(
        now.year + 3,
      ),
    );

    if (date == null) return;

    setState(() {
      _entryDate = date;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // ACTIVAR MODO TENANT
  // ============================================================

  Future<void> _enableTenantMode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_birthDateController.text
        .trim()
        .isEmpty) {
      _showError(
        'Selecciona tu fecha de nacimiento.',
      );

      return;
    }

    if (_entryDate == null) {
      _showError(
        'Selecciona una fecha de entrada.',
      );

      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase =
          Supabase.instance.client;

      if (supabase.auth.currentUser ==
          null) {
        throw Exception(
          'No hay una sesión iniciada.',
        );
      }

      await supabase.rpc(
        'enable_tenant_profile',
        params: {
          'profile_data': {
            'birth_date':
                _birthDateController
                    .text
                    .trim(),

            'gender':
                _gender,

            'nationality':
                _nationality,

            'nationality_code':
                _nationalityCode,

            'language':
                _language,

            'search_city':
                _cityController.text
                    .trim(),

            'accommodation_type':
                _accommodationType,

            'entry_date':
                _formatDate(
              _entryDate!,
            ),

            'stay_duration':
                _stayDuration,

            'max_monthly_budget':
                _maxBudget,

            'search_zone':
                _searchZoneController
                    .text
                    .trim(),

            'room_size':
                _roomSize,

            'smoker':
                _smoker,

            'has_pet':
                _hasPet,

            'occupation':
                _occupation,

            'monthly_income':
                _monthlyIncome,

            'has_guarantor':
                _hasGuarantor,

            'share_room':
                _shareRoom,

            'desired_environment':
                _desiredEnvironment,
          },
        },
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const TenantHomeScreen(),
        ),
        (_) => false,
      );
    } on PostgrestException catch (error) {
      if (!mounted) return;

      _showError(
        error.message,
      );
    } catch (error) {
      if (!mounted) return;

      _showError(
        'No se pudo activar el modo inquilino: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            Colors.redAccent,
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CohabiColors.background,

      appBar: AppBar(
        backgroundColor:
            CohabiColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: CohabiColors.navy,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            22,
            10,
            22,
            35,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration:
                        const BoxDecoration(
                      color:
                          CohabiColors.purpleSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons
                          .person_search_outlined,
                      color:
                          CohabiColors.purple,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Activa el modo inquilino',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        CohabiColors.navy,
                    fontSize: 27,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Cuéntanos qué estás buscando para preparar tu perfil y encontrar opciones que encajen contigo.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: CohabiColors
                        .textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 30),

                // ==============================================
                // NACIMIENTO
                // ==============================================

                _label(
                  'Fecha de nacimiento',
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                      _birthDateController,
                  readOnly: true,
                  onTap: _selectBirthDate,
                  decoration:
                      _inputDecoration(
                    'Selecciona una fecha',
                    Icons
                        .calendar_today_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // ==============================================
                // GÉNERO
                // ==============================================

                _label('Género'),

                const SizedBox(height: 8),

                _dropdown(
                  value: _gender,
                  values: const [
                    'Hombre',
                    'Mujer',
                    'No binario',
                    'Prefiero no decirlo',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                // ==============================================
                // CIUDAD
                // ==============================================

                _label(
                  'Ciudad donde buscas',
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                      _cityController,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Campo obligatorio';
                    }

                    return null;
                  },
                  decoration:
                      _inputDecoration(
                    'Ej. Zaragoza',
                    Icons
                        .location_on_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // ==============================================
                // TIPO ALOJAMIENTO
                // ==============================================

                _label(
                  '¿Qué buscas?',
                ),

                const SizedBox(height: 8),

                _dropdown(
                  value:
                      _accommodationType,
                  values: const [
                    'Habitación',
                    'Piso completo',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _accommodationType =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                // ==============================================
                // FECHA ENTRADA
                // ==============================================

                _label(
                  'Fecha de entrada',
                ),

                const SizedBox(height: 8),

                InkWell(
                  onTap: _selectEntryDate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 17,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                      border: Border.all(
                        color:
                            CohabiColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .calendar_today_outlined,
                          color: CohabiColors
                              .textMuted,
                        ),

                        const SizedBox(width: 12),

                        Text(
                          _entryDate == null
                              ? 'Selecciona una fecha'
                              : _formatDate(
                                  _entryDate!,
                                ),
                          style: TextStyle(
                            color: _entryDate ==
                                    null
                                ? CohabiColors
                                    .textMuted
                                : CohabiColors
                                    .navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==============================================
                // DURACIÓN
                // ==============================================

                _label(
                  'Duración de la estancia',
                ),

                const SizedBox(height: 8),

                _dropdown(
                  value: _stayDuration,
                  values: const [
                    'Menos de 3 meses',
                    '3 a 6 meses',
                    '6 a 12 meses',
                    'Más de 12 meses',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _stayDuration =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 22),

                // ==============================================
                // PRESUPUESTO
                // ==============================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    _label(
                      'Presupuesto máximo',
                    ),

                    Text(
                      '${_maxBudget.round()} €/mes',
                      style:
                          const TextStyle(
                        color: CohabiColors
                            .turquoise,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                Slider(
                  value: _maxBudget,
                  min: 200,
                  max: 2000,
                  divisions: 36,
                  activeColor:
                      CohabiColors.turquoise,
                  onChanged: (value) {
                    setState(() {
                      _maxBudget =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                // ==============================================
                // ZONA
                // ==============================================

                _label(
                  'Zona de búsqueda',
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                      _searchZoneController,
                  decoration:
                      _inputDecoration(
                    'Centro, Universidad...',
                    Icons.map_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // ==============================================
                // OCUPACIÓN
                // ==============================================

                _label('Ocupación'),

                const SizedBox(height: 8),

                _dropdown(
                  value: _occupation,
                  values: const [
                    'Estudiante',
                    'Trabajador',
                    'Ambos',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _occupation =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                // ==============================================
                // AMBIENTE
                // ==============================================

                _label(
                  'Ambiente deseado',
                ),

                const SizedBox(height: 8),

                _dropdown(
                  value:
                      _desiredEnvironment,
                  values: const [
                    'Tranquilo',
                    'Social',
                    'Indiferente',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _desiredEnvironment =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 30),

                _PrimaryTenantButton(
                  text:
                      'Activar modo inquilino',
                  isLoading:
                      _isLoading,
                  onTap:
                      _enableTenantMode,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Tu perfil de propietario y tus propiedades seguirán guardados. Podrás volver al modo propietario cuando quieras.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: CohabiColors
                        .textSecondary,
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

  Text _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: CohabiColors.navy,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: CohabiColors.textMuted,
      ),
      filled: true,
      fillColor: Colors.white,
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),
        borderSide:
            const BorderSide(
          color: CohabiColors.border,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),
        borderSide:
            const BorderSide(
          color: CohabiColors.purple,
          width: 1.5,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),
        borderSide:
            const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> values,
    required ValueChanged<String>
        onChanged,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: CohabiColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: values
              .map(
                (item) =>
                    DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}


// ============================================================
// BOTÓN
// ============================================================

class _PrimaryTenantButton
    extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onTap;

  const _PrimaryTenantButton({
    required this.text,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient:
            CohabiColors.primaryGradient,
        borderRadius:
            BorderRadius.circular(17),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              isLoading ? null : onTap,
          borderRadius:
              BorderRadius.circular(17),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}