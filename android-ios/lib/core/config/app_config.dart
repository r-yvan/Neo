/// Runtime configuration.
///
/// The base URL is supplied at build time so the same binary can point at a
/// local backend, a staging host or production:
///
/// ```sh
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
/// ```
///
/// Defaults are chosen for the Android emulator, which reaches the host
/// machine through `10.0.2.2`. Change it for a physical device (use the LAN IP
/// of the machine running the API) or for the iOS simulator (use `localhost`).
library;

abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  /// Chat is REST + short polling: the backend exposes no websocket gateway.
  static const Duration chatPollInterval = Duration(seconds: 12);

  /// Access tokens live 15 minutes; refresh a little before that.
  static const Duration tokenRefreshLeeway = Duration(minutes: 1);

  /// How long an in-memory cache stays warm before a refetch is forced.
  static const Duration cacheTtl = Duration(minutes: 5);

  static const int pageSize = 20;
}