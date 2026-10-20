import 'dart:ui' show Locale, PlatformDispatcher;

/// Language choices available in the app.
///
/// [system] resolves to the device locale at startup (Kinyarwanda when the
/// device is set to `rw`, English otherwise) and keeps tracking platform
/// locale changes while it is active.
enum AppLocaleChoice {
  system,
  english,
  kinyarwanda;

  /// `[AppPreferences]` storage index / provider state value.
  int get storageIndex => switch (this) {
        system => 0,
        english => 1,
        kinyarwanda => 2,
      };

  static AppLocaleChoice fromStorageIndex(int index) => switch (index) {
        1 => english,
        2 => kinyarwanda,
        _ => system,
      };

  /// Language for the resolved choice — `system` collapses to the device
  /// language first.
  static String code(AppLocaleChoice choice) => switch (choice) {
        english => 'en',
        kinyarwanda => 'rw',
        system => PlatformDispatcher.instance.locales
                .any((Locale l) => l.languageCode == 'rw')
            ? 'rw'
            : 'en',
      };

  /// For `MaterialApp.locale` — null lets the platform locale drive
  /// resolution.
  static Locale? materialLocale(AppLocaleChoice choice) => switch (choice) {
        system => null,
        english => const Locale('en'),
        kinyarwanda => const Locale('rw'),
      };

  static List<Locale> get supportedLocales => const <Locale>[
        Locale('en'),
        Locale('rw'),
      ];
}
