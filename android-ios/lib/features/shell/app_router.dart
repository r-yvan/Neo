import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../auth/login_page.dart';
import '../onboarding/onboarding_page.dart';
import '../profile/profile_page.dart';
import '../shell/root_shell.dart';
import '../splash/splash_page.dart';

/// Declarative routing driven by [SessionStage].
///
/// Session changes `redirect` instead of pushing history, so signing out can
/// never leave a private screen on the stack.
class AppRouter {
  AppRouter(this._ref) {
    _refresh = _SessionRefresh(_ref);
  }

  final Ref _ref;
  late final _SessionRefresh _refresh;

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    refreshListenable: _refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final SessionState session = _ref.read(sessionProvider);
      final String location = state.matchedLocation;
      final bool atRoot = location == '/';

      switch (session.stage) {
        case SessionStage.loading:
          return atRoot ? null : '/';
        case SessionStage.onboarding:
          return location == '/onboarding' ? null : '/onboarding';
        case SessionStage.signedOut:
          return location == '/login' ? null : '/login';
        case SessionStage.signedIn:
        case SessionStage.restricted:
          return atRoot ? '/home' : null;
      }
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage<void>(child: OnboardingPage()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const NoTransitionPage<void>(child: LoginPage()),
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) => const RootShell(),
        routes: <RouteBase>[
          GoRoute(
            path: 'profile',
            builder: (BuildContext context, GoRouterState state) =>
                const ProfilePage(),
          ),
        ],
      ),
    ],
  );

  GoRouter get config => _router;
}

class _SessionRefresh extends ChangeNotifier {
  _SessionRefresh(Ref ref) {
    ref.listen<SessionState>(sessionProvider, (SessionState? _, SessionState __) {
      notifyListeners();
    });
  }
}