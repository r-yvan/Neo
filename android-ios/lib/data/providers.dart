/// Root provider graph.
///
/// Wiring is deliberately manual rather than code-generated: there are only a
/// dozen providers, and keeping them explicit means the dependency direction
/// (UI → repositories → [ApiClient]) is readable at a glance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/app_preferences.dart';
import '../core/storage/token_store.dart';
import 'models/models.dart';
import 'repositories/auth_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/equipment_repository.dart';
import 'repositories/social_repository.dart';
import 'repositories/users_repository.dart';

// ------------------------------------------------------------------ storage

final Provider<AppPreferences> appPreferencesProvider =
    Provider<AppPreferences>((Ref ref) => throw UnimplementedError(
        'appPreferencesProvider must be overridden in main()'));

final Provider<TokenStore> tokenStoreProvider =
    Provider<TokenStore>((Ref ref) => throw UnimplementedError(
        'tokenStoreProvider must be overridden in main()'));

// ----------------------------------------------------------------- networking

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((Ref ref) {
  final ApiClient client =
      ApiClient(tokens: ref.watch(tokenStoreProvider));
  return client;
});

// -------------------------------------------------------------- repositories

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) {
  final ApiClient c = ref.watch(apiClientProvider);
  return AuthRepository(
    (String path, {Object? body, bool skipAuth = false}) =>
        c.post(path, body: body, skipAuth: skipAuth),
    (String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
        c.get(path, query: query, skipAuth: skipAuth),
  );
});

