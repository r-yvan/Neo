import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token + lightweight session persistence.
///
/// Access and refresh tokens live in the platform keystore (Keychain on iOS,
/// EncryptedSharedPreferences on Android) because they are bearer credentials.
/// Non-sensitive preferences — onboarding completion, theme mode — use
/// [SharedPreferences] via [AppPreferences].
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  static const String _kAccess = 'neo_access_token';
  static const String _kRefresh = 'neo_refresh_token';

  /// Cached in memory so the interceptor never awaits disk on the hot path.
  String? _access;
  String? _refresh;

  String? get accessToken => _access;
  String? get refreshToken => _refresh;
  bool get hasSession => (_access?.isNotEmpty ?? false);

  Future<void> read() async {
    _access = await _storage.read(key: _kAccess);
    _refresh = await _storage.read(key: _kRefresh);
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
  }

  Future<void> updateAccess(String accessToken) async {
    _access = accessToken;
    await _storage.write(key: _kAccess, value: accessToken);
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }

  /// Best-effort decode of the JWT payload so the app can react to an expired
  /// token before the first request fails. Returns epoch seconds, or null.
  int? accessExpiry() {
    final String? token = _access;
    if (token == null) return null;
    final List<String> parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final Map<String, dynamic> payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final Object? exp = payload['exp'];
      return exp is int ? exp : null;
    } catch (_) {
      return null;
    }
  }
}