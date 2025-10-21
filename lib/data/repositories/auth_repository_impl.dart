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
    await prefs.setString(_kToken, 'demo-token');
    await prefs.setBool(_kRemember, remember);
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
    await prefs.remove(_kToken);
    await prefs.remove(_kRemember);
  }

  @override
  Future<bool> isLoggedIn() async {
    return prefs.getString(_kToken) != null;
  }
}
