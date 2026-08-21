import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tenant_selection_profile.dart';

class TenantSelectionService {
  final SupabaseClient _supabase;

  TenantSelectionService([SupabaseClient? client])
      : _supabase = client ?? Supabase.instance.client;

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('No hay una sesión iniciada.');
    return id;
  }

  Future<TenantSelectionProfile> getOrCreate() async {
    final id = _userId;
    final existing = await _supabase
        .from('tenant_selection_profiles')
        .select()
        .eq('user_id', id)
        .maybeSingle();

    if (existing != null) {
      return TenantSelectionProfile.fromMap(existing);
    }

    final created = await _supabase
        .from('tenant_selection_profiles')
        .insert({'user_id': id})
        .select()
        .single();

    return TenantSelectionProfile.fromMap(created);
  }

  Future<void> saveStep(int step, Map<String, dynamic> values) async {
    final nextStep = step >= 8 ? 8 : step + 1;
    await _supabase.from('tenant_selection_profiles').update({
      ...values,
      'current_step': nextStep,
    }).eq('user_id', _userId);
  }

  Future<void> complete(Map<String, dynamic> values) async {
    await _supabase.from('tenant_selection_profiles').update({
      ...values,
      'current_step': 8,
      'completed': true,
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('user_id', _userId);
  }

  Future<void> restart() async {
    await _supabase.from('tenant_selection_profiles').update({
      'current_step': 1,
      'completed': false,
      'completed_at': null,
    }).eq('user_id', _userId);
  }
}
