import 'package:supabase_flutter/supabase_flutter.dart';

class TenantProfileService {
  final SupabaseClient _supabase;

  TenantProfileService([SupabaseClient? client])
      : _supabase = client ?? Supabase.instance.client;

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('No hay una sesión iniciada.');
    return id;
  }

  Future<Map<String, dynamic>> load() async {
    final id = _userId;

    final profile = await _supabase
        .from('profiles')
        .select('id, first_name, last_name, phone')
        .eq('id', id)
        .single();

    final tenant = await _supabase
        .from('tenant_profiles')
        .select()
        .eq('user_id', id)
        .single();

    return {
      'profile': Map<String, dynamic>.from(profile),
      'tenant': Map<String, dynamic>.from(tenant),
    };
  }

  Future<void> update({
    required Map<String, dynamic> profile,
    required Map<String, dynamic> tenant,
  }) async {
    final id = _userId;

    await _supabase.from('profiles').update(profile).eq('id', id);
    await _supabase.from('tenant_profiles').update(tenant).eq('user_id', id);
  }
}
