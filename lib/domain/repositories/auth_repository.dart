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

  /// Devuelve true si hay una sesión PERSISTIDA (token + remember en storage)
  Future<bool> hasPersistedSession();

  /// Devuelve el flag "recordarme"
  Future<bool> getRememberFlag();

  /// Mantén este helper si ya lo usas en otros lados:
  /// por claridad lo igualamos a `hasPersistedSession()`.
  Future<bool> isLoggedIn() => hasPersistedSession();
}
