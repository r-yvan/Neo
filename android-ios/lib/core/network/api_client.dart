import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/token_store.dart';
import 'api_exception.dart';
import 'api_paths.dart';

/// Signed-in user snapshot attached to the request context by the guards.
class AuthenticatedUser {
  const AuthenticatedUser({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.roles,
    required this.isVerified,
    this.profileImage,
    this.nationalId,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  final String id;
  final String phone;
  final String fullName;
  final List<String> roles;
  final bool isVerified;
  final String? profileImage;
  final String? nationalId;
  final double averageRating;
  final int totalReviews;

  bool get isOwner => roles.contains('OWNER');
  bool get isAdmin => roles.contains('ADMIN');
}

/// Callbacks the app installs so the client never imports Riverpod.
typedef SessionExpiredCallback = Future<void> Function();

/// Configured Dio instance: bearer injection, silent refresh, error mapping.
class ApiClient {
  ApiClient({required TokenStore tokens, String? baseUrl})
      : _tokens = tokens,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 30),
            responseType: ResponseType.json,
            headers: const {'Accept': 'application/json'},
            // We inspect every response ourselves so error bodies keep their
            // `message` payload instead of throwing a bare DioException.
            validateStatus: (int? status) => status != null && status < 500,
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
      ),
    );
  }

  final Dio _dio;
  final TokenStore _tokens;

  /// Guards against a refresh stampede when several requests 401 at once.
  Future<bool>? _refreshInFlight;

  SessionExpiredCallback? onSessionExpired;

  Dio get raw => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      handler.next(options);
      return;
    }

    final String? token = _tokens.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final int status = response.statusCode ?? 0;
    if (status != 401 || response.requestOptions.extra['skipAuth'] == true) {
      handler.next(response);
      return;
    }

    // One refresh attempt, shared by every queued request.
    final bool refreshed = await (_refreshInFlight ??= _refresh()
      ..whenComplete(() => _refreshInFlight = null));
    if (!refreshed) {
      handler.next(response);
      return;
    }

    final RequestOptions retry = response.requestOptions;
    retry.headers['Authorization'] = 'Bearer ${_tokens.accessToken}';
    try {
      final Response<dynamic> replay = await _dio.fetch<dynamic>(retry);
      handler.resolve(replay);
    } on DioException catch (error) {
      handler.next(error.response ?? response);
    }
  }

  Future<bool> _refresh() async {
    final String? refreshToken = _tokens.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        ApiPaths.authRefresh,
        data: {'refreshToken': refreshToken},
        options: Options(extra: const {'skipAuth': true}),
      );
      final int status = response.statusCode ?? 0;
      if (status < 200 || status >= 300 || response.data is! Map) {
        await _expire();
        return false;
      }
      final Map<String, dynamic> body =
          (response.data as Map).cast<String, dynamic>();
      await _tokens.save(
        accessToken: body['accessToken'] as String,
        refreshToken: (body['refreshToken'] as String?) ?? refreshToken,
      );
      return true;
    } catch (_) {
      await _expire();
      return false;
    }
  }

  Future<void> _expire() async {
    await _tokens.clear();
    await onSessionExpired?.call();
  }

  // ---------------------------------------------------------------- helpers

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) =>
      _send(() => _dio.get<dynamic>(
            path,
            queryParameters: _clean(query),
            options: _options(skipAuth),
          ));

  Future<dynamic> post(
    String path, {
    Object? body,
    bool skipAuth = false,
  }) =>
      _send(() => _dio.post<dynamic>(
            path,
            data: body,
            options: _options(skipAuth),
          ));

  Future<dynamic> patch(String path, {Object? body}) =>
      _send(() => _dio.patch<dynamic>(path, data: body));

  Future<dynamic> put(String path, {Object? body}) =>
      _send(() => _dio.put<dynamic>(path, data: body));

  Future<dynamic> delete(String path, {Object? body}) =>
      _send(() => _dio.delete<dynamic>(path, data: body));

  static Options _options(bool skipAuth) =>
      Options(extra: skipAuth ? const {'skipAuth': true} : null);

  /// Drops null entries so optional query filters never reach the wire as
  /// `?foo=null`.
  static Map<String, dynamic>? _clean(Map<String, dynamic>? query) {
    if (query == null) return null;
    final Map<String, dynamic> out = <String, dynamic>{};
    for (final MapEntry<String, dynamic> e in query.entries) {
      final Object? v = e.value;
      if (v == null) continue;
      if (v is String && v.isEmpty) continue;
      if (v is List && v.isEmpty) continue;
      out[e.key] = v;
    }
    return out.isEmpty ? null : out;
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() run) async {
    late final Response<dynamic> response;
    try {
      response = await run();
    } on DioException catch (error) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw ApiException(
            message: 'The server took too long to respond. Try again.',
            isNetwork: true,
          );
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
          throw ApiException.network();
        case DioExceptionType.badCertificate:
          throw ApiException(
            message:
                'Could not establish a secure connection to the server.',
            isNetwork: true,
          );
        case DioExceptionType.cancel:
          throw ApiException(message: 'Request cancelled.');
        case DioExceptionType.badResponse:
          throw ApiException.fromResponse(
            error.response?.statusCode,
            error.response?.data,
          );
      }
    }

    final int status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return response.data;

    if (status == 401) {
      // The interceptor already tried to refresh; if we are still here the
      // session is genuinely dead.
      await _expire();
    }

    throw ApiException.fromResponse(status, response.data);
  }

  @visibleForTesting
  Future<dynamic> getRaw(String path, {Map<String, dynamic>? query}) =>
      get(path, query: query);
}