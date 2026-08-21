import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase;

  ProfileService([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, dynamic>> getProfile(String userId) async {
    return await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
  }

  Future<bool> hasTenantProfile(String userId) async {
    final row = await _supabase
        .from('tenant_profiles')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();
    return row != null;
  }

  Future<bool> hasOwnerProfile(String userId) async {
    final row = await _supabase
        .from('owner_profiles')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();
    return row != null;
  }
}
