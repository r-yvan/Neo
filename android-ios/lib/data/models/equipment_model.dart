import 'package:json_annotation/json_annotation.dart';

part 'equipment_model.g.dart';

enum EquipmentCategory {
  @JsonValue('CHAIRS')
  chairs,
  @JsonValue('TABLES')
  tables,
  @JsonValue('TENTS')
  tents,
  @JsonValue('SPEAKERS')
  speakers,
  @JsonValue('LIGHTS')
  lights,
  @JsonValue('COOLERS')
  coolers,
  @JsonValue('GENERATORS')
  generators,
  @JsonValue('DECORATIONS')
  decorations,
  @JsonValue('OTHER')
  other,
}

@JsonSerializable()
class EquipmentModel {
  final String id;
  final String ownerId;
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
  final bool isAvailable;
  final bool isApproved;
  final bool isBoosted;
  final DateTime? boostedUntil;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? owner;

  EquipmentModel({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.category,
    required this.quantity,
    required this.pricePerDay,
    this.depositAmount,
    required this.location,
    this.latitude,
    this.longitude,
    required this.images,
    required this.isAvailable,
    required this.isApproved,
    required this.isBoosted,
    this.boostedUntil,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) =>
      _$EquipmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentModelToJson(this);

  String get categoryDisplay {
    switch (category) {
      case EquipmentCategory.chairs:
        return 'Chairs';
      case EquipmentCategory.tables:
        return 'Tables';
      case EquipmentCategory.tents:
        return 'Tents';
      case EquipmentCategory.speakers:
        return 'Speakers';
      case EquipmentCategory.lights:
        return 'Lights';
      case EquipmentCategory.coolers:
        return 'Coolers';
      case EquipmentCategory.generators:
        return 'Generators';
      case EquipmentCategory.decorations:
        return 'Decorations';
      case EquipmentCategory.other:
        return 'Other';
    }
  }
}
