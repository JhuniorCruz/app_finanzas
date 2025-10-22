import 'package:flutter/material.dart';
import 'package:app_finanzas/domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repo;

  bool isLoading = false;
  bool isLoggedIn = false; // estado en runtime
  String? error;

  AuthController(this.repo);

  bool get isAuthenticated => isLoggedIn;

  /// Se llama al iniciar la app (desde DI: ..checkSession())
  /// Revisa SOLO la sesión PERSISTIDA (remember + token).
  Future<void> checkSession() async {
    try {
      isLoading = true;
      notifyListeners();
      isLoggedIn = await repo.hasPersistedSession();
      error = null;
    } catch (e) {
      error = e.toString();
      isLoggedIn = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await repo.login(email: email, password: password, remember: remember);

      // Logueado para ESTA ejecución (persistido solo si remember == true).
      isLoggedIn = true;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      await repo.register(name: name, email: email, password: password);
      // decide si loguear auto o volver al login
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      await repo.sendResetEmail(email);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      isLoading = true;
      notifyListeners();
      await repo.logout();
      isLoggedIn = false; // dispara AppRouter → AuthFlow
      error = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
