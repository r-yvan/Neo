/// Client-side mirrors of the backend's validation rules.
///
/// The server rejects bad input with 400 and a `message` array; catching the
/// obvious cases locally keeps the UX immediate without duplicating logic that
/// matters (ownership, quota, date conflicts — those are server-enforced).
library;

abstract final class Validators {
  /// `RegisterDto.phone` accepts `07…`, `2507…` or `+2507…` plus 8 digits.
  static final RegExp phonePattern = RegExp(r'^(07|2507|\+2507)\d{8}$');

  /// 16 digits, the format printed on a Rwandan national ID.
  static final RegExp nationalIdPattern = RegExp(r'^\d{16}$');

  static String? phone(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter your phone number';
    if (!phonePattern.hasMatch(v)) {
      return 'Enter a valid Rwandan number, e.g. 0780000000';
    }
    return null;
  }

  /// Normalises local formats to the E.164 form the API expects (`250…`).
  static String normalisePhone(String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('250')) return digits;
    if (digits.startsWith('0')) return '250${digits.substring(1)}';
    return digits;
  }

  static String? fullName(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter your full name';
    if (v.length < 2) return 'That name looks too short';
    return null;
  }

  static String? email(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return null; // optional
    final RegExp re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(v) ? null : 'Enter a valid email address';
  }

  static String? password(String? value, {bool required = true}) {
    final String v = value ?? '';
    if (v.isEmpty) return required ? 'Choose a password' : null;
    if (v.length < 6) return 'Use at least 6 characters';
    return null;
  }

  static String? nationalId(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter your national ID';
    if (!nationalIdPattern.hasMatch(v)) {
      return 'A national ID is 16 digits';
    }
    return null;
  }

  static String? otp(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter the 6-digit code';
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return 'The code is 6 digits';
    return null;
  }

  static String? title(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Give your listing a title';
    if (v.length < 4) return 'Use at least 4 characters';
    return null;
  }

  static String? description(String? value) {
    final String v = (value ?? '').trim();
    if (v.length > 2000) return 'Keep it under 2000 characters';
    return null;
  }

  static String? location(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Where can the item be collected?';
    return null;
  }

  static String? quantity(String? value, {int max = 100000}) {
    final int? n = int.tryParse((value ?? '').trim());
    if (n == null) return 'Enter a number';
    if (n < 1) return 'At least 1';
    if (n > max) return 'That is more than $max';
    return null;
  }

  static String? price(String? value) {
    final num? n = num.tryParse((value ?? '').trim().replaceAll(',', ''));
    if (n == null) return 'Enter a price in RWF';
    if (n <= 0) return 'The price must be more than 0';
    if (n > 100000000) return 'That price is out of range';
    return null;
  }

  static String? required(String? value, {String message = 'This field is required'}) =>
      (value ?? '').trim().isEmpty ? message : null;
}