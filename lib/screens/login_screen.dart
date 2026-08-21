import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'account_type_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: CohabiColors.navy,
                      size: 22,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // LOGO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 85),
                child: Image.asset(
                  'assets/images/cohabi_logo.png',
                  width: 210,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              // FRASE DE MARCA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      color: CohabiColors.navy,
                      fontSize: 16,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(text: 'Gestiona tus '),
                      TextSpan(
                        text: 'propiedades',
                        style: TextStyle(
                          color: CohabiColors.turquoise,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ', encuentra\ninquilinos ideales y maximiza tu '),
                      TextSpan(
                        text: 'rentabilidad.',
                        style: TextStyle(
                          color: CohabiColors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // SEPARADOR ONDULADO SUAVE
              Container(
                width: double.infinity,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF5F6FA),
                      CohabiColors.background,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // TÍTULO
              const Text(
                'Iniciar sesión',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  'Accede a tu cuenta y continúa gestionando\ntus propiedades.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // TARJETA LOGIN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Correo electrónico',
                          style: TextStyle(
                            color: CohabiColors.navy,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            hint: 'tu@email.com',
                            icon: Icons.mail_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Introduce tu correo electrónico';
                            }

                            if (!value.contains('@')) {
                              return 'Introduce un correo válido';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'Contraseña',
                          style: TextStyle(
                            color: CohabiColors.navy,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: CohabiColors.navy,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Introduce tu contraseña';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _rememberMe
                                      ? CohabiColors.turquoise
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: _rememberMe
                                        ? CohabiColors.turquoise
                                        : CohabiColors.border,
                                  ),
                                ),
                                child: _rememberMe
                                    ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                                    : null,
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Text(
                              'Recordarme',
                              style: TextStyle(
                                color: CohabiColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),

                            const Spacer(),

                            TextButton(
                              onPressed: () {
                                debugPrint('Olvidé mi contraseña');
                              },
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: CohabiColors.purple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // BOTÓN INICIAR SESIÓN
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: CohabiColors.primaryGradient,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  debugPrint(
                                    'Login: ${_emailController.text}',
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    Spacer(),
                                    Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // O CONTINÚA CON
                        const Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: CohabiColors.border,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'o continúa con',
                                style: TextStyle(
                                  color: CohabiColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: CohabiColors.border,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _SocialButton(
                                text: 'Continuar con Google',
                                icon: Icons.g_mobiledata_rounded,
                                onPressed: () {
                                  debugPrint('Google');
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _SocialButton(
                                text: 'Continuar con Apple',
                                icon: Icons.apple,
                                onPressed: () {
                                  debugPrint('Apple');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // SEGURIDAD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.035),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: CohabiColors.purpleSoft,
                        child: Icon(
                          Icons.shield_outlined,
                          color: CohabiColors.purple,
                          size: 28,
                        ),
                      ),

                      SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu seguridad es nuestra prioridad',
                              style: TextStyle(
                                color: CohabiColors.navy,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Usamos cifrado y medidas avanzadas para proteger tu información.',
                              style: TextStyle(
                                color: CohabiColors.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                '¿No tienes cuenta?',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: 190,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountTypeScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: CohabiColors.purple,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: CohabiColors.purple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 18),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: CohabiColors.purple,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: CohabiColors.textMuted,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: CohabiColors.textSecondary,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: CohabiColors.border,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: CohabiColors.purple,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: CohabiColors.coral,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: CohabiColors.coral,
          width: 1.4,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: CohabiColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: CohabiColors.navy,
              size: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}