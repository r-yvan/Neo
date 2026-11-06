import 'package:eventneo/data/models/admin_models.dart';
import 'package:eventneo/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Booking exposes its dispute summary', () {
    final Booking b = Booking.fromJson(<String, dynamic>{
      'id': 'b1',
      'equipmentId': 'e1',
      'renterId': 'r1',
      'ownerId': 'o1',
      'startDate': '2026-11-01T00:00:00.000Z',
      'endDate': '2026-11-03T00:00:00.000Z',
      'quantity': 10,
      'totalPrice': '450000',
      'commissionAmount': '45000',
      'status': 'DISPUTED',
      'paymentStatus': 'PENDING',
      'dispute': <String, dynamic>{'id': 'd1', 'status': 'OPEN'},
    });
    expect(b.status, BookingStatus.disputed);
    expect(b.disputeId, 'd1');
    expect(b.disputeStatus, 'OPEN');
    expect(b.days, 3);
    expect(b.ownerPayout, 405000);
  });

  test('Booking without a dispute', () {
    final Booking b = Booking.fromJson(<String, dynamic>{
      'id': 'b1',
      'startDate': '2026-11-01',
      'endDate': '2026-11-01',
      'dispute': null,
    });
    expect(b.disputeId, isNull);
  });

  test('Transaction falls back to metadata for the listing title', () {
    final Transaction t = Transaction.fromJson(<String, dynamic>{
      'id': 't1',
      'amount': '450000',
      'type': 'RENTAL',
      'status': 'PENDING',
      'metadata': <String, dynamic>{'equipmentTitle': 'White Plastic Chairs'},
      'booking': <String, dynamic>{'id': 'b1', 'status': 'ACCEPTED'},
    });
    expect(t.equipmentTitle, 'White Plastic Chairs');
    expect(t.type, TransactionType.rental);
    expect(t.type.isIncoming, isFalse);
    expect(TransactionType.payout.isIncoming, isTrue);
  });

  test('Dispute parses opener and listing', () {
    final Dispute d = Dispute.fromJson(<String, dynamic>{
      'id': 'd1',
      'bookingId': 'b1',
      'openedById': 'u1',
      'reason': 'Broken chairs',
      'status': 'IN_REVIEW',
      'openedBy': <String, dynamic>{'id': 'u1', 'fullName': 'Bob Renter'},
      'booking': <String, dynamic>{
        'equipment': <String, dynamic>{'id': 'e1', 'title': 'Chairs'},
      },
    });
    expect(d.openedByName, 'Bob Renter');
    expect(d.bookingEquipmentTitle, 'Chairs');
    expect(d.isOpen, isFalse);
    expect(d.isDecided, isFalse);
  });

  test('Admin dashboard and analytics', () {
    final AdminStats s = AdminStats.fromJson(<String, dynamic>{
      'totalUsers': 4,
      'totalRevenue': '1500',
      'openDisputes': 1,
    });
    expect(s.totalUsers, 4);
    expect(s.totalRevenue, 1500);
    expect(s.openDisputes, 1);

    final AdminAnalytics a = AdminAnalytics.fromJson(<String, dynamic>{
      'newUsers': 1,
      'topEquipment': <dynamic>[
        <String, dynamic>{'id': 'e1', 'title': 'Tent', 'category': 'TENTS'},
      ],
    });
    expect(a.topEquipment.single.category, EquipmentCategory.tents);
  });
}
