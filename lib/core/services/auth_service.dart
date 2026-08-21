import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
    String emailRedirectTo = 'cohabi://login-callback/',
  }) {
    return _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: emailRedirectTo,
      data: data,
    );
  }

  Future<void> signOut() => _supabase.auth.signOut();
}
