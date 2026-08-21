import 'package:flutter/material.dart';
import 'property_features_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';

class PropertyRegisterScreen extends StatefulWidget {
  const PropertyRegisterScreen({super.key});

  @override
  State<PropertyRegisterScreen> createState() =>
      _PropertyRegisterScreenState();
}

class _PropertyRegisterScreenState extends State<PropertyRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;

  String _tenantType = 'Mixto';

  final Set<String> _features = {
    'Ascensor',
    'Garaje',
    'Balcón',
    'Salón',
    'Comedor',
    'Cocina',
    'Amueblado',
    'Lavadora',
    'Videovigilancia',
  };

  final Set<String> _services = {
    'Agua',
    'Luz',
    'Calefacción',
    'Limpieza',
    'WiFi / Internet',
  };

  final _propertyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _roomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _surfaceController = TextEditingController();

  String? _propertyType;
  String _propertyCondition = 'Muy buen estado';

  @override
  void dispose() {
    _propertyNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _roomsController.dispose();
    _bathroomsController.dispose();
    _surfaceController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    final formOk = _formKey.currentState?.validate() ?? false;

    if (!formOk || _propertyType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos obligatorios.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay una sesión iniciada.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final property = await supabase
        .from('properties')
        .insert({
      'owner_id': user.id,
      'name': _propertyNameController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'postal_code': _postalCodeController.text.trim(),
      'property_type': _propertyType,
      'rooms': int.parse(_roomsController.text.trim()),
      'bathrooms': int.parse(_bathroomsController.text.trim()),
      'surface': double.parse(_surfaceController.text.trim()),
      'condition': _propertyCondition,
    })
        .select('id')
        .single();

    final propertyId = property['id'] as String;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyFeaturesScreen(
          propertyId: propertyId,
          roomCount: int.parse(_roomsController.text.trim()),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Obligatorio';
    }

    final number = double.tryParse(value.trim());

    if (number == null || number <= 0) {
      return 'Valor no válido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStepIndicator(),

                      const SizedBox(height: 22),

                      const Text(
                        'Información del piso',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CohabiColors.navy,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Cuéntanos los datos básicos de tu piso.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CohabiColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 25),

                      _buildField(
                        controller: _propertyNameController,
                        label: 'Nombre del piso',
                        hint: 'Ej. Piso Centro',
                        icon: Icons.apartment_rounded,
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: 12),

                      _buildField(
                        controller: _addressController,
                        label: 'Dirección',
                        hint: 'Ej. Calle Gran Vía 123',
                        icon: Icons.location_on_outlined,
                        validator: _requiredValidator,
                      ),

                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildField(
                              controller: _cityController,
                              label: 'Ciudad',
                              hint: 'Ej. Madrid',
                              icon: Icons.location_city_rounded,
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              controller: _postalCodeController,
                              label: 'Código postal',
                              hint: 'Ej. 28001',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.number,
                              validator: _requiredValidator,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _buildPropertyType(),

                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildField(
                              controller: _roomsController,
                              label: 'Habitaciones',
                              hint: 'Ej. 6',
                              icon: Icons.bed_outlined,
                              keyboardType: TextInputType.number,
                              validator: _numberValidator,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: _buildField(
                              controller: _bathroomsController,
                              label: 'Baños',
                              hint: 'Ej. 2',
                              icon: Icons.bathtub_outlined,
                              keyboardType: TextInputType.number,
                              validator: _numberValidator,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: _buildField(
                              controller: _surfaceController,
                              label: 'Superficie',
                              hint: 'Ej. 90',
                              icon: Icons.straighten_rounded,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: _numberValidator,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Estado del piso',
                        style: TextStyle(
                          color: CohabiColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildConditionCard(
                              title: 'Muy buen estado',
                              subtitle:
                              'En perfectas condiciones, listo para entrar.',
                              icon: Icons.auto_awesome_rounded,
                              iconColor: CohabiColors.turquoise,
                              value: 'Muy buen estado',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildConditionCard(
                              title: 'Buen estado',
                              subtitle: 'Bien cuidado, con uso normal.',
                              icon: Icons.thumb_up_alt_outlined,
                              iconColor: Colors.amber,
                              value: 'Buen estado',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildConditionCard(
                              title: 'Necesita mejoras',
                              subtitle:
                              'Pequeños detalles por actualizar.',
                              icon: Icons.build_outlined,
                              iconColor: Colors.orange,
                              value: 'Necesita algunas mejoras',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      _buildContinueButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 210,
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: CohabiColors.navy,
                size: 30,
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Image.asset(
                'assets/images/cohabi_logo.png',
                width: 185,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                height: 50,
                color: const Color(0xFFF8F9FD),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: CohabiColors.turquoise.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Paso 1 de 6',
            style: TextStyle(
              color: CohabiColors.turquoise,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            6,
                (index) => Container(
              width: index == 0 ? 42 : 30,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index == 0
                    ? CohabiColors.turquoise
                    : const Color(0xFFE1E3EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: CohabiColors.navy,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(
          color: CohabiColors.textSecondary,
        ),
        labelStyle: const TextStyle(
          color: CohabiColors.navy,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          icon,
          color: CohabiColors.navy,
          size: 21,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE1E3EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE1E3EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: CohabiColors.turquoise,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyType() {
    return DropdownButtonFormField<String>(
      value: _propertyType,
      validator: (value) {
        if (value == null) {
          return 'Selecciona un tipo de vivienda';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Tipo de vivienda',
        prefixIcon: Container(
          margin: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: CohabiColors.turquoise.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.home_outlined,
            color: CohabiColors.turquoise,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE1E3EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE1E3EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: CohabiColors.turquoise,
            width: 1.6,
          ),
        ),
      ),
      hint: const Text('Selecciona una opción'),
      items: const [
        DropdownMenuItem(value: 'Piso', child: Text('Piso')),
        DropdownMenuItem(value: 'Casa', child: Text('Casa')),
        DropdownMenuItem(value: 'Estudio', child: Text('Estudio')),
        DropdownMenuItem(value: 'Ático', child: Text('Ático')),
        DropdownMenuItem(value: 'Dúplex', child: Text('Dúplex')),
      ],
      onChanged: (value) {
        setState(() {
          _propertyType = value;
        });
      },
    );
  }

  Widget _buildConditionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String value,
  }) {
    final selected = _propertyCondition == value;

    return InkWell(
      onTap: () {
        setState(() {
          _propertyCondition = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 185),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected
              ? CohabiColors.turquoise.withOpacity(0.045)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? CohabiColors.turquoise
                : const Color(0xFFE1E3EB),
            width: selected ? 1.7 : 1,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected
                    ? CohabiColors.turquoise
                    : const Color(0xFFD8DAE2),
              ),
            ),

            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 27,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CohabiColors.navy,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CohabiColors.textSecondary,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return InkWell(
      onTap: _continue,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              CohabiColors.turquoise,
              Color(0xFF2F8DFF),
              CohabiColors.purple,
            ],
          ),
        ),
        child: const Row(
          children: [
            Spacer(),
            Text(
              'Continuar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 17);

    path.cubicTo(
      size.width * 0.18,
      50,
      size.width * 0.32,
      10,
      size.width * 0.50,
      27,
    );

    path.cubicTo(
      size.width * 0.68,
      45,
      size.width * 0.82,
      8,
      size.width,
      25,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}