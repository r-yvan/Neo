/// A single, user-presentable failure type for every network call.
///
/// The backend funnels all errors through `AllExceptionsFilter`, which always
/// answers with `{ success, statusCode, error, message, timestamp }` where
/// `message` is a string or a list of validation strings. [ApiException]
/// unwraps that shape once so the UI never has to.
library;

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const <String, List<String>>{},
    this.isNetwork = false,
  });

  factory ApiException.fromResponse(
    int? statusCode,
    dynamic body, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    String message = fallback;
    final Map<String, List<String>> fields = <String, List<String>>{};

    if (body is Map) {
      final Object? raw = body['message'];
      if (raw is String && raw.isNotEmpty) {
        message = raw;
      } else if (raw is List && raw.isNotEmpty) {
        message = raw.map((Object? e) => e.toString()).join('\n');
      } else if (raw == null && body['error'] is String) {
        message = body['error'] as String;
      }

      // ValidationPipe errors arrive as `{ message: [ ... ] }` with no keys we
      // can map, but some DTOs return keyed maps in future — support both.
      for (final MapEntry<Object?, Object?> entry in body.entries) {
        final Object? value = entry.value;
        if (entry.key != 'message' && value is List) {
          fields[entry.key.toString()] =
              value.map((Object? e) => e.toString()).toList();
        }
      }
    } else if (body is String && body.isNotEmpty) {
      message = body;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      fieldErrors: fields,
    );
  }

  factory ApiException.network([String? detail]) => ApiException(
        message: detail ??
            'No internet connection. Check your network and try again.',
        isNetwork: true,
      );

  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;
  final bool isNetwork;

  /// The session is gone and the user must sign in again.
  bool get isUnauthorized => statusCode == 401;

  /// The action is not allowed for this account or resource.
  bool get isForbidden => statusCode == 403;

  bool get isNotFound => statusCode == 404;

  /// Something already exists (duplicate phone, duplicate national ID, ...).
  bool get isConflict => statusCode == 409;

  /// Client-side validation rejected the payload.
  bool get isValidation => statusCode == 400;

  String get firstFieldError =>
      fieldErrors.values.expand((List<String> v) => v).firstOrNull ?? '';

  @override
  String toString() => message;
}