final Provider<UsersRepository> usersRepositoryProvider =
    Provider<UsersRepository>((Ref ref) {
  final ApiClient c = ref.watch(apiClientProvider);
  return UsersRepository(
    (String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
        c.get(path, query: query, skipAuth: skipAuth),
    (String path, {Object? body}) => c.post(path, body: body),
    (String path, {Object? body}) => c.patch(path, body: body),
    (String path, {Object? body}) => c.delete(path, body: body),
  );
});

final Provider<EquipmentRepository> equipmentRepositoryProvider =
    Provider<EquipmentRepository>((Ref ref) {
  final ApiClient c = ref.watch(apiClientProvider);
  return EquipmentRepository(
    (String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
        c.get(path, query: query, skipAuth: skipAuth),
    (String path, {Object? body}) => c.post(path, body: body),
    (String path, {Object? body}) => c.patch(path, body: body),
    (String path, {Object? body}) => c.put(path, body: body),
    (String path, {Object? body}) => c.delete(path, body: body),
  );
});

final Provider<BookingRepository> bookingRepositoryProvider =
    Provider<BookingRepository>((Ref ref) {
  final ApiClient c = ref.watch(apiClientProvider);
  return BookingRepository(
    (String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
        c.get(path, query: query, skipAuth: skipAuth),
    (String path, {Object? body}) => c.post(path, body: body),
    (String path, {Object? body}) => c.patch(path, body: body),
  );
});

final Provider<PaymentsRepository> paymentsRepositoryProvider =
    Provider<PaymentsRepository>((Ref ref) {
  final ApiClient c = ref.watch(apiClientProvider);
  return PaymentsRepository(
    (String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
        c.get(path, query: query, skipAuth: skipAuth),
    (String path, {Object? body}) => c.post(path, body: body),
  );
});

final Provider<ReviewsRepository> reviewsRepositoryProvider =
    Provider<ReviewsRepository>((Ref ref) {
  final ApiClient c = ref.watch(apiClientProvider);
  return ReviewsRepository(
    (String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
        c.get(path, query: query, skipAuth: skipAuth),
    (String path, {Object? body}) => c.post(path, body: body),
    (String path, {Object? body}) => c.patch(path, body: body),
    (String path, {Object? body}) => c.delete(path, body: body),
  );
});

final Provider<FavoritesRepository> favoritesRepositoryProvider =
    Provider<FavoritesRepository>((Ref ref) {
  final ApiClient c = ref.watch(apiClientProvider);
  return FavoritesRepository(
    (String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
        c.get(path, query: query, skipAuth: skipAuth),
    (String path, {Object? body}) => c.post(path, body: body),
    (String path, {Object? body}) => c.delete(path, body: body),
  );
});

final Provider<ChatRepository> chatRepositoryProvider =
    Provider<ChatRepository>((Ref ref) {
  final ApiClient c = ref.watch(apiClientProvider);
  return ChatRepository(
    (String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
        c.get(path, query: query, skipAuth: skipAuth),
    (String path, {Object? body}) => c.post(path, body: body),
    (String path, {Object? body}) => c.patch(path, body: body),
    (String path, {Object? body}) => c.delete(path, body: body),
  );
});

final Provider<NotificationsRepository> notificationsRepositoryProvider =
    Provider<NotificationsRepository>((Ref ref) {
  final ApiClient c = ref.watch(apiClientProvider);
  return NotificationsRepository(
    (String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
        c.get(path, query: query, skipAuth: skipAuth),
    (String path, {Object? body}) => c.post(path, body: body),
    (String path, {Object? body}) => c.patch(path, body: body),
    (String path, {Object? body}) => c.delete(path, body: body),
  );
});

final Provider<TrustRepository> trustRepositoryProvider =
    Provider<TrustRepository>((Ref ref) {
  final ApiClient c = ref.watch(apiClientProvider);
  return TrustRepository(
    (String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
        c.get(path, query: query, skipAuth: skipAuth),
    (String path, {Object? body}) => c.post(path, body: body),
    (String path, {Object? body}) => c.patch(path, body: body),
  );
});

final Provider<SystemRepository> systemRepositoryProvider =
    Provider<SystemRepository>((Ref ref) {
  final ApiClient c = ref.watch(apiClientProvider);
  return SystemRepository(
    (String path, {Map<String, dynamic>? query, bool skipAuth = false}) =>
        c.get(path, query: query, skipAuth: skipAuth),
  );
});

// ------------------------------------------------------------------- session

/// Where the app should be right now. The router reads this to decide between
/// the auth flow and the main shell.
enum SessionStage {
  loading,
  onboarding,
  signedOut,
  signedIn,
  /// Signed in, but the account has neither RENTER nor OWNER and no OWNER role
  /// has been granted yet — impossible today, kept for future paywalls.
  restricted,
}

class SessionState {
  const SessionState({
    required this.stage,
    this.user,
    this.busy = false,
    this.error,
  });

  const SessionState.loading() : this(stage: SessionStage.loading);

  final SessionStage stage;
  final AppUser? user;
  final bool busy;
  final String? error;

  bool get isSignedIn => stage == SessionStage.signedIn && user != null;

  SessionState copyWith({
    SessionStage? stage,
    AppUser? user,
    bool? busy,
    String? error,
    bool clearError = false,
  }) =>
      SessionState(
        stage: stage ?? this.stage,
        user: user ?? this.user,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
      );
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    // When the API reports an unrecoverable 401 the client calls back here.
    ref.read(apiClientProvider).onSessionExpired = _handleExpiry;
    return const SessionState.loading();
  }

  Future<void> bootstrap() async {
    await ref.read(tokenStoreProvider).read();
    final AppPreferences prefs = ref.read(appPreferencesProvider);

    if (!prefs.hasSeenOnboarding) {
      state = const SessionState(stage: SessionStage.onboarding);
      return;
    }
    if (!ref.read(tokenStoreProvider).hasSession) {
      state = const SessionState(stage: SessionStage.signedOut);
      return;
    }

    // Validate the stored session before trusting it.
    try {
      final AppUser user = await ref.read(authRepositoryProvider).me();
      state = SessionState(stage: SessionStage.signedIn, user: user);
    } catch (_) {
      await ref.read(tokenStoreProvider).clear();
      state = const SessionState(stage: SessionStage.signedOut);
    }
  }

  Future<void> completeOnboarding() async {
    await ref.read(appPreferencesProvider).markOnboarded();
    final bool hasSession = ref.read(tokenStoreProvider).hasSession;
    state = SessionState(
      stage: hasSession ? SessionStage.signedIn : SessionStage.signedOut,
    );
    if (hasSession) await refreshUser();
  }

  Future<void> _persist(AuthSession session) async {
    await ref.read(tokenStoreProvider).save(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
    await ref.read(appPreferencesProvider).setLastPhone(session.user.phone);
    state = SessionState(stage: SessionStage.signedIn, user: session.user);
  }

  Future<void> register({
    required String phone,
    required String fullName,
    String? nationalId,
    String? email,
    String? password,
  }) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final AuthSession session = await ref.read(authRepositoryProvider).register(
            phone: phone,
            fullName: fullName,
            nationalId: nationalId,
            email: email,
            password: password,
          );
      await _persist(session);
    } catch (error, stack) {
      state = SessionState(
        stage: SessionStage.signedOut,
        error: '$error',
      );
      Error.throwWithStackTrace(error, stack);
    }
  }

  Future<void> signIn({required String phone, required String password}) async {
    state = state.copyWith(busy: true, clearError: true);
    final AuthSession session =
        await ref.read(authRepositoryProvider).loginWithPassword(
              phone: phone,
              password: password,
            );
    await _persist(session);
    state = state.copyWith(busy: false);
  }

  Future<void> signInWithOtp({
    required String phone,
    required String otp,
  }) async {
    state = state.copyWith(busy: true, clearError: true);
    final AuthSession session =
        await ref.read(authRepositoryProvider).loginWithOtp(
              phone: phone,
              otp: otp,
            );
    await _persist(session);
    state = state.copyWith(busy: false);
  }

  Future<OtpDispatch> sendOtp(String phone) =>
      ref.read(authRepositoryProvider).sendOtp(phone);

  Future<void> verifyOtp({required String phone, required String otp}) async {
    final AuthSession session = await ref.read(authRepositoryProvider).verifyOtp(
          phone: phone,
          otp: otp,
        );
    await _persist(session);
  }

  Future<void> refreshUser() async {
    final AppUser? current = state.user;
    if (current == null) return;
    try {
      final AppUser fresh = await ref.read(authRepositoryProvider).me();
      state = SessionState(stage: SessionStage.signedIn, user: fresh);
    } catch (_) {
      // Keep the cached snapshot; the next request will surface the error.
    }
  }

  void applyUser(AppUser user) {
    state = SessionState(stage: SessionStage.signedIn, user: user);
  }

  Future<void> signOut() async {
    final String? refresh = ref.read(tokenStoreProvider).refreshToken;
    if (refresh != null) {
      try {
        await ref.read(authRepositoryProvider).logout(refresh);
      } catch (_) {
        // Revoking server-side is best-effort; the local session still goes.
      }
    }
    await ref.read(tokenStoreProvider).clear();
    await ref.read(appPreferencesProvider).clearAllCaches();
    state = const SessionState(stage: SessionStage.signedOut);
  }

  Future<void> _handleExpiry() async {
    if (state.stage == SessionStage.signedOut) return;
    state = const SessionState(
      stage: SessionStage.signedOut,
      error: 'Your session expired. Please sign in again.',
    );
  }
}

final NotifierProvider<SessionNotifier, SessionState> sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

// ----------------------------------------------------------------- platform

/// Public platform config (commission rate, boost tiers, support details).
/// Fetched once per app start; falls back to sane defaults when offline.
final FutureProvider<PlatformConfig> platformConfigProvider =
    FutureProvider<PlatformConfig>((Ref ref) async {
  try {
    return await ref.watch(systemRepositoryProvider).config();
  } catch (_) {
    return const PlatformConfig.fallback();
  }
});

final FutureProvider<List<CategoryInfo>> categoryInfoProvider =
    FutureProvider<List<CategoryInfo>>((Ref ref) async {
  try {
    return await ref.watch(systemRepositoryProvider).categories();
  } catch (_) {
    return EquipmentCategory.values.map(CategoryInfo.local).toList();
  }
});

final FutureProvider<List<RwandaLocation>> locationsProvider =
    FutureProvider<List<RwandaLocation>>((Ref ref) async {
  try {
    return await ref.watch(systemRepositoryProvider).locations();
  } catch (_) {
    return const <RwandaLocation>[];
  }
});

// ------------------------------------------------------------------- theme

final NotifierProvider<ThemeModeController, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final int index = ref.read(appPreferencesProvider).themeModeIndex;
    return switch (index) {
      1 => ThemeMode.light,
      2 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref
        .read(appPreferencesProvider)
        .setThemeModeIndex(switch (mode) {
      ThemeMode.light => 1,
      ThemeMode.dark => 2,
      ThemeMode.system => 0,
    });
  }
}

// ------------------------------------------------------------- misc helpers

const int kPageSize = AppConfig.pageSize;