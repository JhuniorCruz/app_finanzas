// Capa Domain
abstract class AuthRepository {
  Future<void> login({
    required String email,
    required String password,
    required bool remember,
  });

  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendResetEmail(String email);

  Future<void> logout();

  /// Devuelve true si hay sesión persistida (token/flag en storage)
  Future<bool> isLoggedIn();
}
