import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/cohabi_bottom_navigation.dart';
import '../core/widgets/cohabi_snackbar.dart';
import '../features/account/models/account_state.dart';
import '../features/account/services/account_service.dart';
import '../features/account/widgets/widgets.dart';
import 'enable_owner_profile_screen.dart';
import 'enable_tenant_profile_screen.dart';
import 'properties_dashboard_screen.dart';
import 'tenant_home_screen.dart';
import 'welcome_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AccountService _accountService = AccountService();

  AccountStateData? _account;
  bool _isLoading = true;
  bool _isChangingMode = false;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    try {
      final account = await _accountService.loadCurrentAccount();
      if (!mounted) return;
      setState(() {
        _account = account;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CohabiSnackbar.error(context, 'No se pudo cargar tu cuenta: $error');
    }
  }

  Future<void> _changeMode() async {
    final account = _account;
    if (account == null || _isChangingMode) return;

    if (account.isTenant && !account.hasOwnerProfile) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EnableOwnerProfileScreen()),
      );
      if (mounted) await _loadAccount();
      return;
    }

    if (account.isOwner && !account.hasTenantProfile) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EnableTenantProfileScreen()),
      );
      if (mounted) await _loadAccount();
      return;
    }

    await _switchMode(account.isTenant ? 'owner' : 'tenant');
  }

  Future<void> _switchMode(String targetMode) async {
    if (_isChangingMode) return;
    setState(() => _isChangingMode = true);

    try {
      await _accountService.switchMode(targetMode);
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => targetMode == 'owner'
              ? const PropertiesDashboardScreen()
              : const TenantHomeScreen(),
        ),
        (_) => false,
      );
    } on PostgrestException catch (error) {
      if (mounted) CohabiSnackbar.error(context, error.message);
    } catch (error) {
      if (mounted) {
        CohabiSnackbar.error(context, 'No se pudo cambiar de modo: $error');
      }
    } finally {
      if (mounted) setState(() => _isChangingMode = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
    } catch (_) {
      if (mounted) CohabiSnackbar.error(context, 'No se pudo cerrar sesión.');
    }
  }

  String _secondaryModeText(AccountStateData account) {
    if (account.hasBothProfiles) {
      return account.isTenant
          ? 'También disponible: Propietario'
          : 'También disponible: Inquilino';
    }
    return account.isTenant
        ? 'Todavía no tienes modo propietario'
        : 'Todavía no tienes modo inquilino';
  }

  String _changeDescription(AccountStateData account) {
    if (account.isTenant) {
      return account.hasOwnerProfile
          ? 'También puedes publicar y gestionar propiedades con esta misma cuenta.'
          : 'Activa el lado propietario de tu cuenta para publicar y gestionar tus viviendas.';
    }
    return account.hasTenantProfile
        ? 'También puedes buscar habitaciones o viviendas con esta misma cuenta.'
        : 'Activa el modo inquilino para buscar habitaciones y viviendas con esta misma cuenta.';
  }

  String _changeButton(AccountStateData account) {
    if (account.isTenant) {
      return account.hasOwnerProfile
          ? 'Cambiar a modo propietario'
          : 'Activar modo propietario';
    }
    return account.hasTenantProfile
        ? 'Cambiar a modo inquilino'
        : 'Activar modo inquilino';
  }

  String _changeNote(AccountStateData account) {
    if (account.hasBothProfiles) return 'Tus dos perfiles ya están activos';
    return account.isTenant
        ? 'Configura tu perfil de propietario para publicar viviendas'
        : 'Configura tu perfil de inquilino para buscar habitaciones y pisos';
  }

  Future<void> _openTenantProfile() async {
    final account = _account;
    if (account == null || account.hasTenantProfile) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EnableTenantProfileScreen()),
    );
    if (mounted) await _loadAccount();
  }

  Future<void> _openOwnerProfile() async {
    final account = _account;
    if (account == null || account.hasOwnerProfile) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EnableOwnerProfileScreen()),
    );
    if (mounted) await _loadAccount();
  }

  void _onTenantNavigation(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TenantHomeScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: CohabiColors.background,
        body: Center(
          child: CircularProgressIndicator(color: CohabiColors.turquoise),
        ),
      );
    }

    final account = _account;
    if (account == null) {
      return Scaffold(
        backgroundColor: CohabiColors.background,
        body: Center(
          child: TextButton(
            onPressed: _loadAccount,
            child: const Text('Reintentar'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CohabiColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: CohabiColors.turquoise,
          onRefresh: _loadAccount,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            children: [
              const Text(
                'Cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CohabiColors.navy,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 28),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: CohabiColors.textSecondary,
                    fontSize: 20,
                  ),
                  children: [
                    const TextSpan(text: 'Hola, '),
                    TextSpan(
                      text: account.firstName.isEmpty ? 'usuario' : account.firstName,
                      style: const TextStyle(
                        color: CohabiColors.turquoise,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ' 👋'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AccountProfileCard(
                fullName: account.fullName,
                email: account.email,
              ),
              const SizedBox(height: 16),
              ActiveModeCard(
                activeMode: account.activeMode,
                secondaryText: _secondaryModeText(account),
              ),
              const SizedBox(height: 16),
              ChangeModeCard(
                isTenant: account.isTenant,
                description: _changeDescription(account),
                buttonText: _changeButton(account),
                note: _changeNote(account),
                isLoading: _isChangingMode,
                onPressed: _changeMode,
              ),
              const SizedBox(height: 16),
              AccountProfilesCard(
                hasTenantProfile: account.hasTenantProfile,
                hasOwnerProfile: account.hasOwnerProfile,
                onTenantTap: _openTenantProfile,
                onOwnerTap: _openOwnerProfile,
              ),
              const SizedBox(height: 16),
              AccountSettingsCard(onLogout: _confirmLogout),
            ],
          ),
        ),
      ),
      bottomNavigationBar: account.isTenant
          ? CohabiBottomNavigation(
              currentIndex: 4,
              onTap: _onTenantNavigation,
            )
          : null,
    );
  }
}
