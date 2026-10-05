import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive app preferences.
class AppPreferences {
  AppPreferences._(this._prefs);

  static const String _kOnboarded = 'neo_onboarded';
  static const String _kThemeMode = 'neo_theme_mode';
  static const String _kLastPhone = 'neo_last_phone';
  static const String _kCachePrefix = 'neo_cache_';

  final SharedPreferences _prefs;

  static Future<AppPreferences> load() async =>
      AppPreferences._(await SharedPreferences.getInstance());

  bool get hasSeenOnboarding => _prefs.getBool(_kOnboarded) ?? false;

  Future<void> markOnboarded() => _prefs.setBool(_kOnboarded, true);

  Future<void> resetOnboarding() => _prefs.remove(_kOnboarded);

  /// 0 = system, 1 = light, 2 = dark.
  int get themeModeIndex => _prefs.getInt(_kThemeMode) ?? 0;

  Future<void> setThemeModeIndex(int value) =>
      _prefs.setInt(_kThemeMode, value);

  String? get lastPhone => _prefs.getString(_kLastPhone);

  Future<void> setLastPhone(String phone) =>
      _prefs.setString(_kLastPhone, phone);

  /// Small JSON mirror of the last successful page of each list endpoint, so
  /// the app can paint something useful the instant it cold-starts offline.
  Future<void> writeCache(String key, Object? payload) {
    if (payload == null) return Future<void>.value();
    try {
      return _prefs.setString('$_kCachePrefix$key', jsonEncode(payload));
    } catch (_) {
      return Future<void>.value();
    }
  }

  Object? readCache(String key) {
    final String? raw = _prefs.getString('$_kCachePrefix$key');
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache(String key) => _prefs.remove('$_kCachePrefix$key');

  Future<void> clearAllCaches() async {
    for (final String k in _prefs.getKeys().toList()) {
      if (k.startsWith(_kCachePrefix)) await _prefs.remove(k);
    }
  }
}