// lib/domain/repositories/auth_repository.dart

/// Contrato de autenticación usado por el Controller/DI.
/// Lo mantenemos igual para no romper nada arriba.
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

  /// Devuelve true si hay una sesión válida **y** el usuario eligió "recordarme".
  Future<bool> isLoggedIn();

  /// Devuelve true si Supabase tiene una sesión en el storage (independiente del flag remember).
  Future<bool> hasPersistedSession();

  /// Lee el flag "recordarme".
  Future<bool> getRememberFlag();
}
