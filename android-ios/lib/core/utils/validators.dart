import '../l10n/strings.dart';

/// Client-side mirrors of the backend's validation rules.
///
/// The server rejects bad input with 400 and a `message` array; catching the
/// obvious cases locally keeps the UX immediate without duplicating logic that
/// matters (ownership, quota, date conflicts — those are server-enforced).
abstract final class Validators {
  /// `RegisterDto.phone` accepts `07…`, `2507…` or `+2507…` plus 8 digits.
  static final RegExp phonePattern = RegExp(r'^(07|2507|\+2507)\d{8}$');

  /// 16 digits, the format printed on a Rwandan national ID.
  static final RegExp nationalIdPattern = RegExp(r'^\d{16}$');

  static String? phone(String? value) {
    final S s = L10n.i;
    final String v = (value ?? '').trim();
    if (v.isEmpty) return s.valPhoneEmpty;
    if (!phonePattern.hasMatch(v)) {
      return s.valPhonePattern;
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
    final S s = L10n.i;
    final String v = (value ?? '').trim();
    if (v.isEmpty) return s.valFullNameEmpty;
    if (v.length < 2) return s.valFullNameShort;
    return null;
  }

  static String? email(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return null; // optional
    final RegExp re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(v) ? null : L10n.i.valEmailInvalid;
  }

  static String? password(String? value, {bool required = true}) {
    final S s = L10n.i;
    final String v = value ?? '';
    if (v.isEmpty) return required ? s.valPasswordEmpty : null;
    if (v.length < 6) return s.valPasswordShort;
    return null;
  }

  static String? nationalId(String? value) {
    final S s = L10n.i;
    final String v = (value ?? '').trim();
    if (v.isEmpty) return s.valIdEmpty;
    if (!nationalIdPattern.hasMatch(v)) {
      return s.valIdPattern;
    }
    return null;
  }

  static String? otp(String? value) {
    final S s = L10n.i;
    final String v = (value ?? '').trim();
    if (v.isEmpty) return s.valOtpEmpty;
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return s.valOtpPattern;
    return null;
  }

  static String? title(String? value) {
    final S s = L10n.i;
    final String v = (value ?? '').trim();
    if (v.isEmpty) return s.valTitleEmpty;
    if (v.length < 4) return s.valTitleShort;
    return null;
  }

  static String? description(String? value) {
    final String v = (value ?? '').trim();
    if (v.length > 2000) return L10n.i.valDescriptionLong;
    return null;
  }

  static String? location(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return L10n.i.valLocationEmpty;
    return null;
  }

  static String? quantity(String? value, {int max = 100000}) {
    final S s = L10n.i;
    final int? n = int.tryParse((value ?? '').trim());
    if (n == null) return s.valQuantityNumber;
    if (n < 1) return s.valQuantityMin;
    if (n > max) return s.valQuantityMax(max);
    return null;
  }

  static String? price(String? value) {
    final S s = L10n.i;
    final num? n = num.tryParse((value ?? '').trim().replaceAll(',', ''));
    if (n == null) return s.valPriceNumber;
    if (n <= 0) return s.valPriceZero;
    if (n > 100000000) return s.valPriceRange;
    return null;
  }

  static String? required(String? value, {String? message}) => (value ?? '')
          .trim()
          .isEmpty
      ? (message ?? L10n.i.valFieldRequired)
      : null;
}
