import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:country_picker/country_picker.dart';
import 'tenant_account_created_screen.dart';

import '../core/theme/app_colors.dart';

class TenantRegisterScreen extends StatefulWidget {
  const TenantRegisterScreen({super.key});

  @override
  State<TenantRegisterScreen> createState() =>
      _TenantRegisterScreenState();
}

class _TenantRegisterScreenState
    extends State<TenantRegisterScreen> {
  int _currentStep = 0;

  // PASO 1
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // PASO 2
  final _birthDateController = TextEditingController();
  final _cityController = TextEditingController();

  String _gender = 'Prefiero no decirlo';
  String? _nationality;
  String? _nationalityCode;
  String _language = 'Español';

  // PASO 3
  String _accommodationType = 'Habitación';
  String _entryDate = 'Selecciona una fecha';
  double _maxBudget = 450;

  final _searchZoneController = TextEditingController();

  String _stayDuration = '6 a 12 meses';

  // PASO 4
  String _roomSize = 'Indiferente';
  String _smoker = 'No';
  String _hasPet = 'No';
  String _occupation = 'Ambos';

  // PASO 5
  String _monthlyIncome = 'Selecciona una opción';
  String _hasGuarantor = 'Sí';
  String _shareRoom = 'No';
  String _desiredEnvironment = 'Tranquilo';

  // PASO 6
  bool _privacyAccepted = true;
  bool _termsAccepted = true;

  bool _isCreatingAccount = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    _cityController.dispose();
    _searchZoneController.dispose();

    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _nextStep() {
    // PASO 1
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty ||
          _surnameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _showError('Completa todos los campos obligatorios.');
        return;
      }

      if (!_emailController.text.contains('@')) {
        _showError('Introduce un correo electrónico válido.');
        return;
      }

      if (_passwordController.text.length < 8) {
        _showError(
          'La contraseña debe tener al menos 8 caracteres.',
        );
        return;
      }

      if (_passwordController.text !=
          _confirmPasswordController.text) {
        _showError('Las contraseñas no coinciden.');
        return;
      }
    }

    // PASO 2
    if (_currentStep == 1) {
      if (_birthDateController.text.trim().isEmpty ||
          _cityController.text.trim().isEmpty) {
        _showError(
          'Completa la fecha de nacimiento y la ciudad.',
        );
        return;
      }

      if (_nationality == null) {
        _showError('Selecciona tu nacionalidad.');
        return;
      }
    }

    // PASO 3
    if (_currentStep == 2) {
      if (_entryDate == 'Selecciona una fecha') {
        _showError('Selecciona una fecha de entrada.');
        return;
      }

      if (_searchZoneController.text.trim().isEmpty) {
        _showError(
          'Introduce la zona donde buscas alojamiento.',
        );
        return;
      }
    }

    // PASO 5
    if (_currentStep == 4) {
      if (_monthlyIncome == 'Selecciona una opción') {
        _showError(
          'Selecciona tus ingresos mensuales aproximados.',
        );
        return;
      }
    }

    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const TenantAccountCreatedScreen(),
        ),
            (route) => false,
      );
    }
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();

    final adultLimit = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );

    final initialDate = DateTime(
      now.year - 25,
      now.month,
      now.day,
    );

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: adultLimit,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
            Theme.of(context).colorScheme.copyWith(
              primary: CohabiColors.purple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;

    final day = selected.day.toString().padLeft(2, '0');
    final month = selected.month.toString().padLeft(2, '0');
    final year = selected.year.toString();

    setState(() {
      _birthDateController.text = '$day/$month/$year';
    });
  }

  Future<void> _selectEntryDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(
        const Duration(days: 730),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
            Theme.of(context).colorScheme.copyWith(
              primary: CohabiColors.purple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;

    final day = selected.day.toString().padLeft(2, '0');
    final month = selected.month.toString().padLeft(2, '0');
    final year = selected.year.toString();

    setState(() {
      _entryDate = '$day/$month/$year';
    });
  }

  void _selectCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        backgroundColor: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        inputDecoration: InputDecoration(
          hintText: 'Buscar país',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: CohabiColors.purple,
          ),
          filled: true,
          fillColor: CohabiColors.background,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: CohabiColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: CohabiColors.turquoise,
              width: 1.4,
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _nationality = country.name;
          _nationalityCode = country.countryCode;
        });
      },
    );
  }

  Future<void> _createAccount() async {
    if (!_privacyAccepted || !_termsAccepted) {
      _showError(
        'Debes aceptar la Política de Privacidad y los Términos y Condiciones.',
      );
      return;
    }

    if (_isCreatingAccount) return;

    setState(() {
      _isCreatingAccount = true;
    });

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        emailRedirectTo: 'cohabi://login-callback/',
        data: {
          'first_name': _nameController.text.trim(),
          'last_name': _surnameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': 'tenant',

          'birth_date': _birthDateController.text.trim(),
          'gender': _gender,
          'nationality': _nationality,
          'nationality_code': _nationalityCode,
          'language': _language,
          'search_city': _cityController.text.trim(),

          'accommodation_type': _accommodationType,
          'entry_date': _entryDate,
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
        },
      );

      final user = response.user;

      if (user == null) {
        _showError('No se ha podido crear la cuenta.');
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cuenta de inquilino creada correctamente.',
          ),
          backgroundColor: CohabiColors.turquoise,
        ),
      );

      Navigator.pop(context);
    } on AuthException catch (error) {
      if (!mounted) return;

      _showError(error.message);
    } catch (error) {
      if (!mounted) return;

      _showError(
        'Ha ocurrido un error al crear la cuenta: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingAccount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStepBadge(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: _buildCurrentStep(),
              ),
              const SizedBox(height: 18),
              _buildDots(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 90),
                child: Image.asset(
                  'assets/images/cohabi_logo.png',
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(text: 'Alquila con '),
                      TextSpan(
                        text: 'confianza',
                        style: TextStyle(
                          color: CohabiColors.turquoise,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ', encuentra tu hogar con ',
                      ),
                      TextSpan(
                        text: 'Cohabi.',
                        style: TextStyle(
                          color: CohabiColors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                height: 26,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF2F4F8),
                      CohabiColors.background,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          left: 8,
          top: 8,
          child: IconButton(
            onPressed: _previousStep,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: CohabiColors.navy,
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: CohabiColors.turquoiseSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Paso ${_currentStep + 1} de 6',
        style: const TextStyle(
          color: CohabiColors.turquoise,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalDataStep();
      case 1:
        return _buildPersonalInfoStep();
      case 2:
        return _buildSearchStep();
      case 3:
        return _buildPreferencesStep();
      case 4:
        return _buildAdditionalInfoStep();
      case 5:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalDataStep() {
    return Column(
      children: [
        const Text(
          'Datos personales',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Cuéntanos quién eres.',
          style: TextStyle(
            color: CohabiColors.textSecondary,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 24),

        _buildField(
          controller: _nameController,
          hint: 'Nombre',
          icon: Icons.person_outline_rounded,
        ),

        const SizedBox(height: 12),

        _buildField(
          controller: _surnameController,
          hint: 'Apellidos',
          icon: Icons.person_outline_rounded,
        ),

        const SizedBox(height: 12),

        _buildField(
          controller: _emailController,
          hint: 'Correo electrónico',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 12),

        _buildField(
          controller: _phoneController,
          hint: 'Teléfono móvil',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 12),

        _buildField(
          controller: _passwordController,
          hint: 'Contraseña',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: CohabiColors.textMuted,
            ),
          ),
        ),

        const SizedBox(height: 12),

        _buildField(
          controller: _confirmPasswordController,
          hint: 'Confirmar contraseña',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscureConfirmPassword =
                !_obscureConfirmPassword;
              });
            },
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: CohabiColors.textMuted,
            ),
          ),
        ),

        const SizedBox(height: 22),

        _buildPrimaryButton(
          text: 'Continuar',
          onTap: _nextStep,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Información personal',
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 6),

        const Center(
          child: Text(
            'Para conocerte mejor.',
            style: TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Fecha de nacimiento',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: _selectBirthDate,
          child: AbsorbPointer(
            child: _buildField(
              controller: _birthDateController,
              hint: 'DD/MM/AAAA',
              icon: Icons.calendar_today_outlined,
            ),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Debes ser mayor de edad.',
          style: TextStyle(
            color: CohabiColors.textSecondary,
            fontSize: 11.5,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Género (opcional)',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildSelectableOption(
                title: 'Hombre',
                icon: Icons.male_rounded,
                selected: _gender == 'Hombre',
                color: CohabiColors.turquoise,
                onTap: () {
                  setState(() {
                    _gender = 'Hombre';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSelectableOption(
                title: 'Mujer',
                icon: Icons.female_rounded,
                selected: _gender == 'Mujer',
                color: CohabiColors.purple,
                onTap: () {
                  setState(() {
                    _gender = 'Mujer';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSelectableOption(
                title: 'Prefiero no decirlo',
                icon: Icons.transgender_rounded,
                selected: _gender == 'Prefiero no decirlo',
                color: CohabiColors.purple,
                onTap: () {
                  setState(() {
                    _gender = 'Prefiero no decirlo';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        const Text(
          'Nacionalidad',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        InkWell(
          onTap: _selectCountry,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _nationality != null
                    ? CohabiColors.turquoise
                    : CohabiColors.border,
                width: _nationality != null ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.public_rounded,
                  color: CohabiColors.textMuted,
                  size: 21,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    _nationality ?? 'Selecciona tu nacionalidad',
                    style: TextStyle(
                      color: _nationality == null
                          ? CohabiColors.textMuted
                          : CohabiColors.navy,
                      fontSize: 14,
                    ),
                  ),
                ),

                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: CohabiColors.textMuted,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Idioma preferido',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        _buildDropdown(
          value: _language,
          items: const [
            'Español',
            'English',
          ],
          prefix: '🌐',
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _language = value;
            });
          },
        ),

        const SizedBox(height: 16),

        const Text(
          'Ciudad donde buscas alojamiento',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        _buildField(
          controller: _cityController,
          hint: 'Ej. Madrid',
          icon: Icons.location_on_outlined,
        ),

        const SizedBox(height: 22),

        _buildPrimaryButton(
          text: 'Continuar',
          onTap: _nextStep,
        ),
      ],
    );
  }

  Widget _buildSearchStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Tu búsqueda',
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 6),

        const Center(
          child: Text(
            'Cuéntanos qué estás buscando.',
            style: TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          '¿Qué tipo de alojamiento buscas?',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildLargeSelectableOption(
                title: 'Habitación',
                subtitle: 'En piso compartido',
                icon: Icons.bed_outlined,
                selected: _accommodationType == 'Habitación',
                color: CohabiColors.turquoise,
                onTap: () {
                  setState(() {
                    _accommodationType = 'Habitación';
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildLargeSelectableOption(
                title: 'Piso completo',
                subtitle: 'Apartamento en exclusivo',
                icon: Icons.weekend_outlined,
                selected: _accommodationType == 'Piso completo',
                color: CohabiColors.purple,
                onTap: () {
                  setState(() {
                    _accommodationType = 'Piso completo';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        const Text(
          '¿Cuándo te gustaría entrar?',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: _selectEntryDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: CohabiColors.border,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: CohabiColors.textMuted,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _entryDate,
                    style: TextStyle(
                      color: _entryDate == 'Selecciona una fecha'
                          ? CohabiColors.textMuted
                          : CohabiColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Presupuesto máximo mensual',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        Slider(
          min: 250,
          max: 1000,
          divisions: 15,
          value: _maxBudget,
          activeColor: CohabiColors.turquoise,
          onChanged: (value) {
            setState(() {
              _maxBudget = value.roundToDouble();
            });
          },
        ),

        Center(
          child: Text(
            '${_maxBudget.round()} € / mes',
            style: const TextStyle(
              color: CohabiColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Zona donde buscas',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        _buildField(
          controller: _searchZoneController,
          hint: 'Ej. Centro, Salamanca, Retiro...',
          icon: Icons.location_on_outlined,
        ),

        const SizedBox(height: 22),

        _buildPrimaryButton(
          text: 'Continuar',
          onTap: _nextStep,
        ),
      ],
    );
  }

  Widget _buildPreferencesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Tus preferencias',
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Tamaño mínimo de la habitación',
          style: TextStyle(
            color: CohabiColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildSmallOption(
                title: 'Indiferente',
                selected: _roomSize == 'Indiferente',
                onTap: () {
                  setState(() {
                    _roomSize = 'Indiferente';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallOption(
                title: '< de 10 m²',
                selected: _roomSize == '< de 10 m²',
                onTap: () {
                  setState(() {
                    _roomSize = '< de 10 m²';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallOption(
                title: '> de 15 m²',
                selected: _roomSize == '> de 15 m²',
                onTap: () {
                  setState(() {
                    _roomSize = '> de 15 m²';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        const Text(
          '¿Eres fumador/a?',
          style: TextStyle(
            color: CohabiColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildSmallOption(
                title: 'No',
                selected: _smoker == 'No',
                onTap: () {
                  setState(() {
                    _smoker = 'No';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallOption(
                title: 'Sí',
                selected: _smoker == 'Sí',
                onTap: () {
                  setState(() {
                    _smoker = 'Sí';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        const Text(
          '¿Tienes mascota?',
          style: TextStyle(
            color: CohabiColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildSmallOption(
                title: 'No',
                selected: _hasPet == 'No',
                onTap: () {
                  setState(() {
                    _hasPet = 'No';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallOption(
                title: 'Sí',
                selected: _hasPet == 'Sí',
                onTap: () {
                  setState(() {
                    _hasPet = 'Sí';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        const Text(
          '¿A qué te dedicas actualmente?',
          style: TextStyle(
            color: CohabiColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildSmallOption(
                title: 'Trabajo',
                selected: _occupation == 'Trabajo',
                onTap: () {
                  setState(() {
                    _occupation = 'Trabajo';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallOption(
                title: 'Estudio',
                selected: _occupation == 'Estudio',
                onTap: () {
                  setState(() {
                    _occupation = 'Estudio';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallOption(
                title: 'Ambos',
                selected: _occupation == 'Ambos',
                onTap: () {
                  setState(() {
                    _occupation = 'Ambos';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        _buildPrimaryButton(
          text: 'Continuar',
          onTap: _nextStep,
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Información adicional',
            style: TextStyle(
              color: CohabiColors.navy,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 6),

        const Center(
          child: Text(
            'Para mejorar la compatibilidad con los pisos.',
            style: TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 26),

        const Text(
          'Ingresos mensuales aproximados',
          style: TextStyle(
            color: CohabiColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        _buildDropdown(
          value: _monthlyIncome,
          items: const [
            'Selecciona una opción',
            'Menos de 1.000 €',
            '1.000 € - 1.500 €',
            '1.500 € - 2.000 €',
            '2.000 € - 2.500 €',
            '2.500 € - 3.000 €',
            'Más de 3.000 €',
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _monthlyIncome = value;
            });
          },
        ),

        const SizedBox(height: 22),

        const Text(
          '¿Cuentas con aval o garantía?',
          style: TextStyle(
            color: CohabiColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildSmallOption(
                title: 'Sí',
                selected: _hasGuarantor == 'Sí',
                onTap: () {
                  setState(() {
                    _hasGuarantor = 'Sí';
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSmallOption(
                title: 'No',
                selected: _hasGuarantor == 'No',
                onTap: () {
                  setState(() {
                    _hasGuarantor = 'No';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        const Text(
          '¿Compartirías la habitación con otra persona?',
          style: TextStyle(
            color: CohabiColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildSmallOption(
                title: 'No',
                selected: _shareRoom == 'No',
                onTap: () {
                  setState(() {
                    _shareRoom = 'No';
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSmallOption(
                title: 'Sí',
                selected: _shareRoom == 'Sí',
                onTap: () {
                  setState(() {
                    _shareRoom = 'Sí';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        const Text(
          '¿Qué ambiente buscas en el piso?',
          style: TextStyle(
            color: CohabiColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildSmallOption(
                title: 'Tranquilo',
                selected: _desiredEnvironment == 'Tranquilo',
                onTap: () {
                  setState(() {
                    _desiredEnvironment = 'Tranquilo';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallOption(
                title: 'Social',
                selected: _desiredEnvironment == 'Social',
                onTap: () {
                  setState(() {
                    _desiredEnvironment = 'Social';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSmallOption(
                title: 'Indiferente',
                selected: _desiredEnvironment == 'Indiferente',
                onTap: () {
                  setState(() {
                    _desiredEnvironment = 'Indiferente';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        _buildPrimaryButton(
          text: 'Continuar',
          onTap: _nextStep,
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      children: [
        const Text(
          'Revisión y finalización',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Revisa tu información y crea tu cuenta.',
          style: TextStyle(
            color: CohabiColors.textSecondary,
          ),
        ),

        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: CohabiColors.border,
            ),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                'Tipo de alojamiento',
                _accommodationType,
              ),
              _buildSummaryRow(
                'Entrada',
                _entryDate,
              ),
              _buildSummaryRow(
                'Estancia',
                _stayDuration,
              ),
              _buildSummaryRow(
                'Presupuesto',
                '${_maxBudget.round()} € / mes',
              ),
              _buildSummaryRow(
                'Zona',
                _searchZoneController.text.trim(),
              ),
              _buildSummaryRow(
                'Fumador/a',
                _smoker,
              ),
              _buildSummaryRow(
                'Mascotas',
                _hasPet,
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        CheckboxListTile(
          value: _privacyAccepted,
          activeColor: CohabiColors.turquoise,
          title: const Text(
            'He leído y acepto la Política de Privacidad.',
          ),
          onChanged: (value) {
            setState(() {
              _privacyAccepted = value ?? false;
            });
          },
        ),

        CheckboxListTile(
          value: _termsAccepted,
          activeColor: CohabiColors.turquoise,
          title: const Text(
            'Acepto los Términos y Condiciones de uso.',
          ),
          onChanged: (value) {
            setState(() {
              _termsAccepted = value ?? false;
            });
          },
        ),

        const SizedBox(height: 22),

        _buildPrimaryButton(
          text: _isCreatingAccount
              ? 'Creando cuenta...'
              : 'Crear cuenta',
          onTap: _createAccount,
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon == null
            ? null
            : Icon(
          icon,
          color: CohabiColors.textMuted,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: CohabiColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: CohabiColors.turquoise,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? prefix,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CohabiColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                prefix == null ? item : '$prefix  $item',
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSelectableOption({
    required String title,
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? CohabiColors.turquoise
                : CohabiColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeSelectableOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? CohabiColors.turquoise
                : CohabiColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CohabiColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? CohabiColors.turquoise
                : CohabiColors.border,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: CohabiColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: CohabiColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: CohabiColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isCreatingAccount ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
            (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentStep
                ? CohabiColors.turquoise
                : CohabiColors.border,
          ),
        ),
      ),
    );
  }
}