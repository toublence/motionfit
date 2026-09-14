import 'dart:async';

import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  Future<void> _telemetryWrite = Future.value();

  /// Separate from user settings so concurrent settings writes cannot erase
  /// retention deduplication. Keys represent milestones or workout dates.
  Future<bool> claimRetentionEvent(String key) async {
    final previous = _telemetryWrite;
    final released = Completer<void>();
    _telemetryWrite = released.future;
    await previous;
    try {
      final keys =
          await _preferences.getStringList('retention_revision_3') ?? [];
      if (keys.contains(key)) return false;
      await _preferences.setStringList('retention_revision_3', [...keys, key]);
      return true;
    } finally {
      released.complete();
    }
  }

  static const _preferencesKey = 'user_preferences_v1';
  final SharedPreferencesAsync _preferences;

  Future<bool> hasSavedPreferences() async =>
      await _preferences.getString(_preferencesKey) != null;

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
