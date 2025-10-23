import 'package:flutter/material.dart';
import 'package:app_finanzas/domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repo;
  bool isLoading = false;
  bool isLoggedIn = false;
  String? error;

  AuthController(this.repo);

  bool get isAuthenticated => isLoggedIn;

  Future<void> checkSession() async {
    try {
      isLoading = true;
      notifyListeners();

      final logged = await repo.isLoggedIn();
      if (!logged) {
        isLoggedIn = false;
        return;
      }

      final remember = await repo.getRememberFlag();

      if (!remember) {
        // Sesión existe (de Supabase) pero el usuario no marcó "Recordarme".
        // Salimos para que al reiniciar no se mantenga logueado.
        await repo.logout();
        isLoggedIn = false;
      } else {
        isLoggedIn = true;
      }
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
      // Si requiere confirmación por correo, aquí no marcamos logged in.
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
      isLoggedIn = false;
      error = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
