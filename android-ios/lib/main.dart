import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/token_store.dart';
import 'data/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait: booking, payment and chat flows are single-column, and
  // the owner dashboard tables do not reflow usefully in landscape.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  final AppPreferences preferences = await AppPreferences.load();
  final TokenStore tokens = TokenStore();
  await tokens.read();

  runApp(
    ProviderScope(
      overrides: <Override>[
        appPreferencesProvider.overrideWithValue(preferences),
        tokenStoreProvider.overrideWithValue(tokens),
      ],
      child: const NeoApp(),
    ),
  );
}