import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _preferencesKey = 'user_preferences_v1';
  final SharedPreferencesAsync _preferences;

  Future<UserPreferences> load() async {
    final source = await _preferences.getString(_preferencesKey);
    if (source == null) return UserPreferences.defaults();
    try {
      return UserPreferences.decode(source);
    } on Object {
      return UserPreferences.defaults();
    }
  }

  Future<void> save(UserPreferences preferences) =>
      _preferences.setString(_preferencesKey, preferences.encode());
}
