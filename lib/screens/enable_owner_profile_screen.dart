import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/widgets.dart';
import '../features/account/services/account_service.dart';
import 'properties_dashboard_screen.dart';

class EnableOwnerProfileScreen extends StatefulWidget {
  const EnableOwnerProfileScreen({super.key});

  @override
  State<EnableOwnerProfileScreen> createState() =>
      _EnableOwnerProfileScreenState();
}

class _EnableOwnerProfileScreenState extends State<EnableOwnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountService = AccountService();

  final _companyController = TextEditingController();
  final _documentController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();

  String _ownerType = 'Particular';
  String _language = 'Español';
  bool _isLoading = false;

  @override
  void dispose() {
    _companyController.dispose();
    _documentController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  Future<void> _enableOwnerMode() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) return;

    if ((_ownerType == 'Empresa' || _ownerType == 'Agencia inmobiliaria') &&
        _companyController.text.trim().isEmpty) {
      CohabiSnackbar.error(context, 'Introduce el nombre de la empresa.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (Supabase.instance.client.auth.currentUser == null) {
        throw StateError('No hay una sesión iniciada.');
      }

      await _accountService.enableOwnerProfile({
        'owner_type': _ownerType,
        'company_name': _companyController.text.trim(),
        'document_number': _documentController.text.trim(),
        'city': _cityController.text.trim(),
        'province': _provinceController.text.trim(),
        'language': _language,
      });

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PropertiesDashboardScreen()),
        (_) => false,
      );
    } on PostgrestException catch (error) {
      if (mounted) CohabiSnackbar.error(context, error.message);
    } catch (error) {
      if (mounted) {
        CohabiSnackbar.error(context, 'No se pudo activar el modo propietario: $error');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                      color: CohabiColors.turquoiseSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.home_work_outlined,
                      color: CohabiColors.turquoise,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const CohabiSectionHeader(
                  title: 'Activa el modo propietario',
                  subtitle:
                      'Completa los datos necesarios para publicar y gestionar propiedades en Cohabi.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const Text(
                  '¿Cómo utilizarás Cohabi?',
                  style: TextStyle(
                    color: CohabiColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...['Particular', 'Empresa', 'Agencia inmobiliaria'].map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OwnerTypeCard(
                      text: type,
                      selected: _ownerType == type,
                      icon: type == 'Particular'
                          ? Icons.person_outline_rounded
                          : type == 'Empresa'
                              ? Icons.apartment_rounded
                              : Icons.work_outline_rounded,
                      onTap: () => setState(() => _ownerType = type),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_ownerType != 'Particular') ...[
                  CohabiTextField(
                    controller: _companyController,
                    label: 'Nombre de la empresa',
                    hint: 'Nombre de la empresa',
                    icon: Icons.apartment_outlined,
                    validator: _required,
                  ),
                  const SizedBox(height: 18),
                ],
                CohabiTextField(
                  controller: _documentController,
                  label: 'DNI / NIE / NIF',
                  hint: 'Introduce tu número',
                  icon: Icons.badge_outlined,
                  validator: _required,
                ),
                const SizedBox(height: 18),
                CohabiTextField(
                  controller: _cityController,
                  label: 'Ciudad',
                  hint: 'Ej. Zaragoza',
                  icon: Icons.location_city_outlined,
                  validator: _required,
                ),
                const SizedBox(height: 18),
                CohabiTextField(
                  controller: _provinceController,
                  label: 'Provincia',
                  hint: 'Ej. Zaragoza',
                  icon: Icons.map_outlined,
                  validator: _required,
                ),
                const SizedBox(height: 18),
                CohabiDropdown<String>(
                  value: _language,
                  label: 'Idioma preferido',
                  items: const [
                    DropdownMenuItem(value: 'Español', child: Text('🌐  Español')),
                    DropdownMenuItem(value: 'English', child: Text('🌐  English')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _language = value);
                  },
                ),
                const SizedBox(height: 30),
                CohabiPrimaryButton(
                  text: 'Activar modo propietario',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _enableOwnerMode,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tu perfil de inquilino seguirá guardado. Podrás cambiar entre ambos modos cuando quieras.',
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
}

class _OwnerTypeCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OwnerTypeCard({
    required this.text,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CohabiCard(
      padding: const EdgeInsets.all(15),
      withShadow: false,
      borderSide: BorderSide(
        color: selected ? CohabiColors.turquoise : CohabiColors.border,
        width: selected ? 1.5 : 1,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: CohabiColors.turquoise),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: CohabiColors.navy,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (selected)
            const CircleAvatar(
              radius: 10,
              backgroundColor: CohabiColors.turquoise,
              child: Icon(Icons.check, color: Colors.white, size: 14),
            ),
        ],
      ),
    );
  }
}
