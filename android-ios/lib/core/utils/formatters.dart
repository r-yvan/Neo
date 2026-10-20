import 'package:intl/intl.dart';

import '../l10n/strings.dart';

/// Rwandan-franc formatting and date helpers.
///
/// The platform is `RWF` with no minor unit in practice, so amounts are shown
/// as whole francs with thin thousands separators, matching how prices are
/// quoted locally.
abstract final class Money {
  static const String currency = 'RWF';

  static final NumberFormat _plain = NumberFormat.decimalPattern('en_US');

  /// `45,000 RWF`
  static String format(num value, {bool withCurrency = true}) {
    final String body = _plain.format(value.round());
    return withCurrency ? '$body $currency' : body;
  }

  /// Compact form for dense dashboard tiles: `1.2M RWF`.
  static String compact(num value) {
    final double v = value.toDouble();
    if (v.abs() >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(v.abs() >= 10000000 ? 0 : 1)}M $currency';
    }
    if (v.abs() >= 1000) {
      return '${(v / 1000).toStringAsFixed(v.abs() >= 10000 ? 0 : 1)}K $currency';
    }
    return '$v $currency';
  }

  /// Percentage of `value`, e.g. commission on a booking.
  static String percent(num value, num part) {
    if (value == 0) return '0%';
    return '${(part / value * 100).toStringAsFixed(1)}%';
  }
}

/// Language-aware date formatting. `setLocale` rebuilds the cached formatters
/// in the requested locale; where the intl package has no calendar data for a
/// language (today: fr vs en, rw may fall back) it silently keeps English.
abstract final class Dates {
  static String _locale = 'en';

  static DateFormat _day = DateFormat('d MMM', _locale);
  static DateFormat _dayYear = DateFormat('d MMM yyyy', _locale);
  static DateFormat _weekday = DateFormat('EEE', _locale);
  static DateFormat _weekdayLong = DateFormat('EEEE', _locale);
  static DateFormat _monthYear = DateFormat('MMMM yyyy', _locale);
  static DateFormat _monthShort = DateFormat('MMM', _locale);
  static DateFormat _time = DateFormat('HH:mm');
  static DateFormat _iso = DateFormat('yyyy-MM-dd');

  /// Rebuilds every formatter in the preferred language. Safe to call from the
  /// language controller before the first frame paints.
  static void setLocale(String languageCode) {
    final String requested = languageCode == 'rw' ? 'rw' : 'en';
    try {
      _locale = requested;
      _day = DateFormat('d MMM', _locale);
      _dayYear = DateFormat('d MMM yyyy', _locale);
      _weekday = DateFormat('EEE', _locale);
      _weekdayLong = DateFormat('EEEE', _locale);
      _monthYear = DateFormat('MMMM yyyy', _locale);
      _monthShort = DateFormat('MMM', _locale);
      _time = DateFormat('HH:mm');
      _iso = DateFormat('yyyy-MM-dd');
    } catch (_) {
      // intl has no calendar data for this language — keep English symbols.
      _locale = 'en';
    }
  }

  static String iso(DateTime date) => _iso.format(date);

  static DateTime? tryIso(String? value) =>
      value == null ? null : DateTime.tryParse(value);

  /// Strips the time component — the backend stores booking dates as
  /// `@db.Date`, so any client-side time-of-day would be misleading.
  static DateTime dayOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String short(DateTime date) => _day.format(date);
  static String full(DateTime date) => _dayYear.format(date);
  static String weekday(DateTime date) => _weekday.format(date);
  static String weekdayLong(DateTime date) => _weekdayLong.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
  static String monthShort(DateTime date) => _monthShort.format(date);
  static String time(DateTime date) => _time.format(date);

  /// `12 – 14 Nov` or `28 Nov – 2 Dec` when the month changes.
  static String range(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${start.day} – ${end.day} ${_monthShort.format(end)}';
    }
    if (start.year == end.year) {
      return '${_day.format(start)} – ${_day.format(end)}';
    }
    return '${_dayYear.format(start)} – ${_dayYear.format(end)}';
  }

  static String relative(DateTime? date) {
    if (date == null) return '';
    final Duration diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return L10n.i.relJustNow;
    if (diff.inMinutes < 60) return L10n.i.relMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return L10n.i.relHoursAgo(diff.inHours);
    if (diff.inDays < 7) return L10n.i.relDaysAgo(diff.inDays);
    if (diff.inDays < 365) return _day.format(date);
    return _dayYear.format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Every date in `[start, end]` inclusive.
  static List<DateTime> rangeInclusive(DateTime start, DateTime end) {
    final List<DateTime> out = <DateTime>[];
    DateTime cursor = dayOnly(start);
    final DateTime last = dayOnly(end);
    while (!cursor.isAfter(last)) {
      out.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return out;
  }
}