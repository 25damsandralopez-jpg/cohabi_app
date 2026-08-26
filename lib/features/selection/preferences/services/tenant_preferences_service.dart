import 'package:supabase_flutter/supabase_flutter.dart';

class TenantPreferencesService {
  final SupabaseClient _supabase;

  TenantPreferencesService([SupabaseClient? client])
      : _supabase = client ?? Supabase.instance.client;

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('No hay una sesión iniciada.');
    return id;
  }

  Future<Map<String, dynamic>> load() async {
    final tenant = await _supabase
        .from('tenant_profiles')
        .select()
        .eq('user_id', _userId)
        .single();

    var selection = await _supabase
        .from('tenant_selection_profiles')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();

    selection ??= await _supabase
        .from('tenant_selection_profiles')
        .insert({'user_id': _userId})
        .select()
        .single();

    return {
      'tenant': Map<String, dynamic>.from(tenant),
      'selection': Map<String, dynamic>.from(selection),
    };
  }

  Future<void> save({
    required Map<String, dynamic> tenant,
    required Map<String, dynamic> selection,
  }) async {
    await _supabase
        .from('tenant_profiles')
        .update(tenant)
        .eq('user_id', _userId);

    // No tocamos completed/current_step: editar preferencias no debe reiniciar
    // Cohabi Selección ni marcar el perfil como incompleto.
    await _supabase
        .from('tenant_selection_profiles')
        .update(selection)
        .eq('user_id', _userId);
  }
}
