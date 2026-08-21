import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'owner_account_created_screen.dart';

import '../core/theme/app_colors.dart';

class OwnerRegisterScreen extends StatefulWidget {
  const OwnerRegisterScreen({super.key});

  @override
  State<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _companyController = TextEditingController();
  final _documentController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();

  String _ownerType = 'Particular';
  String _language = 'Español';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _privacyAccepted = true;
  bool _termsAccepted = true;
  bool _serviceCommunicationAccepted = true;
  bool _dataSharingAccepted = true;
  bool _marketingAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyController.dispose();
    _documentController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // PASO 1 — Datos personales
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
        _showError('La contraseña debe tener al menos 8 caracteres.');
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('Las contraseñas no coinciden.');
        return;
      }
    }

    // PASO 2 — Información del propietario
    if (_currentStep == 1) {
      if (_documentController.text.trim().isEmpty ||
          _cityController.text.trim().isEmpty ||
          _provinceController.text.trim().isEmpty) {
        _showError('Completa los campos obligatorios.');
        return;
      }

      if ((_ownerType == 'Empresa' ||
          _ownerType == 'Agencia inmobiliaria') &&
          _companyController.text.trim().isEmpty) {
        _showError('Introduce el nombre de la empresa.');
        return;
      }
    }

    // PASO 3 — Verificación opcional
    if (_currentStep == 2) {
      setState(() {
        _currentStep++;
      });
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
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
  Future<void> _createAccount() async {
    if (!_privacyAccepted ||
        !_termsAccepted ||
        !_serviceCommunicationAccepted) {
      _showError(
        'Debes aceptar la Política de Privacidad, los Términos y las comunicaciones del servicio.',
      );
      return;
    }

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
          'role': 'owner',
          'city': _cityController.text.trim(),
          'province': _provinceController.text.trim(),
          'language': _language,
          'owner_type': _ownerType,
          'company_name': _companyController.text.trim(),
          'document_number': _documentController.text.trim(),
        },
      );

      final user = response.user;

      if (user == null) {
        _showError('No se ha podido crear la cuenta.');
        return;
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const OwnerAccountCreatedScreen(),
        ),
            (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (error) {
      if (!mounted) return;
      _showError(
        'Ha ocurrido un error al crear la cuenta: $error',
      );
    }
  }
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
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
                      TextSpan(text: ', gestiona con '),
                      TextSpan(
                        text: 'facilidad.',
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
        'Paso ${_currentStep + 1} de 4',
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
        return _buildOwnerInfoStep();
      case 2:
        return _buildVerificationStep();
      case 3:
        return _buildTermsStep();
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
                _obscureConfirmPassword = !_obscureConfirmPassword;
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

  Widget _buildOwnerInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Información del propietario',
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
            'Háblanos un poco más sobre ti.',
            style: TextStyle(
              color: CohabiColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          '¿Cómo utilizarás Cohabi?',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        _buildOwnerTypeOption(
          value: 'Particular',
          icon: Icons.person_outline_rounded,
          color: CohabiColors.turquoise,
        ),
        const SizedBox(height: 10),

        _buildOwnerTypeOption(
          value: 'Empresa',
          icon: Icons.apartment_rounded,
          color: CohabiColors.purple,
        ),
        const SizedBox(height: 10),

        _buildOwnerTypeOption(
          value: 'Agencia inmobiliaria',
          icon: Icons.work_outline_rounded,
          color: CohabiColors.purple,
        ),

        const SizedBox(height: 18),

        const Text(
          'Nombre de la empresa (opcional)',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),

        _buildField(
          controller: _companyController,
          hint: 'Nombre de la empresa',
        ),

        const SizedBox(height: 16),

        const Text(
          'DNI / NIE / NIF',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),

        _buildField(
          controller: _documentController,
          hint: 'Introduce tu número',
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ciudad',
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
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Provincia',
                    style: TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _provinceController,
                    hint: 'Ej. Madrid',
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: CohabiColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: CohabiColors.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _language,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'Español',
                  child: Text('🌐  Español'),
                ),
                DropdownMenuItem(
                  value: 'English',
                  child: Text('🌐  English'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _language = value;
                  });
                }
              },
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

  Widget _buildVerificationStep() {
    return Column(
      children: [
        const Text(
          'Verificación de identidad',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Opcional, pero recomendado para generar\nmás confianza.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CohabiColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CohabiColors.turquoiseSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: CohabiColors.turquoise,
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verifica tu identidad para aumentar la seguridad y confianza de tu perfil. Puedes hacerlo ahora o más tarde.',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _buildUploadCard(
          title: 'Subir documento de identidad',
          subtitle: 'DNI, NIE o Pasaporte',
          onTap: () {
            debugPrint('Subir documento');
          },
        ),

        const SizedBox(height: 12),

        _buildUploadCard(
          title: 'Selfie para verificar identidad',
          subtitle: 'Tómate una foto para comprobar que eres tú.',
          onTap: () {
            debugPrint('Subir selfie');
          },
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CohabiColors.purpleSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: CohabiColors.purple,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Este paso es opcional. Podrás completarlo más adelante desde tu perfil.',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        TextButton(
          onPressed: _nextStep,
          child: const Text(
            'Verificar más tarde',
            style: TextStyle(
              color: CohabiColors.purple,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 10),

        _buildPrimaryButton(
          text: 'Continuar',
          onTap: _nextStep,
        ),
      ],
    );
  }

  Widget _buildTermsStep() {
    return Column(
      children: [
        const Text(
          'Términos y permisos',
          style: TextStyle(
            color: CohabiColors.navy,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Últimos pasos para crear tu cuenta.',
          style: TextStyle(
            color: CohabiColors.textSecondary,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 22),

        _buildCheckboxCard(
          value: _privacyAccepted,
          text: 'He leído y acepto la Política de Privacidad.',
          onChanged: (value) {
            setState(() {
              _privacyAccepted = value ?? false;
            });
          },
        ),

        const SizedBox(height: 10),

        _buildCheckboxCard(
          value: _termsAccepted,
          text: 'Acepto los Términos y Condiciones de uso.',
          onChanged: (value) {
            setState(() {
              _termsAccepted = value ?? false;
            });
          },
        ),

        const SizedBox(height: 10),

        _buildCheckboxCard(
          value: _serviceCommunicationAccepted,
          text:
          'Acepto recibir comunicaciones relacionadas con mi cuenta, avisos importantes y notificaciones del servicio.',
          onChanged: (value) {
            setState(() {
              _serviceCommunicationAccepted = value ?? false;
            });
          },
        ),

        const SizedBox(height: 10),

        _buildCheckboxCard(
          value: _dataSharingAccepted,
          text:
          'Acepto que Cohabi pueda compartir determinados datos de mi perfil con empresas colaboradoras cuando sea necesario para prestarme servicios relacionados con el alquiler. (Opcional)',
          onChanged: (value) {
            setState(() {
              _dataSharingAccepted = value ?? false;
            });
          },
        ),

        const SizedBox(height: 10),

        _buildCheckboxCard(
          value: _marketingAccepted,
          text:
          'Deseo recibir ofertas, promociones y recomendaciones personalizadas de Cohabi y de sus empresas colaboradoras. (Opcional)',
          onChanged: (value) {
            setState(() {
              _marketingAccepted = value ?? false;
            });
          },
        ),

        const SizedBox(height: 22),

        _buildPrimaryButton(
          text: 'Crear cuenta',
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
        hintStyle: const TextStyle(
          color: CohabiColors.textMuted,
          fontSize: 14,
        ),
        prefixIcon: icon == null
            ? null
            : Icon(
          icon,
          color: CohabiColors.textMuted,
          size: 21,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
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
    );
  }

  Widget _buildOwnerTypeOption({
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final selected = _ownerType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _ownerType = value;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? CohabiColors.turquoise : CohabiColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              const CircleAvatar(
                radius: 10,
                backgroundColor: CohabiColors.turquoise,
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CohabiColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: CohabiColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: CohabiColors.purpleSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: CohabiColors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxCard({
    required bool value,
    required String text,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CohabiColors.border,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: CohabiColors.turquoise,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          text,
          style: const TextStyle(
            color: CohabiColors.navy,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ],
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
        4,
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