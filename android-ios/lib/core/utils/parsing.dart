/// Shared parsing helpers.
///
/// Prisma serialises `Decimal` columns as JSON strings (`"15000"`), so every
/// money field in the API arrives quoted. [asDouble] and [asInt] accept both
/// quoted and unquoted forms; nothing in the app parses a decimal by hand.
library;

double asDouble(Object? value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) {
    if (value.isEmpty) return fallback;
    return double.tryParse(value) ?? fallback;
  }
  return fallback;
}

int asInt(Object? value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  if (value is String) {
    if (value.isEmpty) return fallback;
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
  }
  return fallback;
}

bool asBool(Object? value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is String) return value == 'true';
  if (value is num) return value != 0;
  return fallback;
}

String asString(Object? value, [String fallback = '']) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

String? asStringOrNull(Object? value) {
  if (value == null) return null;
  final String s = value is String ? value : value.toString();
  return s.isEmpty ? null : s;
}

DateTime? asDateOrNull(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

DateTime asDate(Object? value) =>
    asDateOrNull(value) ?? DateTime.fromMillisecondsSinceEpoch(0);

/// Converts DateTime to ISO date string (YYYY-MM-DD)
String isoDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

List<String> asStringList(Object? value) {
  if (value is List) {
    return value.map((Object? e) => e?.toString() ?? '').where((String e) => e.isNotEmpty).toList();
  }
  return const <String>[];
}

List<String> asStringEnumList(Object? value) {
  return asStringList(value);
}

Map<String, dynamic> asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> asMapList(Object? value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((Map e) => e.cast<String, dynamic>())
        .toList();
  }
  return const <Map<String, dynamic>>[];
}

/// A raw `T | null` field, kept because some backend selects omit keys
/// entirely rather than sending null.
extension NullableMapRead<T> on Map<String, dynamic> {
  T? read<T>(String key) {
    final Object? value = this[key];
    if (value == null) return null;
    return value as T;
  }
}