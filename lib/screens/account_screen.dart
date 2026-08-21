import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';

import 'enable_owner_profile_screen.dart';
import 'enable_tenant_profile_screen.dart';
import 'properties_dashboard_screen.dart';
import 'tenant_home_screen.dart';
import 'welcome_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
  });

  @override
  State<AccountScreen> createState() =>
      _AccountScreenState();
}

class _AccountScreenState
    extends State<AccountScreen> {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  bool _isLoading = true;
  bool _isChangingMode = false;

  String _firstName = '';
  String _lastName = '';
  String _email = '';

  String _activeMode = 'tenant';

  bool _hasTenantProfile = false;
  bool _hasOwnerProfile = false;

  @override
  void initState() {
    super.initState();

    _loadAccount();
  }

  // ============================================================
  // CARGAR CUENTA
  // ============================================================

  Future<void> _loadAccount() async {
    try {
      final user =
          _supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'No hay una sesión iniciada.',
        );
      }

      // ========================================================
      // PERFIL GENERAL
      // ========================================================

      final profile = await _supabase
          .from('profiles')
          .select(
            'first_name, last_name, active_mode',
          )
          .eq(
            'id',
            user.id,
          )
          .single();

      // ========================================================
      // COMPROBAR PERFIL TENANT
      // ========================================================

      final tenantProfile =
          await _supabase
              .from('tenant_profiles')
              .select('user_id')
              .eq(
                'user_id',
                user.id,
              )
              .maybeSingle();

      // ========================================================
      // COMPROBAR PERFIL OWNER
      // ========================================================

      final ownerProfile =
          await _supabase
              .from('owner_profiles')
              .select('user_id')
              .eq(
                'user_id',
                user.id,
              )
              .maybeSingle();

      if (!mounted) return;

      setState(() {
        _firstName =
            profile['first_name']
                    ?.toString() ??
                '';

        _lastName =
            profile['last_name']
                    ?.toString() ??
                '';

        _activeMode =
            profile['active_mode']
                    ?.toString() ??
                'tenant';

        _email =
            user.email ?? '';

        _hasTenantProfile =
            tenantProfile != null;

        _hasOwnerProfile =
            ownerProfile != null;

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(
        'No se pudo cargar tu cuenta: $error',
      );
    }
  }

  // ============================================================
  // CAMBIO DE MODO
  // ============================================================

  Future<void> _changeMode() async {
    if (_isChangingMode) return;

    // ==========================================================
    // TENANT → OWNER
    // ==========================================================

    if (_activeMode == 'tenant') {
      if (!_hasOwnerProfile) {
        final result =
            await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const EnableOwnerProfileScreen(),
          ),
        );

        if (result == true) {
          await _loadAccount();
        }

        return;
      }

      await _switchMode(
        'owner',
      );

      return;
    }

    // ==========================================================
    // OWNER → TENANT
    // ==========================================================

    if (!_hasTenantProfile) {
      final result =
          await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const EnableTenantProfileScreen(),
        ),
      );

      if (result == true) {
        await _loadAccount();
      }

      return;
    }

    await _switchMode(
      'tenant',
    );
  }

  // ============================================================
  // RPC SWITCH ACTIVE MODE
  // ============================================================

  Future<void> _switchMode(
    String targetMode,
  ) async {
    if (_isChangingMode) return;

    setState(() {
      _isChangingMode = true;
    });

    try {
      await _supabase.rpc(
        'switch_active_mode',
        params: {
          'target_mode':
              targetMode,
        },
      );

      if (!mounted) return;

      // ========================================================
      // OWNER
      // ========================================================

      if (targetMode == 'owner') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const PropertiesDashboardScreen(),
          ),
          (_) => false,
        );

        return;
      }

      // ========================================================
      // TENANT
      // ========================================================

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
        'No se pudo cambiar de modo: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChangingMode = false;
        });
      }
    }
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  Future<void> _logout() async {
    try {
      await _supabase.auth.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const WelcomeScreen(),
        ),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;

      _showError(
        'No se pudo cerrar sesión.',
      );
    }
  }

  // ============================================================
  // CONFIRMAR LOGOUT
  // ============================================================

  Future<void> _confirmLogout() async {
    final result =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cerrar sesión',
          ),
          content: const Text(
            '¿Seguro que quieres cerrar sesión?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color:
                      Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _logout();
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        backgroundColor:
            Colors.redAccent,
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // GETTERS
  // ============================================================

  bool get _bothProfilesActive =>
      _hasTenantProfile &&
      _hasOwnerProfile;

  bool get _isTenant =>
      _activeMode == 'tenant';

  String get _fullName {
    final name =
        '$_firstName $_lastName'
            .trim();

    return name.isEmpty
        ? 'Usuario Cohabi'
        : name;
  }

  String get _modeTitle =>
      _isTenant
          ? 'Inquilino activo'
          : 'Propietario activo';

  String get _secondaryModeText {
    if (_bothProfilesActive) {
      return _isTenant
          ? 'También disponible: Propietario'
          : 'También disponible: Inquilino';
    }

    return _isTenant
        ? 'Todavía no tienes modo propietario'
        : 'Todavía no tienes modo inquilino';
  }

  String get _changeModeDescription {
    if (_isTenant) {
      if (_hasOwnerProfile) {
        return 'También puedes publicar y gestionar propiedades con esta misma cuenta.';
      }

      return 'Activa el lado propietario de tu cuenta para publicar y gestionar tus viviendas.';
    }

    if (_hasTenantProfile) {
      return 'También puedes buscar habitaciones o viviendas con esta misma cuenta.';
    }

    return 'Activa el modo inquilino para buscar habitaciones y viviendas con esta misma cuenta.';
  }

  String get _changeModeButton {
    if (_isTenant) {
      return _hasOwnerProfile
          ? 'Cambiar a modo propietario'
          : 'Activar modo propietario';
    }

    return _hasTenantProfile
        ? 'Cambiar a modo inquilino'
        : 'Activar modo inquilino';
  }

  String get _changeModeNote {
    if (_bothProfilesActive) {
      return 'Tus dos perfiles ya están activos';
    }

    return _isTenant
        ? 'Configura tu perfil de propietario para publicar viviendas'
        : 'Configura tu perfil de inquilino para buscar habitaciones y pisos';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CohabiColors.background,

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    CohabiColors.turquoise,
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // ============================================
                  // CONTENIDO
                  // ============================================

                  Expanded(
                    child:
                        RefreshIndicator(
                      color:
                          CohabiColors
                              .turquoise,
                      onRefresh:
                          _loadAccount,
                      child:
                          SingleChildScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          18,
                          20,
                          30,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .stretch,
                          children: [
                            // ==================================
                            // TÍTULO
                            // ==================================

                            const Text(
                              'Cuenta',
                              textAlign:
                                  TextAlign.center,
                              style:
                                  TextStyle(
                                color:
                                    CohabiColors
                                        .navy,
                                fontSize:
                                    30,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            // ==================================
                            // SALUDO
                            // ==================================

                            RichText(
                              text:
                                  TextSpan(
                                style:
                                    const TextStyle(
                                  color:
                                      CohabiColors
                                          .textSecondary,
                                  fontSize:
                                      20,
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'Hola, ',
                                  ),
                                  TextSpan(
                                    text:
                                        _firstName.isEmpty
                                            ? 'usuario'
                                            : _firstName,
                                    style:
                                        const TextStyle(
                                      color:
                                          CohabiColors
                                              .turquoise,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        ' 👋',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // ==================================
                            // PERFIL
                            // ==================================

                            _buildProfileCard(),

                            const SizedBox(
                              height: 16,
                            ),

                            // ==================================
                            // MODO ACTUAL
                            // ==================================

                            _buildCurrentModeCard(),

                            const SizedBox(
                              height: 16,
                            ),

                            // ==================================
                            // CAMBIO DE MODO
                            // ==================================

                            _buildChangeModeCard(),

                            const SizedBox(
                              height: 16,
                            ),

                            // ==================================
                            // PERFILES
                            // ==================================

                            _buildProfilesCard(),

                            const SizedBox(
                              height: 16,
                            ),

                            // ==================================
                            // CONFIG
                            // ==================================

                            _buildSettingsCard(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ============================================
                  // BOTTOM NAVIGATION
                  // ============================================

                  if (_isTenant)
                    _buildTenantBottomNavigation(),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // PERFIL PRINCIPAL
  // ============================================================

  Widget _buildProfileCard() {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          _cardDecoration(),
      child: Row(
        children: [
          // ==============================================
          // AVATAR
          // ==============================================

          Container(
            width: 72,
            height: 72,
            decoration:
                const BoxDecoration(
              gradient:
                  CohabiColors
                      .primaryGradient,
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color:
                  Colors.white,
              size: 45,
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  _fullName,
                  style:
                      const TextStyle(
                    color:
                        CohabiColors
                            .navy,
                    fontSize:
                        21,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _email,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        CohabiColors
                            .textSecondary,
                    fontSize:
                        14,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal:
                        10,
                    vertical:
                        5,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        CohabiColors
                            .turquoiseSoft,
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child:
                      const Row(
                    mainAxisSize:
                        MainAxisSize
                            .min,
                    children: [
                      Icon(
                        Icons
                            .check_circle_rounded,
                        color:
                            CohabiColors
                                .turquoise,
                        size:
                            16,
                      ),
                      SizedBox(
                        width:
                            5,
                      ),
                      Text(
                        'Perfil verificado',
                        style:
                            TextStyle(
                          color:
                              CohabiColors
                                  .turquoise,
                          fontSize:
                              12,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons
                .chevron_right_rounded,
            color:
                CohabiColors.navy,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MODO ACTUAL
  // ============================================================

  Widget _buildCurrentModeCard() {
    final modeColor =
        _isTenant
            ? CohabiColors.purple
            : CohabiColors.turquoise;

    final softColor =
        _isTenant
            ? CohabiColors.purpleSoft
            : CohabiColors.turquoiseSoft;

    final icon =
        _isTenant
            ? Icons.person_outline_rounded
            : Icons.home_outlined;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration:
          _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration:
                BoxDecoration(
              color:
                  softColor,
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              icon,
              color:
                  modeColor,
              size:
                  27,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Text(
                  'Modo actual',
                  style:
                      TextStyle(
                    color:
                        CohabiColors
                            .navy,
                    fontSize:
                        16,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _secondaryModeText,
                  style:
                      const TextStyle(
                    color:
                        CohabiColors
                            .textSecondary,
                    fontSize:
                        12.5,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal:
                  12,
              vertical:
                  8,
            ),
            decoration:
                BoxDecoration(
              color:
                  softColor,
              borderRadius:
                  BorderRadius
                      .circular(
                18,
              ),
              border:
                  Border.all(
                color:
                    modeColor
                        .withOpacity(
                  0.18,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      modeColor,
                  size:
                      18,
                ),

                const SizedBox(
                  width: 6,
                ),

                Text(
                  _modeTitle,
                  style:
                      TextStyle(
                    color:
                        modeColor,
                    fontSize:
                        12.5,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CAMBIO DE MODO
  // ============================================================

  Widget _buildChangeModeCard() {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Cambiar de modo',
                      style:
                          TextStyle(
                        color:
                            CohabiColors
                                .navy,
                        fontSize:
                            22,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      _changeModeDescription,
                      style:
                          const TextStyle(
                        color:
                            CohabiColors
                                .textSecondary,
                        fontSize:
                            14,
                        height:
                            1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Container(
                width: 82,
                height: 82,
                decoration:
                    BoxDecoration(
                  color:
                      CohabiColors
                          .purpleSoft,
                  borderRadius:
                      BorderRadius
                          .circular(
                    22,
                  ),
                ),
                child: Icon(
                  _isTenant
                      ? Icons
                          .home_work_outlined
                      : Icons
                          .search_rounded,
                  color:
                      CohabiColors
                          .purple,
                  size:
                      38,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          // ==============================================
          // BOTÓN
          // ==============================================

          Container(
            width:
                double.infinity,
            height:
                56,
            decoration:
                BoxDecoration(
              gradient:
                  CohabiColors
                      .primaryGradient,
              borderRadius:
                  BorderRadius
                      .circular(
                16,
              ),
            ),
            child:
                Material(
              color:
                  Colors.transparent,
              child:
                  InkWell(
                onTap:
                    _isChangingMode
                        ? null
                        : _changeMode,
                borderRadius:
                    BorderRadius
                        .circular(
                  16,
                ),
                child:
                    Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal:
                        18,
                  ),
                  child:
                      Row(
                    children: [
                      const Spacer(),

                      if (_isChangingMode)
                        const SizedBox(
                          width:
                              23,
                          height:
                              23,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.5,
                            valueColor:
                                AlwaysStoppedAnimation<
                                    Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      else
                        Text(
                          _changeModeButton,
                          style:
                              const TextStyle(
                            color:
                                Colors
                                    .white,
                            fontSize:
                                15,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),

                      const Spacer(),

                      if (!_isChangingMode)
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

          const SizedBox(
            height: 14,
          ),

          Row(
            children: [
              const Icon(
                Icons
                    .check_circle_outline_rounded,
                color:
                    CohabiColors
                        .turquoise,
                size:
                    19,
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child: Text(
                  _changeModeNote,
                  style:
                      const TextStyle(
                    color:
                        CohabiColors
                            .textSecondary,
                    fontSize:
                        12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TUS PERFILES
  // ============================================================

  Widget _buildProfilesCard() {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        8,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Tus perfiles',
            style:
                TextStyle(
              color:
                  CohabiColors.navy,
              fontSize:
                  21,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          _buildProfileRow(
            title:
                'Perfil de inquilino',
            icon:
                Icons.person_outline_rounded,
            exists:
                _hasTenantProfile,
            onTap: () {
              if (!_hasTenantProfile) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const EnableTenantProfileScreen(),
                  ),
                );
              }
            },
          ),

          const Divider(
            height: 1,
            color:
                CohabiColors.border,
          ),

          _buildProfileRow(
            title:
                'Perfil de propietario',
            icon:
                Icons.home_outlined,
            exists:
                _hasOwnerProfile,
            onTap: () {
              if (!_hasOwnerProfile) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const EnableOwnerProfileScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow({
    required String title,
    required IconData icon,
    required bool exists,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 15,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color:
                    CohabiColors
                        .purpleSoft,
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
              ),
              child:
                  Icon(
                icon,
                color:
                    CohabiColors
                        .purple,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(
                  color:
                      CohabiColors
                          .navy,
                  fontSize:
                      14,
                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),
            ),

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal:
                    10,
                vertical:
                    6,
              ),
              decoration:
                  BoxDecoration(
                color:
                    exists
                        ? CohabiColors
                            .turquoiseSoft
                        : CohabiColors
                            .purpleSoft,
                borderRadius:
                    BorderRadius
                        .circular(
                  18,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    exists
                        ? Icons
                            .check_circle_rounded
                        : Icons
                            .schedule_rounded,
                    color:
                        exists
                            ? CohabiColors
                                .turquoise
                            : CohabiColors
                                .purple,
                    size:
                        16,
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  Text(
                    exists
                        ? 'Activo'
                        : 'Pendiente',
                    style:
                        TextStyle(
                      color:
                          exists
                              ? CohabiColors
                                  .turquoise
                              : CohabiColors
                                  .purple,
                      fontSize:
                          11.5,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            const Icon(
              Icons
                  .chevron_right_rounded,
              color:
                  CohabiColors
                      .textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONFIGURACIÓN
  // ============================================================

  Widget _buildSettingsCard() {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        6,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style:
                TextStyle(
              color:
                  CohabiColors.navy,
              fontSize:
                  21,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          _settingsRow(
            icon:
                Icons.person_outline_rounded,
            title:
                'Datos personales',
            onTap: () {},
          ),

          const Divider(
            height: 1,
            color:
                CohabiColors.border,
          ),

          _settingsRow(
            icon:
                Icons.shield_outlined,
            title:
                'Privacidad',
            onTap: () {},
          ),

          const Divider(
            height: 1,
            color:
                CohabiColors.border,
          ),

          _settingsRow(
            icon:
                Icons.notifications_none_rounded,
            title:
                'Notificaciones',
            onTap: () {},
          ),

          const Divider(
            height: 1,
            color:
                CohabiColors.border,
          ),

          _settingsRow(
            icon:
                Icons.language_rounded,
            title:
                'Idioma',
            onTap: () {},
          ),

          const Divider(
            height: 1,
            color:
                CohabiColors.border,
          ),

          _settingsRow(
            icon:
                Icons.logout_rounded,
            title:
                'Cerrar sesión',
            onTap:
                _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap:
          onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration:
                  BoxDecoration(
                color:
                    CohabiColors
                        .purpleSoft,
                borderRadius:
                    BorderRadius
                        .circular(
                  10,
                ),
              ),
              child:
                  Icon(
                icon,
                color:
                    CohabiColors
                        .purple,
                size:
                    21,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(
                  color:
                      CohabiColors
                          .navy,
                  fontSize:
                      14,
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
            ),

            const Icon(
              Icons
                  .chevron_right_rounded,
              color:
                  CohabiColors
                      .textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAV TENANT
  // ============================================================

  Widget _buildTenantBottomNavigation() {
    return Container(
      decoration:
          const BoxDecoration(
        color:
            Colors.white,
        border: Border(
          top:
              BorderSide(
            color:
                CohabiColors.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceAround,
            children: [
              _bottomItem(
                icon:
                    Icons.home_outlined,
                text:
                    'Inicio',
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const TenantHomeScreen(),
                    ),
                    (_) => false,
                  );
                },
              ),

              _bottomItem(
                icon:
                    Icons.auto_awesome_outlined,
                text:
                    'Selección',
              ),

              _bottomItem(
                icon:
                    Icons.assignment_outlined,
                text:
                    'Solicitudes',
              ),

              _bottomItem(
                icon:
                    Icons.house_outlined,
                text:
                    'Mi Casa',
              ),

              _bottomItem(
                icon:
                    Icons.person_rounded,
                text:
                    'Cuenta',
                selected:
                    true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String text,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    final color =
        selected
            ? CohabiColors.purple
            : CohabiColors
                .textSecondary;

    return InkWell(
      onTap:
          onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Icon(
              icon,
              color:
                  color,
              size:
                  25,
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              text,
              style:
                  TextStyle(
                color:
                    color,
                fontSize:
                    10.5,
                fontWeight:
                    selected
                        ? FontWeight
                            .w700
                        : FontWeight
                            .w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DECORACIÓN CARD
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color:
          Colors.white,

      borderRadius:
          BorderRadius.circular(
        20,
      ),

      border:
          Border.all(
        color:
            CohabiColors.border
                .withOpacity(
          0.65,
        ),
      ),

      boxShadow: [
        BoxShadow(
          color:
              Colors.black
                  .withOpacity(
            0.035,
          ),
          blurRadius:
              14,
          offset:
              const Offset(
            0,
            5,
          ),
        ),
      ],
    );
  }
}