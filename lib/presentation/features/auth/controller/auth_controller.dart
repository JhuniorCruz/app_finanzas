// lib/presentation/features/auth/controller/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:app_finanzas/domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repo;
  bool isLoading = false;
  bool isLoggedIn = false;
  String? error;

  AuthController(this.repo);

  /// Útil si tu router usa este nombre
  bool get isAuthenticated => isLoggedIn;

  /// Restaura sesión al iniciar la app (prefs / token / etc.)
  Future<void> checkSession() async {
    try {
      isLoading = true;
      notifyListeners();
      isLoggedIn = await repo.isLoggedIn();
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
      isLoggedIn = false; // <- clave: dispara AppRouter → AuthFlow
      error = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /*
  Future<void> logout() async {
    await repo.logout();
    isLoggedIn = false;
    notifyListeners();
  }
  */
}
