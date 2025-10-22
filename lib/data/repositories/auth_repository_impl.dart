import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_finanzas/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _kToken = 'auth_token';
  static const _kRemember = 'auth_remember';

  final SharedPreferences prefs;
  AuthRepositoryImpl(this.prefs);

  @override
  Future<void> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    // Aquí iría tu llamada a API. De momento, simulamos éxito.
    await Future.delayed(const Duration(milliseconds: 300));

    if (remember) {
      await prefs.setBool(_kRemember, true);
      await prefs.setString(
        _kToken,
        'local_${DateTime.now().millisecondsSinceEpoch}', // token ficticio
      );
    } else {
      // Sesión NO persistida: no guardes token (ni remember)
      await prefs.setBool(_kRemember, false);
      await prefs.remove(_kToken);
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulación de registro
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> sendResetEmail(String email) async {
    // Simulación de envío de email
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> logout() async {
    await prefs.setBool(_kRemember, false);
    await prefs.remove(_kToken);
  }

  @override
  Future<bool> hasPersistedSession() async {
    final remembered = prefs.getBool(_kRemember) ?? false;
    final token = prefs.getString(_kToken);
    return remembered && token != null && token.isNotEmpty;
  }

  @override
  Future<bool> getRememberFlag() async {
    return prefs.getBool(_kRemember) ?? false;
  }

  // Alias para compatibilidad con tu interface actual
  @override
  Future<bool> isLoggedIn() => hasPersistedSession();
}
