import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewModel {
  final String id;
  final String bookingId;
  final String fromUserId;
  final String toUserId;
  final String? equipmentId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? fromUser;
  final UserModel? toUser;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.fromUserId,
    required this.toUserId,
    this.equipmentId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.fromUser,
    this.toUser,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}
