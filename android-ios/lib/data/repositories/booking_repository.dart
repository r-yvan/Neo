import '../../core/network/api_paths.dart';
import '../../core/utils/parsing.dart' show isoDate;
import '../models/models.dart';
import 'users_repository.dart';

class BookingRepository {
  BookingRepository(this._get, this._post, this._patch);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;
  final Future<dynamic> Function(String path, {Object? body}) _post;
  final Future<dynamic> Function(String path, {Object? body}) _patch;

  /// Pricing is computed server-side. The client previews the same formula so
  /// the summary screen can respond instantly; the booking response is
  /// authoritative.
  Future<Booking> create({
    required String equipmentId,
    required DateTime startDate,
    required DateTime endDate,
    required int quantity,
    String? notes,
  }) async =>
      Booking.fromJson(asMap(await _post(ApiPaths.bookings, body: {
        'equipmentId': equipmentId,
        'startDate': isoDate(startDate),
        'endDate': isoDate(endDate),
        'quantity': quantity,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      })));

  Future<PaginatedList<Booking>> mine({
    BookingRole? role,
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    final String path = switch (role) {
      BookingRole.renter => ApiPaths.bookingsRenter,
      BookingRole.owner => ApiPaths.bookingsOwner,
      null => ApiPaths.bookings,
    };
    return _page(await _get(path, query: {
      'page': page,
      'limit': limit,
      if (role != null) 'role': role.wire,
      if (status != null) 'status': status.wire,
    }));
  }

  Future<Booking> byId(String id) async =>
      Booking.fromJson(asMap(await _get(ApiPaths.booking(id))));

  Future<List<BookingTimelineEntry>> timeline(String id) async {
    final dynamic res = await _get(ApiPaths.bookingTimeline(id));
    return asMapList(res).map(BookingTimelineEntry.fromJson).toList();
  }

  Future<Booking> accept(String id) async =>
      Booking.fromJson(asMap(await _patch(ApiPaths.bookingAccept(id))));

  Future<Booking> reject(String id) async =>
      Booking.fromJson(asMap(await _patch(ApiPaths.bookingReject(id))));

  Future<Booking> cancel(String id) async =>
      Booking.fromJson(asMap(await _patch(ApiPaths.bookingCancel(id))));

  Future<Booking> start(String id) async =>
      Booking.fromJson(asMap(await _patch(ApiPaths.bookingStart(id))));

  Future<Booking> complete(String id) async =>
      Booking.fromJson(asMap(await _patch(ApiPaths.bookingComplete(id))));

  Future<Booking> markDisputed(String id) async =>
      Booking.fromJson(asMap(await _patch(ApiPaths.bookingDispute(id))));

  /// Re-prices the booking against the equipment's current daily rate.
  Future<Booking> extend(String id, DateTime newEndDate) async =>
      Booking.fromJson(asMap(await _post(ApiPaths.bookingExtend(id),
          body: {'newEndDate': isoDate(newEndDate)})));

  /// Client-side mirror of `BookingsService.rentalDays`.
  static int rentalDays(DateTime start, DateTime end) {
    final DateTime a = DateTime(start.year, start.month, start.day);
    final DateTime b = DateTime(end.year, end.month, end.day);
    final int days = b.difference(a).inDays + 1;
    return days < 1 ? 1 : days;
  }

  /// Client-side mirror of `calcPricing` + the 10% platform commission.
  static ({double total, double commission, double deposit}) preview({
    required double pricePerDay,
    required double? depositAmount,
    required DateTime startDate,
    required DateTime endDate,
    required int quantity,
    double commissionRate = 0.10,
  }) {
    final int days = rentalDays(startDate, endDate);
    final double total = days * pricePerDay * quantity;
    return (
      total: total,
      commission: total * commissionRate,
      deposit: depositAmount ?? 0,
    );
  }
}

enum BookingRole {
  renter('renter', 'I am renting'),
  owner('owner', 'I own the item');

  const BookingRole(this.wire, this.label);
  final String wire;
  final String label;
}

PaginatedList<Booking> _page(dynamic res) {
  final Map<String, dynamic> map = asMap(res);
  return PaginatedList<Booking>(
    items: asMapList(map['data']).map(Booking.fromJson).toList(),
    meta: asMap(map['meta']),
  );
}