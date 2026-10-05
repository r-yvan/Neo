import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

enum NotificationType {
  @JsonValue('BOOKING')
  booking,
  @JsonValue('PAYMENT')
  payment,
  @JsonValue('CHAT')
  chat,
  @JsonValue('REVIEW')
  review,
  @JsonValue('SYSTEM')
  system,
  @JsonValue('DISPUTE')
  dispute,
}

@JsonSerializable()
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
