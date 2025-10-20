import 'package:flutter/foundation.dart';
import '../../../../application/usecases/get_profile.dart';
import '../../../../application/usecases/update_profile.dart';
import '../../../../domain/entities/user_profile.dart';

class SettingsController extends ChangeNotifier {
  final GetProfile _get;
  final UpdateProfile _update;

  SettingsController(this._get, this._update);

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _profile = await _get();
    _loading = false;
    notifyListeners();
  }

  Future<void> save(UserProfile p) async {
    _loading = true;
    notifyListeners();
    await _update(p);
    _profile = p;
    _loading = false;
    notifyListeners();
  }
}
