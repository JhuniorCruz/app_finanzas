import 'package:flutter/foundation.dart';
import '../../../../domain/entities/user_profile.dart';

/// Recibe dos funciones:
///  - _getProfile(): Future<UserProfile?>
///  - _saveProfile(UserProfile): Future<void>
class SettingsController extends ChangeNotifier {
  final Future<UserProfile?> Function() _getProfile;
  final Future<void> Function(UserProfile) _saveProfile;

  SettingsController(this._getProfile, this._saveProfile) {
    load();
  }

  UserProfile? _profile;
  bool _busy = false;

  UserProfile? get profile => _profile;
  bool get busy => _busy;

  Future<void> load() async {
    _busy = true;
    notifyListeners();
    try {
      _profile = await _getProfile();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// <-- Este es el método que reclama tu SettingsPage
  Future<void> updateProfile(UserProfile newProfile) async {
    _busy = true;
    notifyListeners();
    try {
      await _saveProfile(newProfile); // persiste usando la función inyectada
      _profile = newProfile; // actualiza el estado en memoria
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
