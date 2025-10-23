// lib/data/repositories/supabase_auth_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_finanzas/domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  static const _kRemember = 'auth_remember';
  // Usa el mismo esquema/host que configuraste en AndroidManifest/Info.plist
  static const _kRedirectUri = 'appfinanzas://auth-callback';

  final SharedPreferences prefs;
  SupabaseAuthRepository(this.prefs);

  AuthResponse _ensureOk(AuthResponse res) {
    // Si tu proyecto exige verificación de email, res.session puede venir null.
    // Aquí no lanzamos error automáticamente.
    return res;
  }

  @override
  Future<void> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _ensureOk(res);
      await prefs.setBool(_kRemember, remember);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('No se pudo iniciar sesión. Intenta nuevamente.');
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        // mejor usar "full_name" como clave común de metadata
        data: {'full_name': name},
        emailRedirectTo: _kRedirectUri, // ← importante para deep-link
      );
      // Si tu proyecto exige verificación por email, no habrá sesión aún.
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('No se pudo crear la cuenta. Intenta nuevamente.');
    }
  }

  @override
  Future<void> sendResetEmail(String email) async {
    try {
      // Redirect para que el enlace de recuperación vuelva a la app
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: _kRedirectUri,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('No se pudo enviar el correo de recuperación.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } finally {
      await prefs.remove(_kRemember);
    }
  }

  /// “¿Hay sesión viva en memoria o restaurada por Supabase?”
  @override
  Future<bool> isLoggedIn() async {
    return Supabase.instance.client.auth.currentSession != null;
  }

  /// “¿Debo mantener logueado al usuario al arrancar?”
  /// Requiere sesión *y* remember=true.
  @override
  Future<bool> hasPersistedSession() async {
    final hasSession = Supabase.instance.client.auth.currentSession != null;
    final remember = prefs.getBool(_kRemember) ?? false;
    return hasSession && remember;
  }

  @override
  Future<bool> getRememberFlag() async {
    return prefs.getBool(_kRemember) ?? false;
  }
}
