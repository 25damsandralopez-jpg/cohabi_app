import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';
import 'properties_dashboard_screen.dart';

class EnableOwnerProfileScreen extends StatefulWidget {
  const EnableOwnerProfileScreen({super.key});

  @override
  State<EnableOwnerProfileScreen> createState() =>
      _EnableOwnerProfileScreenState();
}

class _EnableOwnerProfileScreenState
    extends State<EnableOwnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

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

  // ============================================================
  // ACTIVAR MODO PROPIETARIO
  // ============================================================

  Future<void> _enableOwnerMode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) return;

    if ((_ownerType == 'Empresa' ||
            _ownerType == 'Agencia inmobiliaria') &&
        _companyController.text.trim().isEmpty) {
      _showError(
        'Introduce el nombre de la empresa.',
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase =
          Supabase.instance.client;

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'No hay una sesión iniciada.',
        );
      }

      await supabase.rpc(
        'enable_owner_profile',
        params: {
          'profile_data': {
            'owner_type':
                _ownerType,

            'company_name':
                _companyController.text.trim(),

            'document_number':
                _documentController.text.trim(),

            'city':
                _cityController.text.trim(),

            'province':
                _provinceController.text.trim(),

            'language':
                _language,
          },
        },
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PropertiesDashboardScreen(),
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
        'No se pudo activar el modo propietario: $error',
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
        backgroundColor: Colors.redAccent,
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
                // ==============================================
                // ICONO
                // ==============================================

                Center(
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration:
                        const BoxDecoration(
                      color:
                          CohabiColors.turquoiseSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.home_work_outlined,
                      color:
                          CohabiColors.turquoise,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Activa el modo propietario',
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
                  'Completa los datos necesarios para publicar y gestionar propiedades en Cohabi.',
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
                // TIPO PROPIETARIO
                // ==============================================

                const Text(
                  '¿Cómo utilizarás Cohabi?',
                  style: TextStyle(
                    color:
                        CohabiColors.navy,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                _OwnerTypeCard(
                  text: 'Particular',
                  icon: Icons
                      .person_outline_rounded,
                  selected:
                      _ownerType ==
                          'Particular',
                  onTap: () {
                    setState(() {
                      _ownerType =
                          'Particular';
                    });
                  },
                ),

                const SizedBox(height: 10),

                _OwnerTypeCard(
                  text: 'Empresa',
                  icon:
                      Icons.apartment_rounded,
                  selected:
                      _ownerType ==
                          'Empresa',
                  onTap: () {
                    setState(() {
                      _ownerType =
                          'Empresa';
                    });
                  },
                ),

                const SizedBox(height: 10),

                _OwnerTypeCard(
                  text:
                      'Agencia inmobiliaria',
                  icon:
                      Icons.work_outline_rounded,
                  selected:
                      _ownerType ==
                          'Agencia inmobiliaria',
                  onTap: () {
                    setState(() {
                      _ownerType =
                          'Agencia inmobiliaria';
                    });
                  },
                ),

                const SizedBox(height: 22),

                // ==============================================
                // EMPRESA
                // ==============================================

                if (_ownerType !=
                    'Particular') ...[
                  _label(
                    'Nombre de la empresa',
                  ),

                  const SizedBox(height: 8),

                  _field(
                    controller:
                        _companyController,
                    hint:
                        'Nombre de la empresa',
                    icon:
                        Icons.apartment_outlined,
                  ),

                  const SizedBox(height: 18),
                ],

                // ==============================================
                // DOCUMENTO
                // ==============================================

                _label('DNI / NIE / NIF'),

                const SizedBox(height: 8),

                _field(
                  controller:
                      _documentController,
                  hint:
                      'Introduce tu número',
                  icon:
                      Icons.badge_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Campo obligatorio';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==============================================
                // CIUDAD
                // ==============================================

                _label('Ciudad'),

                const SizedBox(height: 8),

                _field(
                  controller:
                      _cityController,
                  hint: 'Ej. Zaragoza',
                  icon: Icons
                      .location_city_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Campo obligatorio';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==============================================
                // PROVINCIA
                // ==============================================

                _label('Provincia'),

                const SizedBox(height: 8),

                _field(
                  controller:
                      _provinceController,
                  hint: 'Ej. Zaragoza',
                  icon:
                      Icons.map_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Campo obligatorio';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==============================================
                // IDIOMA
                // ==============================================

                _label('Idioma preferido'),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 15,
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
                  child:
                      DropdownButtonHideUnderline(
                    child:
                        DropdownButton<String>(
                      value: _language,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'Español',
                          child: Text(
                            '🌐  Español',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'English',
                          child: Text(
                            '🌐  English',
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value !=
                            null) {
                          setState(() {
                            _language =
                                value;
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==============================================
                // BOTÓN
                // ==============================================

                _PrimaryButton(
                  text:
                      'Activar modo propietario',
                  isLoading:
                      _isLoading,
                  onTap:
                      _enableOwnerMode,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Tu perfil de inquilino seguirá guardado. Podrás cambiar entre ambos modos cuando quieras.',
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

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: CohabiColors.navy,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon == null
            ? null
            : Icon(
                icon,
                color:
                    CohabiColors.textMuted,
              ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide:
              const BorderSide(
            color:
                CohabiColors.border,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide:
              const BorderSide(
            color:
                CohabiColors.turquoise,
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
      ),
    );
  }
}


// ============================================================
// TIPO DE PROPIETARIO
// ============================================================

class _OwnerTypeCard
    extends StatelessWidget {
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
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(15),
      child: Container(
        padding:
            const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? CohabiColors.turquoise
                : CohabiColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  CohabiColors.turquoise,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color:
                      CohabiColors.navy,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),

            if (selected)
              const CircleAvatar(
                radius: 10,
                backgroundColor:
                    CohabiColors.turquoise,
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
}


// ============================================================
// BOTÓN
// ============================================================

class _PrimaryButton
    extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onTap;

  const _PrimaryButton({
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