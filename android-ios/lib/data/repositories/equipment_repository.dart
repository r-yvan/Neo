import '../../core/network/api_paths.dart';
import '../../core/utils/parsing.dart' show isoDate;
import '../models/models.dart';
import 'users_repository.dart';

/// Query surface accepted by `GET /equipment` and `GET /equipment/nearby`.
class EquipmentQuery {
  const EquipmentQuery({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.category,
    this.location,
    this.minPrice,
    this.maxPrice,
    this.date,
    this.latitude,
    this.longitude,
    this.radiusKm,
  });

  final int page;
  final int limit;
  final String? search;
  final EquipmentCategory? category;
  final String? location;
  final double? minPrice;
  final double? maxPrice;

  /// ISO `YYYY-MM-DD`; the backend excludes listings blocked on that day.
  final DateTime? date;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;

  Map<String, dynamic> toQuery() => {
        'page': page,
        'limit': limit,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (category != null) 'category': category!.wire,
        if (location != null && location!.isNotEmpty) 'location': location,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (date != null) 'date': isoDate(date!),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radiusKm != null) 'radiusKm': radiusKm,
      };

  EquipmentQuery copyWith({
    int? page,
    int? limit,
    String? search,
    EquipmentCategory? category,
    String? location,
    double? minPrice,
    double? maxPrice,
    DateTime? date,
    bool clearDate = false,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) =>
      EquipmentQuery(
        page: page ?? this.page,
        limit: limit ?? this.limit,
        search: search ?? this.search,
        category: category ?? this.category,
        location: location ?? this.location,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        date: clearDate ? null : (date ?? this.date),
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        radiusKm: radiusKm ?? this.radiusKm,
      );

  bool get isFiltered =>
      (search != null && search!.isNotEmpty) ||
      category != null ||
      (location != null && location!.isNotEmpty) ||
      minPrice != null ||
      maxPrice != null ||
      date != null;
}

/// The payload accepted by `POST /equipment`.
class EquipmentDraft {
  const EquipmentDraft({
    required this.title,
    required this.category,
    required this.quantity,
    required this.pricePerDay,
    required this.location,
    this.description,
    this.depositAmount,
    this.latitude,
    this.longitude,
    this.images = const <String>[],
  });

  final String title;
  final String? description;
  final EquipmentCategory category;
  final int quantity;
  final double pricePerDay;
  final double? depositAmount;
  final String location;
  final double? latitude;
  final double? longitude;
  final List<String> images;

  Map<String, dynamic> toCreateBody() => {
        'title': title,
        if (description != null && description!.isNotEmpty)
          'description': description,
        'category': category.wire,
        'quantity': quantity,
        'pricePerDay': pricePerDay,
        if (depositAmount != null && depositAmount! > 0)
          'depositAmount': depositAmount,
        'location': location,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (images.isNotEmpty) 'images': images,
      };

  Map<String, dynamic> toUpdateBody() => {
        'title': title,
        if (description != null) 'description': description,
        'category': category.wire,
        'quantity': quantity,
        'pricePerDay': pricePerDay,
        if (depositAmount != null) 'depositAmount': depositAmount,
        'location': location,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}

class EquipmentRepository {
  EquipmentRepository(this._get, this._post, this._patch, this._put, this._delete);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;
  final Future<dynamic> Function(String path, {Object? body}) _post;
  final Future<dynamic> Function(String path, {Object? body}) _patch;
  final Future<dynamic> Function(String path, {Object? body}) _put;
  final Future<dynamic> Function(String path, {Object? body}) _delete;

  Future<PaginatedList<Equipment>> list(EquipmentQuery query) async =>
      _page(await _get(ApiPaths.equipment, query: query.toQuery()));

  Future<PaginatedList<Equipment>> nearby(EquipmentQuery query) async =>
      _page(await _get(ApiPaths.equipmentNearby, query: query.toQuery()));

