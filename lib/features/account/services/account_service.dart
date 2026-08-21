import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/account_state.dart';

class AccountService {
  final SupabaseClient _supabase;

  AccountService([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  Future<AccountStateData> loadCurrentAccount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError('No hay una sesión iniciada.');
    }

    final results = await Future.wait<dynamic>([
      _supabase
          .from('profiles')
          .select('first_name, last_name, active_mode')
          .eq('id', user.id)
          .single(),
      _supabase
          .from('tenant_profiles')
          .select('user_id')
          .eq('user_id', user.id)
          .maybeSingle(),
      _supabase
          .from('owner_profiles')
          .select('user_id')
          .eq('user_id', user.id)
          .maybeSingle(),
    ]);

    final profile = results[0] as Map<String, dynamic>;

    return AccountStateData(
      userId: user.id,
      firstName: profile['first_name']?.toString() ?? '',
      lastName: profile['last_name']?.toString() ?? '',
      email: user.email ?? '',
      activeMode: profile['active_mode']?.toString() ?? 'tenant',
      hasTenantProfile: results[1] != null,
      hasOwnerProfile: results[2] != null,
    );
  }

  Future<void> switchMode(String targetMode) async {
    if (targetMode != 'tenant' && targetMode != 'owner') {
      throw ArgumentError.value(targetMode, 'targetMode', 'Modo no válido');
    }

    await _supabase.rpc(
      'switch_active_mode',
      params: {'target_mode': targetMode},
    );
  }

  Future<void> enableOwnerProfile(Map<String, dynamic> profileData) {
    return _supabase.rpc(
      'enable_owner_profile',
      params: {'profile_data': profileData},
    );
  }

  Future<void> enableTenantProfile(Map<String, dynamic> profileData) {
    return _supabase.rpc(
      'enable_tenant_profile',
      params: {'profile_data': profileData},
    );
  }
}
