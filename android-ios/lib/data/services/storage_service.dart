import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/config/app_config.dart';
import '../../core/errors/exceptions.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late Box _authBox;
  late Box _userBox;
  late Box _settingsBox;

  Future<void> init() async {
    _authBox = await Hive.openBox('authBox');
    _userBox = await Hive.openBox('userBox');
    _settingsBox = await Hive.openBox('settingsBox');
  }

  // Auth Token Storage
  Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: AppConfig.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConfig.accessTokenKey);
  }

  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: AppConfig.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConfig.refreshTokenKey);
  }

  Future<void> setUserId(String userId) async {
    await _secureStorage.write(key: AppConfig.userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: AppConfig.userIdKey);
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
    await _secureStorage.delete(key: AppConfig.userIdKey);
    await _authBox.clear();
  }

  // User Data Storage
  Future<void> setUserProfile(Map<String, dynamic> profile) async {
    await _userBox.put(AppConfig.userProfileKey, profile);
  }

  Map<String, dynamic>? getUserProfile() {
    return _userBox.get(AppConfig.userProfileKey);
  }

  Future<void> clearUserProfile() async {
    await _userBox.delete(AppConfig.userProfileKey);
  }

  // Settings Storage
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  Future<void> clearSettings() async {
    await _settingsBox.clear();
  }

  // Cache Storage
  Future<void> setCache(String key, dynamic value) async {
    await _authBox.put(key, value);
  }

  dynamic getCache(String key) {
    return _authBox.get(key);
  }

  Future<void> clearCache() async {
    await _authBox.clear();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    final token = _secureStorage.read(key: AppConfig.accessTokenKey);
    return token != null;
  }

  // Clear all data
  Future<void> clearAll() async {
    await clearAuthData();
    await clearUserProfile();
    await clearSettings();
    await clearCache();
  }
}
