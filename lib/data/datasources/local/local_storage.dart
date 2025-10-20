import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  LocalStorage(this._prefs);

  String? readRaw() => _prefs.getString(StorageKeys.appState);

  Future<void> writeRaw(String json) async {
    await _prefs.setString(StorageKeys.appState, json);
  }
}
