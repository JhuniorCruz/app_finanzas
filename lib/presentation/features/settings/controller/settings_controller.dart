// lib/presentation/features/settings/controller/settings_controller.dart
import 'package:flutter/foundation.dart';

import '../../../../domain/entities/user_profile.dart';
import 'package:app_finanzas/core/utils/scoring.dart'; // Thresholds / defaultThresholds

/// Recibe dos funciones:
///  - _getProfile(): Future<UserProfile?>
///  - _saveProfile(UserProfile): Future<void>
class SettingsController extends ChangeNotifier {
  final Future<UserProfile?> Function() _getProfile;
  final Future<void> Function(UserProfile) _saveProfile;

  SettingsController(this._getProfile, this._saveProfile);

  UserProfile? _profile;
  bool _busy = false;

  UserProfile? get profile => _profile;
  bool get busy => _busy;

  /// Devuelve los umbrales que usa el Score. Si aún no hay perfil,
  /// usa los valores por defecto del perfil inicial para mantener
  /// consistencia con la UI de Ajustes.
  Thresholds get thresholds {
    final p = _profile ?? UserProfile.initial();
    return Thresholds(
      savingsTarget: p.savingsTarget,
      debtToIncomeWarning: p.debtToIncomeThreshold,
      utilizationWarning: p.utilizationThreshold,
    );
  }

  Future<void> load() async {
    _busy = true;
    notifyListeners();
    try {
      _profile = await _getProfile();
    } catch (_) {
      // Puede fallar si aún no hay sesión; el llamador puede reintentar.
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Actualiza y persiste el perfil completo.
  Future<void> updateProfile(UserProfile newProfile) async {
    _busy = true;
    notifyListeners();
    try {
      await _saveProfile(newProfile);
      _profile = newProfile;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Limpia el perfil cargado (por ejemplo, al cerrar sesión).
  void reset() {
    if (_profile != null) {
      _profile = null;
      notifyListeners();
    }
  }
}
