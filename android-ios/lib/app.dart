import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final ThemeMode mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Neo — Event Equipment Rental',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
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
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}