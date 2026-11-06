import '../../core/network/api_paths.dart';
import '../../core/utils/parsing.dart';
import '../models/admin_models.dart';
import '../models/models.dart';
import 'users_repository.dart';

/// Back-office operations. Every route is guarded by the ADMIN role
/// server-side; the client only shows the console to admins.
class AdminRepository {
  AdminRepository(this._get, this._patch, this._delete);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;
  final Future<dynamic> Function(String path, {Object? body}) _patch;
  final Future<dynamic> Function(String path, {Object? body}) _delete;

  Future<AdminStats> dashboard() async =>
      AdminStats.fromJson(asMap(await _get(ApiPaths.adminDashboard)));

  Future<AdminAnalytics> analytics() async =>
      AdminAnalytics.fromJson(asMap(await _get(ApiPaths.adminAnalytics)));

  Future<PaginatedList<T>> _page<T>(
    String path,
    T Function(Map<String, dynamic>) parse, {
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> map =
        asMap(await _get(path, query: {'page': page, 'limit': limit}));
    return PaginatedList<T>(
      items: asMapList(map['data']).map(parse).toList(),
      meta: asMap(map['meta']),
    );
  }

  // ----------------------------------------------------------------- users
  Future<PaginatedList<AppUser>> users({int page = 1}) =>
      _page(ApiPaths.adminUsers, AppUser.fromJson, page: page);

  Future<void> verifyUser(String id) => _patch(ApiPaths.adminUserVerify(id));
  Future<void> banUser(String id) => _patch(ApiPaths.adminUserBan(id));
  Future<void> unbanUser(String id) => _patch(ApiPaths.adminUserUnban(id));

  // ------------------------------------------------------------- equipment
  Future<PaginatedList<AdminEquipment>> equipment({int page = 1}) =>
      _page(ApiPaths.adminEquipment, AdminEquipment.fromJson, page: page);

  Future<void> approveEquipment(String id) =>
      _patch(ApiPaths.adminEquipmentApprove(id));
  Future<void> rejectEquipment(String id) =>
      _patch(ApiPaths.adminEquipmentReject(id));

  // ----------------------------------------------------- money & bookings
  Future<PaginatedList<Booking>> bookings({int page = 1}) =>
      _page(ApiPaths.adminBookings, Booking.fromJson, page: page);

  Future<PaginatedList<AdminTransaction>> transactions({int page = 1}) =>
      _page(ApiPaths.adminTransactions, AdminTransaction.fromJson, page: page);

  // --------------------------------------------------------------- reviews
  Future<PaginatedList<Review>> reviews({int page = 1}) =>
      _page(ApiPaths.adminReviews, Review.fromJson, page: page);

  Future<void> deleteReview(String id) => _delete(ApiPaths.adminReview(id));

  // ------------------------------------------------------ trust & safety
  Future<PaginatedList<AdminReport>> reports({int page = 1}) =>
      _page(ApiPaths.adminReports, AdminReport.fromJson, page: page);

  /// `status` is RESOLVED or DISMISSED.
  Future<void> resolveReport(String id,
          {required String status, String? note}) =>
      _patch(ApiPaths.adminReport(id), body: {
        'status': status,
        if (note != null && note.isNotEmpty) 'note': note,
      });

  Future<PaginatedList<AdminDispute>> disputes({int page = 1}) =>
      _page(ApiPaths.adminDisputes, AdminDispute.fromJson, page: page);

  /// `status` is RESOLVED or CLOSED.
  Future<void> resolveDispute(String id,
          {required String status, required String resolution}) =>
      _patch(ApiPaths.adminDispute(id),
          body: {'status': status, 'resolution': resolution});
}
