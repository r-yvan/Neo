/// Read models for the admin console (`/admin/*`). Entities that already have
/// a client model (users, equipment, bookings, reviews, transactions) reuse
/// it; these classes cover the admin-only aggregates and envelopes.
library;

import '../../core/utils/parsing.dart';
import 'models.dart';

class AdminStats {
  const AdminStats({
    this.totalUsers = 0,
    this.totalEquipment = 0,
    this.totalBookings = 0,
    this.pendingBookings = 0,
    this.completedBookings = 0,
    this.totalRevenue = 0,
    this.openReports = 0,
    this.openDisputes = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
        totalUsers: asInt(json['totalUsers']),
        totalEquipment: asInt(json['totalEquipment']),
        totalBookings: asInt(json['totalBookings']),
        pendingBookings: asInt(json['pendingBookings']),
        completedBookings: asInt(json['completedBookings']),
        totalRevenue: asDouble(json['totalRevenue']),
        openReports: asInt(json['openReports']),
        openDisputes: asInt(json['openDisputes']),
      );

  final int totalUsers;
  final int totalEquipment;
  final int totalBookings;
  final int pendingBookings;
  final int completedBookings;
  final double totalRevenue;
  final int openReports;
  final int openDisputes;
}

class AdminTopEquipment {
  const AdminTopEquipment({
    required this.id,
    required this.title,
    required this.category,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  factory AdminTopEquipment.fromJson(Map<String, dynamic> json) =>
      AdminTopEquipment(
        id: asString(json['id']),
        title: asString(json['title']),
        category: EquipmentCategory.fromWire(asStringOrNull(json['category'])),
        averageRating: asDouble(json['averageRating']),
        totalReviews: asInt(json['totalReviews']),
      );

  final String id;
  final String title;
  final EquipmentCategory category;
  final double averageRating;
  final int totalReviews;
}

class AdminAnalytics {
  const AdminAnalytics({
    this.period = '30d',
    this.newUsers = 0,
    this.newBookings = 0,
    this.revenueLastMonth = 0,
    this.topEquipment = const <AdminTopEquipment>[],
  });

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) => AdminAnalytics(
        period: asString(json['period'], '30d'),
        newUsers: asInt(json['newUsers']),
        newBookings: asInt(json['newBookings']),
        revenueLastMonth: asDouble(json['revenueLastMonth']),
        topEquipment: asMapList(json['topEquipment'])
            .map(AdminTopEquipment.fromJson)
            .toList(growable: false),
      );

  final String period;
  final int newUsers;
  final int newBookings;
  final double revenueLastMonth;
  final List<AdminTopEquipment> topEquipment;
}

/// Equipment as the moderation queue sees it: the listing plus its owner.
class AdminEquipment {
  const AdminEquipment({required this.equipment, this.ownerName, this.ownerPhone});

  factory AdminEquipment.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> owner = asMap(json['owner']);
    return AdminEquipment(
      equipment: Equipment.fromJson(json),
      ownerName: asStringOrNull(owner['fullName']),
      ownerPhone: asStringOrNull(owner['phone']),
    );
  }

  final Equipment equipment;
  final String? ownerName;
  final String? ownerPhone;
}

class AdminTransaction {
  const AdminTransaction({
    required this.transaction,
    this.userName,
    this.equipmentTitle,
  });

  factory AdminTransaction.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = asMap(json['user']);
    final Map<String, dynamic> meta = asMap(json['metadata']);
    return AdminTransaction(
      transaction: Transaction.fromJson(json),
      userName: asStringOrNull(user['fullName']),
      equipmentTitle: asStringOrNull(meta['equipmentTitle']),
    );
  }

  final Transaction transaction;
  final String? userName;
  final String? equipmentTitle;
}

class AdminReport {
  const AdminReport({required this.report, this.reporterName, this.note});

  factory AdminReport.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> reporter = asMap(json['reporter']);
    return AdminReport(
      report: Report.fromJson(json),
      reporterName: asStringOrNull(reporter['fullName']),
      note: asStringOrNull(json['resolutionNote']) ?? asStringOrNull(json['note']),
    );
  }

  final Report report;
  final String? reporterName;
  final String? note;
}

class AdminDispute {
  const AdminDispute({
    required this.dispute,
    this.openedByName,
    this.renterName,
    this.ownerName,
  });

  factory AdminDispute.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> booking = asMap(json['booking']);
    return AdminDispute(
      dispute: Dispute.fromJson(json),
      openedByName: asStringOrNull(asMap(json['openedBy'])['fullName']),
      renterName: asStringOrNull(asMap(booking['renter'])['fullName']),
      ownerName: asStringOrNull(asMap(booking['owner'])['fullName']),
    );
  }

  final Dispute dispute;
  final String? openedByName;
  final String? renterName;
  final String? ownerName;
}