  Future<PaginatedList<Equipment>> popular({int page = 1, int limit = 10}) async =>
      _page(await _get(ApiPaths.equipmentPopular,
          query: {'page': page, 'limit': limit}));

  Future<PaginatedList<Equipment>> mine({int page = 1, int limit = 20, String? search}) async =>
      _page(await _get(ApiPaths.equipmentMy, query: {
        'page': page,
        'limit': limit,
        if (search != null && search!.isNotEmpty) 'search': search,
      }));

  Future<Equipment> byId(String id) async =>
      Equipment.fromJson(asMap(await _get(ApiPaths.equipmentById(id))));

  Future<Equipment> create(EquipmentDraft draft) async => Equipment.fromJson(
      asMap(await _post(ApiPaths.equipment, body: draft.toCreateBody())));

  Future<Equipment> update(String id, EquipmentDraft draft) async =>
      Equipment.fromJson(asMap(await _patch(ApiPaths.equipmentById(id),
          body: draft.toUpdateBody())));

  Future<Equipment> setAvailability(String id, {required bool isAvailable}) async =>
      Equipment.fromJson(asMap(await _patch(ApiPaths.equipmentById(id),
          body: {'isAvailable': isAvailable})));

  Future<void> delete(String id) =>
      _delete(ApiPaths.equipmentById(id));

  Future<Equipment> addImages(String id, List<String> urls) async =>
      Equipment.fromJson(asMap(await _post(ApiPaths.equipmentImages(id),
          body: {'urls': urls})));

  /// `imageId` is either the array index or the URL-encoded URL.
  Future<Equipment> removeImage(String id, String imageId) async =>
      Equipment.fromJson(asMap(await _delete(
          ApiPaths.equipmentImage(id, Uri.encodeComponent(imageId)))));

  /// Boosting immediately records a PAID BOOST transaction on the backend.
  Future<Equipment> boost(String id, {int? days}) async =>
      Equipment.fromJson(asMap(await _post(ApiPaths.equipmentBoost(id),
          body: {if (days != null) 'days': days})));

  Future<Equipment> cancelBoost(String id) async =>
      Equipment.fromJson(asMap(await _delete(ApiPaths.equipmentBoost(id))));

  Future<List<AvailabilityDay>> availability(String id) async {
    final dynamic res =
        await _get(ApiPaths.equipmentAvailability(id));
    return asMapList(asMap(res)['data'])
        .map(AvailabilityDay.fromJson)
        .toList(growable: false);
  }

  Future<List<AvailabilityDay>> setDates(
    String id, {
    required List<DateTime> dates,
    required bool isAvailable,
  }) async {
    final dynamic res = await _put(ApiPaths.equipmentAvailability(id), body: {
      'dates': dates.map(isoDate).toList(),
      'isAvailable': isAvailable,
    });
    return asMapList(asMap(res)['data'])
        .map(AvailabilityDay.fromJson)
        .toList(growable: false);
  }

  Future<List<AvailabilityDay>> blockDates(
    String id,
    List<DateTime> dates,
  ) async {
    final dynamic res = await _post(ApiPaths.equipmentBlockDates(id),
        body: {'dates': dates.map(isoDate).toList()});
    return asMapList(asMap(res)['data'])
        .map(AvailabilityDay.fromJson)
        .toList(growable: false);
  }

  Future<void> clearDate(String id, DateTime date) =>
      _delete(ApiPaths.equipmentAvailabilityDate(id, isoDate(date)));

  Future<List<String>> categories() async {
    final dynamic res = await _get(ApiPaths.equipmentCategories, skipAuth: true);
    return asStringList(asMap(res)['categories']);
  }
}

PaginatedList<Equipment> _page(dynamic res) {
  final Map<String, dynamic> map = asMap(res);
  return PaginatedList<Equipment>(
    items: asMapList(map['data']).map(Equipment.fromJson).toList(),
    meta: asMap(map['meta']),
  );
}