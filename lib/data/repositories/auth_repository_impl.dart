// lib/data/repositories/auth_repository_impl.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_finanzas/domain/repositories/auth_repository.dart';

/// Implementación integrada con Supabase.
/// - Usa Supabase para auth y refresh de sesiones.
/// - Usa SharedPreferences solo para el flag "recordarme".
class AuthRepositoryImpl implements AuthRepository {
  static const _kRemember = 'auth_remember';
  static const _kRedirectUri = 'appfinanzas://auth-callback';

  final SharedPreferences prefs;
  final SupabaseClient _client;

  AuthRepositoryImpl(this.prefs) : _client = Supabase.instance.client;

  @override
  Future<void> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    // Sign-in con email/password (si confirm email está activo, puede fallar si no está verificado).
    await _client.auth.signInWithPassword(email: email, password: password);

    // Guardamos el flag "recordarme".
    await prefs.setBool(_kRemember, remember);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Sign-up con metadata y deep-link para verificación (si está activo).
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
      emailRedirectTo: _kRedirectUri,
    );

    // Nota: NO seteamos remember aquí. Se hará en el login real.
  }

  @override
  Future<void> sendResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email, redirectTo: _kRedirectUri);
  }

  @override
  Future<void> logout() async {
    // Limpia sesión y flag local.
    await _client.auth.signOut();
    await prefs.remove(_kRemember);
  }

  @override
  Future<bool> isLoggedIn() async {
    final session = _client.auth.currentSession;
    if (session == null) return false;

    // Si el usuario NO marcó "recordarme", consideramos que después de un cold start
    // no debe permanecer logueado. Para reforzarlo, limpiamos la sesión almacenada.
    final remember = prefs.getBool(_kRemember) ?? false;
    if (!remember) {
      try {
        await _client.auth.signOut(); // limpia secure storage/refresh token
      } catch (_) {}
      return false;
    }

    return true;
  }

  @override
  Future<bool> hasPersistedSession() async {
    // Chequea si Supabase tiene una sesión (independiente de "recordarme").
    return _client.auth.currentSession != null;
  }

  @override
  Future<bool> getRememberFlag() async {
    return prefs.getBool(_kRemember) ?? false;
  }
}
