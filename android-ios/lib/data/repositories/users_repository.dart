import '../../core/network/api_paths.dart';
import '../../core/utils/parsing.dart';
import '../models/models.dart';

/// Reads the app's own profile plus the public profiles of other users.
class UsersRepository {
  UsersRepository(this._get, this._post, this._patch, this._delete);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;
  final Future<dynamic> Function(String path, {Object? body}) _post;
  final Future<dynamic> Function(String path, {Object? body}) _patch;
  final Future<dynamic> Function(String path, {Object? body}) _delete;

  Future<AppUser> me() async =>
      AppUser.fromJson(asMap(await _get(ApiPaths.usersMe)));

  Future<AppUser> updateProfile({String? fullName, String? email}) async =>
      AppUser.fromJson(asMap(await _patch(ApiPaths.usersMe, body: {
        if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
        if (email != null && email.isNotEmpty) 'email': email,
      })));

  /// The backend stores an avatar *URL*, not a file — there is no binary
  /// upload route in the API, so the client passes whatever URL it holds.
  Future<AppUser> setAvatar(String url) async => AppUser.fromJson(
      asMap(await _post(ApiPaths.usersMeAvatar, body: {'url': url})));

  Future<AppUser> removeAvatar() async =>
      AppUser.fromJson(asMap(await _delete(ApiPaths.usersMeAvatar)));

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final dynamic res = await _post(ApiPaths.usersMeChangePassword, body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    return asString(asMap(res)['message'], 'Password changed');
  }

  /// A user may hold RENTER and OWNER at the same time; this adds one.
  Future<AppUser> addRole(UserRole role) async => AppUser.fromJson(
      asMap(await _patch(ApiPaths.usersMeRole, body: {'role': role.wire})));

  Future<AppUser> submitNationalId(String nationalId) async =>
      AppUser.fromJson(asMap(await _post(ApiPaths.usersMeVerifyNationalId,
          body: {'nationalId': nationalId})));

  Future<PublicProfile> profile(String id) async =>
      PublicProfile.fromJson(asMap(await _get(ApiPaths.user(id))));

  Future<PaginatedList<Review>> reviews(String id,
          {int page = 1, int limit = 20}) async =>
      _reviewPage(await _get(ApiPaths.userReviews(id),
          query: {'page': page, 'limit': limit}));

  Future<List<Equipment>> equipment(String id,
      {int page = 1, int limit = 20}) async {
    final dynamic res = await _get(ApiPaths.userEquipment(id),
        query: {'page': page, 'limit': limit});
    return asMapList(asMap(res)['data'])
        .map(Equipment.fromJson)
        .toList(growable: false);
  }

  Future<PaginatedList<PublicProfile>> search(String? term,
      {int page = 1, int limit = 20}) async {
    final dynamic res = await _get(ApiPaths.usersSearch, query: {
      'page': page,
      'limit': limit,
      if (term != null && term.isNotEmpty) 'search': term,
    });
    return PaginatedList<PublicProfile>(
      items: asMapList(asMap(res)['data']).map(PublicProfile.fromJson).toList(),
      meta: asMap(asMap(res)['meta']),
    );
  }
}

class PaginatedList<T> {
  const PaginatedList({required this.items, required this.meta});

  final List<T> items;
  final Map<String, dynamic> meta;

  int get total => asInt(meta['total'], items.length);
  int get page => asInt(meta['page'], 1);
  bool get hasMore => page * asInt(meta['limit'], 20) < total;
  int get length => items.length;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  PaginatedList<T> merge(PaginatedList<T> other) {
    return PaginatedList<T>(
      items: [...items, ...other.items],
      meta: other.meta,
    );
  }
}

PaginatedList<Review> _reviewPage(dynamic res) {
  final Map<String, dynamic> map = asMap(res);
  return PaginatedList<Review>(
    items: asMapList(map['data']).map(Review.fromJson).toList(),
    meta: asMap(map['meta']),
  );
}
