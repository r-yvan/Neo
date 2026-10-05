import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole {
  @JsonValue('RENTER')
  renter,
  @JsonValue('OWNER')
  owner,
  @JsonValue('ADMIN')
  admin,
}

@JsonSerializable()
class UserModel {
  final String id;
  final String phone;
  final String fullName;
  final String? nationalId;
  final String? email;
  final List<UserRole> roles;
  final bool isVerified;
  final bool isBanned;
  final String? profileImage;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    this.nationalId,
    this.email,
    required this.roles,
    required this.isVerified,
    required this.isBanned,
    this.profileImage,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  bool get isOwner => roles.contains(UserRole.owner);
  bool get isRenter => roles.contains(UserRole.renter);
  bool get isAdmin => roles.contains(UserRole.admin);
}
