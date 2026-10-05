import 'package:json_annotation/json_annotation.dart';
import 'equipment_model.dart';
import 'user_model.dart';

part 'booking_model.g.dart';

enum BookingStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('ONGOING')
  ongoing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('DISPUTED')
  disputed,
}

enum PaymentStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PAID')
  paid,
  @JsonValue('REFUNDED')
  refunded,
  @JsonValue('FAILED')
  failed,
}

@JsonSerializable()
class BookingModel {
  final String id;
  final String equipmentId;
  final String renterId;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;
  final double totalPrice;
  final double commissionAmount;
  final double depositAmount;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final EquipmentModel? equipment;
  final UserModel? renter;
  final UserModel? owner;

  BookingModel({
    required this.id,
    required this.equipmentId,
    required this.renterId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.quantity,
    required this.totalPrice,
    required this.commissionAmount,
    required this.depositAmount,
    required this.status,
    required this.paymentStatus,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.equipment,
    this.renter,
    this.owner,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  String get statusDisplay {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.ongoing:
        return 'Ongoing';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.disputed:
        return 'Disputed';
    }
  }

  int get days {
    return endDate.difference(startDate).inDays + 1;
  }
}
