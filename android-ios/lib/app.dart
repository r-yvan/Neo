import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_locale.dart';
import 'core/l10n/material_fallback.dart';
import 'core/l10n/strings.dart';
import 'core/theme/app_theme.dart';
import 'data/providers.dart';
import 'features/shell/app_router.dart';

class NeoApp extends ConsumerStatefulWidget {
  const NeoApp({super.key});

  @override
  ConsumerState<NeoApp> createState() => _NeoAppState();
}

class _NeoAppState extends ConsumerState<NeoApp> {
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter(ref);
    // Validate the stored session and pick the first screen once the first
    // frame is on-screen, so the splash does not flash.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SessionState>(sessionProvider,
        (SessionState? _, SessionState __) => _router.sessionChanged());
    final ThemeMode mode = ref.watch(themeModeProvider);
    final AppLocaleChoice language = ref.watch(languageProvider);
    return MaterialApp.router(
      title: L10n.i.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      locale: AppLocaleChoice.materialLocale(language),
      supportedLocales: AppLocaleChoice.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        RwMaterialLocalizationsDelegate(),
        RwCupertinoLocalizationsDelegate(),
      ],
      routerConfig: _router.config,
      builder: (BuildContext context, Widget? child) {
        // Clamp text scaling so the dense marketplace cards stay legible.
        final MediaQueryData mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.3,
            ),
          ),
          // Tapping outside a text field dismisses the keyboard everywhere.
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
