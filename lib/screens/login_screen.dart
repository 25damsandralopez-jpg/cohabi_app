import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';
import 'account_type_screen.dart';
import 'tenant_home_screen.dart';
import 'properties_dashboard_screen.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN SUPABASE
  // ============================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // --------------------------------------------------------
      // 1. INICIAR SESIÓN
      // --------------------------------------------------------

      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = response.user;

      if (user == null) {
        throw Exception(
          'No se pudo iniciar sesión.',
        );
      }

      // --------------------------------------------------------
      // 2. LEER ROLE DESDE PROFILES
      // --------------------------------------------------------

      final profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = profile['role']?.toString();

      if (!mounted) return;

      // --------------------------------------------------------
      // 3. NAVEGACIÓN SEGÚN TIPO DE CUENTA
      // --------------------------------------------------------

      if (role == 'tenant') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const TenantHomeScreen(),
          ),
              (route) => false,
        );

        return;
      }

      if (role == 'owner') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const PropertiesDashboardScreen(),
          ),
              (route) => false,
        );

        return;
      }

      _showError(
        'La cuenta no tiene un tipo de usuario válido.',
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      _showError(
        _getAuthErrorMessage(error.message),
      );
    } catch (error) {
      if (!mounted) return;

      _showError(
        'Error al iniciar sesión: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // MENSAJE DE ERROR
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // TRADUCIR ERRORES DE SUPABASE
  // ============================================================

  String _getAuthErrorMessage(String message) {
    final error = message.toLowerCase();

    if (error.contains('invalid login credentials')) {
      return 'Correo electrónico o contraseña incorrectos.';
    }

    if (error.contains('email not confirmed')) {
      return 'Debes confirmar tu correo electrónico antes de iniciar sesión.';
    }

    if (error.contains('invalid email')) {
      return 'El correo electrónico no es válido.';
    }

    if (error.contains('too many requests')) {
      return 'Has realizado demasiados intentos. Inténtalo de nuevo más tarde.';
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CohabiColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ==================================================
              // VOLVER
              // ==================================================

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    top: 8,
                  ),
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

              const SizedBox(height: 5),

              // ==================================================
              // LOGO
              // ==================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 85,
                ),
                child: Image.asset(
                  'assets/images/cohabi_logo.png',
                  width: 210,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // TITULO
              // ==================================================

              const Text(
                '¡Hola de nuevo!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Text(
                  'Inicia sesión para continuar en Cohabi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // TARJETA LOGIN
              // ==================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(24),
                    border: Border.all(
                      color: CohabiColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.04),
                        blurRadius: 20,
                        offset:
                        const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        // ========================================
                        // EMAIL
                        // ========================================

                        const Text(
                          'Correo electrónico',
                          style: TextStyle(
                            color: CohabiColors.navy,
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller:
                          _emailController,
                          keyboardType:
                          TextInputType
                              .emailAddress,
                          textInputAction:
                          TextInputAction.next,
                          decoration:
                          InputDecoration(
                            hintText:
                            'tu@email.com',
                            prefixIcon:
                            const Icon(
                              Icons
                                  .mail_outline_rounded,
                            ),
                            filled: true,
                            fillColor:
                            CohabiColors.background,
                            border:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(16),
                              borderSide:
                              const BorderSide(
                                color:
                                CohabiColors.border,
                              ),
                            ),
                            enabledBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(16),
                              borderSide:
                              const BorderSide(
                                color:
                                CohabiColors.border,
                              ),
                            ),
                            focusedBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(16),
                              borderSide:
                              const BorderSide(
                                color:
                                CohabiColors.purple,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            final email =
                                value?.trim() ?? '';

                            if (email.isEmpty) {
                              return 'Introduce tu correo electrónico.';
                            }

                            if (!email.contains('@')) {
                              return 'Introduce un correo electrónico válido.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // ========================================
                        // CONTRASEÑA
                        // ========================================

                        const Text(
                          'Contraseña',
                          style: TextStyle(
                            color: CohabiColors.navy,
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller:
                          _passwordController,
                          obscureText:
                          _obscurePassword,
                          textInputAction:
                          TextInputAction.done,
                          onFieldSubmitted: (_) {
                            _login();
                          },
                          decoration:
                          InputDecoration(
                            hintText:
                            'Introduce tu contraseña',
                            prefixIcon:
                            const Icon(
                              Icons.lock_outline_rounded,
                            ),
                            suffixIcon:
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                  !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons
                                    .visibility_off_outlined
                                    : Icons
                                    .visibility_outlined,
                              ),
                            ),
                            filled: true,
                            fillColor:
                            CohabiColors.background,
                            border:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(16),
                              borderSide:
                              const BorderSide(
                                color:
                                CohabiColors.border,
                              ),
                            ),
                            enabledBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(16),
                              borderSide:
                              const BorderSide(
                                color:
                                CohabiColors.border,
                              ),
                            ),
                            focusedBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(16),
                              borderSide:
                              const BorderSide(
                                color:
                                CohabiColors.purple,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Introduce tu contraseña.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 6),

                        // ========================================
                        // RECUPERAR CONTRASEÑA
                        // ========================================

                        Align(
                          alignment:
                          Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Lo conectaremos después
                              // con resetPasswordForEmail()
                            },
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color:
                                CohabiColors.purple,
                                fontSize: 13,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ========================================
                        // BOTÓN LOGIN
                        // ========================================

                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient:
                            CohabiColors
                                .primaryGradient,
                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap:
                              _isLoading
                                  ? null
                                  : _login,
                              borderRadius:
                              BorderRadius.circular(
                                18,
                              ),
                              child: Padding(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  children: [
                                    const Spacer(),

                                    if (_isLoading)
                                      const SizedBox(
                                        width: 23,
                                        height: 23,
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
                                    else
                                      const Text(
                                        'Iniciar sesión',
                                        style:
                                        TextStyle(
                                          color:
                                          Colors.white,
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight
                                              .w700,
                                        ),
                                      ),

                                    const Spacer(),

                                    if (!_isLoading)
                                      const Icon(
                                        Icons
                                            .arrow_forward_rounded,
                                        color:
                                        Colors.white,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ========================================
                        // O CONTINÚA CON
                        // ========================================

                        const Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color:
                                CohabiColors.border,
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'o continúa con',
                                style: TextStyle(
                                  color: CohabiColors
                                      .textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color:
                                CohabiColors.border,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _SocialButton(
                                text:
                                'Continuar con Google',
                                icon: Icons
                                    .g_mobiledata_rounded,
                                onPressed: () {
                                  // Google OAuth después
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _SocialButton(
                                text:
                                'Continuar con Apple',
                                icon: Icons.apple,
                                onPressed: () {
                                  // Apple OAuth después
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

              const SizedBox(height: 26),

              // ==================================================
              // NO TIENES CUENTA
              // ==================================================

              const Text(
                '¿Todavía no tienes cuenta?',
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: 230,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const AccountTypeScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: CohabiColors.purple,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Crear una cuenta',
                    style: TextStyle(
                      color: CohabiColors.purple,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // SEGURIDAD
              // ==================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(22),
                    border: Border.all(
                      color: CohabiColors.border,
                    ),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 27,
                        backgroundColor:
                        CohabiColors.purpleSoft,
                        child: Icon(
                          Icons.shield_outlined,
                          color: CohabiColors.purple,
                          size: 27,
                        ),
                      ),

                      SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tus datos están protegidos',
                              style: TextStyle(
                                color:
                                CohabiColors.navy,
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'Utilizamos conexiones seguras para proteger tu cuenta.',
                              style: TextStyle(
                                color: CohabiColors
                                    .textSecondary,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================
// BOTÓN SOCIAL
// ============================================================

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
          foregroundColor: CohabiColors.navy,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          side: const BorderSide(
            color: CohabiColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: CohabiColors.navy,
              size: 24,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 11.5,
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