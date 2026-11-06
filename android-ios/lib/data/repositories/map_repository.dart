import '../../core/network/api_paths.dart';
import '../../core/utils/parsing.dart';
import '../models/map_models.dart';

class MapRepository {
  MapRepository(this._get, this._patch, this._delete);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;
  final Future<dynamic> Function(String path, {Object? body}) _patch;
  final Future<dynamic> Function(String path, {Object? body}) _delete;

  Future<MapNearby> nearby({
    required double latitude,
    required double longitude,
    double radiusKm = 15,
    MapLayer layer = MapLayer.all,
  }) async =>
      MapNearby.fromJson(asMap(await _get(ApiPaths.mapNearby, query: {
        'latitude': latitude,
        'longitude': longitude,
        'radiusKm': radiusKm,
        'layer': layer.wire,
      })));

  Future<MapPresence> presence() async =>
      MapPresence.fromJson(asMap(await _get(ApiPaths.mapMe)));

  /// Only the fields given are changed. Pass an empty string to clear a text.
  Future<MapPresence> updatePresence({
    double? latitude,
    double? longitude,
    String? locationLabel,
    bool? showOnMap,
    String? note,
  }) async =>
      MapPresence.fromJson(asMap(await _patch(ApiPaths.mapMe, body: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (locationLabel != null) 'locationLabel': locationLabel,
        if (showOnMap != null) 'showOnMap': showOnMap,
        if (note != null) 'mapNote': note,
      })));

  /// Hides the user and deletes the stored location server-side.
  Future<MapPresence> clearPresence() async =>
      MapPresence.fromJson(asMap(await _delete(ApiPaths.mapMe)));
}
