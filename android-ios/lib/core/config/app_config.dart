/// Runtime configuration.
///
/// The API base URL can be supplied at build time so the same code can point
/// at a local backend, a staging host or production:
///
/// ```sh
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.97:3000/api/v1
/// ```
///
/// When no override is given a sensible per-platform default is used:
///  * Web (Chrome)        → `http://localhost:3000/api/v1`
///  * Android emulator    → `http://10.0.2.2:3000/api/v1` (host loopback)
///  * iOS simulator/other → `http://localhost:3000/api/v1`
///
/// A **physical device** cannot reach `localhost`/`10.0.2.2`; always pass the
/// LAN IP of the machine running the API with `--dart-define` (see
/// `starter-cmds.md` at the repository root).
library;

import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return 'http://localhost:3000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }

  /// Origin of the API (no `/api/v1`), used to resolve relative upload URLs.
  static String get apiOrigin {
    final Uri uri = Uri.parse(apiBaseUrl);
    return uri.replace(path: '', query: null).toString().replaceAll(RegExp(r'/$'), '');
  }

  /// Chat is REST + short polling: the backend exposes no websocket gateway.
  static const Duration chatPollInterval = Duration(seconds: 12);

  /// How often the shell refreshes unread badges (chat + notifications).
  static const Duration badgePollInterval = Duration(seconds: 30);

  /// Access tokens live 15 minutes; refresh a little before that.
  static const Duration tokenRefreshLeeway = Duration(minutes: 1);

  /// How long an in-memory cache stays warm before a refetch is forced.
  static const Duration cacheTtl = Duration(minutes: 5);

  static const int pageSize = 20;

  /// Kigali city centre — fallback origin for the "Near you" rail when the
  /// device location is unknown.
  static const double defaultLatitude = -1.9441;
  static const double defaultLongitude = 30.0619;
}
