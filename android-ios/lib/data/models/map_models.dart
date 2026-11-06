/// Read models for the nearby map (`/map/*`).
library;

import '../../core/utils/parsing.dart';
import 'models.dart';

enum MapLayer {
  all('all'),
  lenders('lenders'),
  borrowers('borrowers');

  const MapLayer(this.wire);
  final String wire;
}

/// Fields shared by every pin on the map.
abstract class MapPerson {
  /// The user's id (for profile / chat).
  String get id;

  /// Unique per pin. A lender can have several pins (one per area).
  String get key => id;

  String get fullName;
  String? get profileImage;
  double get averageRating;
  int get totalReviews;
  bool get isVerified;
  double get latitude;
  double get longitude;
  double get distanceKm;
  String? get locationLabel;

  UserRef toUserRef() => UserRef(
        id: id,
        fullName: fullName,
        profileImage: profileImage,
        averageRating: averageRating,
        totalReviews: totalReviews,
      );

  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class MapListing {
  const MapListing({
    required this.id,
    required this.title,
    required this.category,
    required this.pricePerDay,
    this.image,
  });

  factory MapListing.fromJson(Map<String, dynamic> json) => MapListing(
        id: asString(json['id']),
        title: asString(json['title']),
        image: asStringOrNull(json['image']),
        category: EquipmentCategory.fromWire(asStringOrNull(json['category'])),
        pricePerDay: asDouble(json['pricePerDay']),
      );

  final String id;
  final String title;
  final String? image;
  final EquipmentCategory category;
  final double pricePerDay;
}

/// An owner with live listings nearby. The pin sits at their listings.
class MapLender extends MapPerson {
  MapLender({
    required this.id,
    String? pinId,
    required this.fullName,
    required this.latitude,
    required this.longitude,
    this.profileImage,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.isVerified = false,
    this.distanceKm = 0,
    this.locationLabel,
    this.listingCount = 0,
    this.categories = const <EquipmentCategory>[],
    this.minPricePerDay = 0,
    this.listings = const <MapListing>[],
  }) : pinId = pinId ?? id;

  factory MapLender.fromJson(Map<String, dynamic> json) => MapLender(
        id: asString(json['id']),
        pinId: asStringOrNull(json['pinId']),
        fullName: asString(json['fullName']),
        profileImage: asStringOrNull(json['profileImage']),
        averageRating: asDouble(json['averageRating']),
        totalReviews: asInt(json['totalReviews']),
        isVerified: asBool(json['isVerified']),
        latitude: asDouble(json['latitude']),
        longitude: asDouble(json['longitude']),
        distanceKm: asDouble(json['distanceKm']),
        locationLabel: asStringOrNull(json['locationLabel']),
        listingCount: asInt(json['listingCount']),
        categories: asStringList(json['categories'])
            .map(EquipmentCategory.fromWire)
            .toList(growable: false),
        minPricePerDay: asDouble(json['minPricePerDay']),
        listings: asMapList(json['listings'])
            .map(MapListing.fromJson)
            .toList(growable: false),
      );

  @override
  final String id;
  @override
  final String fullName;
  @override
  final String? profileImage;
  @override
  final double averageRating;
  @override
  final int totalReviews;
  @override
  final bool isVerified;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final double distanceKm;
  @override
  final String? locationLabel;
  final String pinId;

  @override
  String get key => pinId;

  final int listingCount;
  final List<EquipmentCategory> categories;
  final double minPricePerDay;
  final List<MapListing> listings;
}

/// A renter who chose to appear on the map. Position is approximate (~1 km).
class MapBorrower extends MapPerson {
  MapBorrower({
    required this.id,
    required this.fullName,
    required this.latitude,
    required this.longitude,
    this.profileImage,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.isVerified = false,
    this.distanceKm = 0,
    this.locationLabel,
    this.note,
    this.activeAt,
  });

  factory MapBorrower.fromJson(Map<String, dynamic> json) => MapBorrower(
        id: asString(json['id']),
        fullName: asString(json['fullName']),
        profileImage: asStringOrNull(json['profileImage']),
        averageRating: asDouble(json['averageRating']),
        totalReviews: asInt(json['totalReviews']),
        isVerified: asBool(json['isVerified']),
        latitude: asDouble(json['latitude']),
        longitude: asDouble(json['longitude']),
        distanceKm: asDouble(json['distanceKm']),
        locationLabel: asStringOrNull(json['locationLabel']),
        note: asStringOrNull(json['note']),
        activeAt: asDateOrNull(json['activeAt']),
      );

  @override
  final String id;
  @override
  final String fullName;
  @override
  final String? profileImage;
  @override
  final double averageRating;
  @override
  final int totalReviews;
  @override
  final bool isVerified;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final double distanceKm;
  @override
  final String? locationLabel;
  final String? note;
  final DateTime? activeAt;
}

class MapNearby {
  const MapNearby({
    required this.radiusKm,
    this.lenders = const <MapLender>[],
    this.borrowers = const <MapBorrower>[],
  });

  factory MapNearby.fromJson(Map<String, dynamic> json) => MapNearby(
        radiusKm: asDouble(json['radiusKm'], 15),
        lenders: asMapList(json['lenders'])
            .map(MapLender.fromJson)
            .toList(growable: false),
        borrowers: asMapList(json['borrowers'])
            .map(MapBorrower.fromJson)
            .toList(growable: false),
      );

  final double radiusKm;
  final List<MapLender> lenders;
  final List<MapBorrower> borrowers;
}

/// The signed-in user's own map settings.
class MapPresence {
  const MapPresence({
    this.latitude,
    this.longitude,
    this.locationLabel,
    this.showOnMap = false,
    this.note,
    this.updatedAt,
  });

  factory MapPresence.fromJson(Map<String, dynamic> json) => MapPresence(
        latitude: json['latitude'] == null ? null : asDouble(json['latitude']),
        longitude:
            json['longitude'] == null ? null : asDouble(json['longitude']),
        locationLabel: asStringOrNull(json['locationLabel']),
        showOnMap: asBool(json['showOnMap']),
        note: asStringOrNull(json['mapNote']),
        updatedAt: asDateOrNull(json['locationUpdatedAt']),
      );

  final double? latitude;
  final double? longitude;
  final String? locationLabel;
  final bool showOnMap;
  final String? note;
  final DateTime? updatedAt;

  bool get hasLocation => latitude != null && longitude != null;
}
