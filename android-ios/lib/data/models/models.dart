/// Domain models mirroring the JSON the NestJS API actually returns.
///
/// Every constructor takes the raw decoded map so a schema addition on the
/// server can never crash the app: unknown keys are ignored, and a changed
/// type falls back to a safe default through the helpers in `parsing.dart`.
library;

import '../../core/utils/parsing.dart';

// ------------------------------------------------------------------- users

enum UserRole {
  renter('RENTER', 'Renter'),
  owner('OWNER', 'Owner'),
  admin('ADMIN', 'Admin');

  const UserRole(this.wire, this.label);
  final String wire;
  final String label;

  static UserRole fromWire(String? value) => UserRole.values.firstWhere(
        (UserRole r) => r.wire == value,
        orElse: () => UserRole.renter,
      );
}

class AppUser {
  const AppUser({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.roles,
    required this.isVerified,
    this.email,
    this.nationalId,
    this.profileImage,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.isBanned = false,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: asString(json['id']),
        phone: asString(json['phone']),
        fullName: asString(json['fullName']),
        email: asStringOrNull(json['email']),
        nationalId: asStringOrNull(json['nationalId']),
        profileImage: asStringOrNull(json['profileImage']),
        roles: asStringEnumList(json['roles']).map(UserRole.fromWire).toList(),
        isVerified: asBool(json['isVerified']),
        isBanned: asBool(json['isBanned']),
        averageRating: asDouble(json['averageRating']),
        totalReviews: asInt(json['totalReviews']),
        createdAt: asDateOrNull(json['createdAt']),
      );

  final String id;
  final String phone;
  final String fullName;
  final String? email;
  final String? nationalId;
  final String? profileImage;
  final List<UserRole> roles;
  final bool isVerified;
  final bool isBanned;
  final double averageRating;
  final int totalReviews;
  final DateTime? createdAt;

  bool get isOwner => roles.contains(UserRole.owner);
  bool get isAdmin => roles.contains(UserRole.admin);

  /// Two letters for the avatar fallback.
  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.take(1) + parts.last.characters.take(1))
        .toUpperCase();
  }

  /// Masked phone for display in the profile header: 078 000 0003 → 078 ••• •003.
  String get maskedPhone {
    if (phone.length < 4) return phone;
    final String head = phone.substring(0, phone.length - 6);
    return '$head ••• ${phone.substring(phone.length - 3)}';
  }

  AppUser copyWith({
    String? fullName,
    String? email,
    String? nationalId,
    String? profileImage,
    List<UserRole>? roles,
    bool? isVerified,
    double? averageRating,
    int? totalReviews,
  }) =>
      AppUser(
        id: id,
        phone: phone,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        nationalId: nationalId ?? this.nationalId,
        profileImage: profileImage ?? this.profileImage,
        roles: roles ?? this.roles,
        isVerified: isVerified ?? this.isVerified,
        isBanned: isBanned,
        averageRating: averageRating ?? this.averageRating,
        totalReviews: totalReviews ?? this.totalReviews,
        createdAt: createdAt,
      );
}

/// A trimmed public profile (`users.service.ts` selects a subset of columns).
class PublicProfile {
  const PublicProfile({
    required this.id,
    required this.fullName,
    required this.roles,
    this.profileImage,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.createdAt,
  });

  factory PublicProfile.fromJson(Map<String, dynamic> json) => PublicProfile(
        id: asString(json['id']),
        fullName: asString(json['fullName']),
        profileImage: asStringOrNull(json['profileImage']),
        averageRating: asDouble(json['averageRating']),
        totalReviews: asInt(json['totalReviews']),
        roles: asStringEnumList(json['roles']).map(UserRole.fromWire).toList(),
        createdAt: asDateOrNull(json['createdAt']),
      );

  final String id;
  final String fullName;
  final String? profileImage;
  final double averageRating;
  final int totalReviews;
  final List<UserRole> roles;
  final DateTime? createdAt;

  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.take(1) + parts.last.characters.take(1))
        .toUpperCase();
  }

  bool get isOwner => roles.contains(UserRole.owner);
}

// -------------------------------------------------------------- equipment

enum EquipmentCategory {
  chairs('CHAIRS', 'Chairs & Seating'),
  tables('TABLES', 'Tables & High Tables'),
  tents('TENTS', 'Tents & Canopies'),
  speakers('SPEAKERS', 'Sound & Audio'),
  lights('LIGHTS', 'Lighting & Stage FX'),
  coolers('COOLERS', 'Coolers & Catering'),
  generators('GENERATORS', 'Power & Generators'),
  decorations('DECORATIONS', 'Decorations & Backdrops'),
  other('OTHER', 'Other Event Supplies');

  const EquipmentCategory(this.wire, this.label);
  final String wire;
  final String label;

  static EquipmentCategory fromWire(String? value) =>
      EquipmentCategory.values.firstWhere(
        (EquipmentCategory c) => c.wire == value,
        orElse: () => EquipmentCategory.other,
      );
}

/// Lightweight owner/reference shape embedded in listings and bookings.
class UserRef {
  const UserRef({
    required this.id,
    required this.fullName,
    this.profileImage,
    this.phone,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  factory UserRef.fromJson(Map<String, dynamic> json) => UserRef(
        id: asString(json['id']),
        fullName: asString(json['fullName']),
        profileImage: asStringOrNull(json['profileImage']),
        phone: asStringOrNull(json['phone']),
        averageRating: asDouble(json['averageRating']),
        totalReviews: asInt(json['totalReviews']),
      );

  final String id;
  final String fullName;
  final String? profileImage;
  final String? phone;
  final double averageRating;
  final int totalReviews;

  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.take(1) + parts.last.characters.take(1))
        .toUpperCase();
  }
}

class Equipment {
  const Equipment({
    required this.id,
    required this.title,
    required this.category,
    required this.quantity,
    required this.pricePerDay,
    required this.location,
    required this.isAvailable,
    this.ownerId = '',
    this.description,
    this.depositAmount,
    this.latitude,
    this.longitude,
    this.images = const <String>[],
    this.isApproved = true,
    this.isBoosted = false,
    this.boostedUntil,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.owner,
    this.availability = const <AvailabilityDay>[],
    this.createdAt,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        id: asString(json['id']),
        ownerId: asString(json['ownerId']),
        title: asString(json['title']),
        description: asStringOrNull(json['description']),
        category: EquipmentCategory.fromWire(asStringOrNull(json['category'])),
        quantity: asInt(json['quantity']),
        pricePerDay: asDouble(json['pricePerDay']),
        depositAmount:
            json['depositAmount'] == null ? null : asDouble(json['depositAmount']),
        location: asString(json['location']),
        latitude: json['latitude'] == null ? null : asDouble(json['latitude']),
        longitude:
            json['longitude'] == null ? null : asDouble(json['longitude']),
        images: asStringList(json['images']),
        isAvailable: asBool(json['isAvailable'], true),
        isApproved: asBool(json['isApproved'], true),
        isBoosted: asBool(json['isBoosted']),
        boostedUntil: asDateOrNull(json['boostedUntil']),
        averageRating: asDouble(json['averageRating']),
        totalReviews: asInt(json['totalReviews']),
        owner: json['owner'] == null
            ? null
            : UserRef.fromJson(asMap(json['owner'])),
        availability: asMapList(json['availability'])
            .map(AvailabilityDay.fromJson)
            .toList(),
        createdAt: asDateOrNull(json['createdAt']),
      );

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
  final UserRef? owner;
  final List<AvailabilityDay> availability;
  final DateTime? createdAt;

  bool get boostIsActive =>
      isBoosted && boostedUntil != null && boostedUntil!.isAfter(DateTime.now());

  bool get hasDeposit => (depositAmount ?? 0) > 0;

  /// Set of dates the owner explicitly blocked. Dates absent from the list are
  /// available by default — that is exactly how `EquipmentService.findAll`
  /// treats the availability table.
  Set<DateTime> get blockedDates => availability
      .where((AvailabilityDay d) => !d.isAvailable)
      .map((AvailabilityDay d) => DateUtils.dateOnly(d.date))
      .toSet();

  Set<DateTime> get openDates => availability
      .where((AvailabilityDay d) => d.isAvailable)
      .map((AvailabilityDay d) => DateUtils.dateOnly(d.date))
      .toSet();

  Equipment copyWith({
    String? title,
    String? description,
    EquipmentCategory? category,
    int? quantity,
    double? pricePerDay,
    double? depositAmount,
    String? location,
    List<String>? images,
    bool? isAvailable,
    bool? isBoosted,
    DateTime? boostedUntil,
    double? averageRating,
    int? totalReviews,
  }) =>
      Equipment(
        id: id,
        ownerId: ownerId,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        pricePerDay: pricePerDay ?? this.pricePerDay,
        depositAmount: depositAmount ?? this.depositAmount,
        location: location ?? this.location,
        latitude: latitude,
        longitude: longitude,
        images: images ?? this.images,
        isAvailable: isAvailable ?? this.isAvailable,
        isApproved: isApproved,
        isBoosted: isBoosted ?? this.isBoosted,
        boostedUntil: boostedUntil ?? this.boostedUntil,
        averageRating: averageRating ?? this.averageRating,
        totalReviews: totalReviews ?? this.totalReviews,
        owner: owner,
        availability: availability,
        createdAt: createdAt,
      );
}

class AvailabilityDay {
  const AvailabilityDay({
    required this.id,
    required this.date,
    required this.isAvailable,
  });

  factory AvailabilityDay.fromJson(Map<String, dynamic> json) =>
      AvailabilityDay(
        id: asString(json['id']),
        date: asDate(json['date']),
        isAvailable: asBool(json['isAvailable'], true),
      );

  final String id;
  final DateTime date;
  final bool isAvailable;
}

// --------------------------------------------------------------- bookings

enum BookingStatus {
  pending('PENDING', 'Pending', 'Waiting for the owner to respond'),
  accepted('ACCEPTED', 'Accepted', 'Confirmed — arrange the handover'),
  rejected('REJECTED', 'Rejected', 'The owner declined this request'),
  cancelled('CANCELLED', 'Cancelled', 'This booking was cancelled'),
  ongoing('ONGOING', 'Ongoing', 'The rental is in progress'),
  completed('COMPLETED', 'Completed', 'Rental finished'),
  disputed('DISPUTED', 'Disputed', 'Under dispute review');

  const BookingStatus(this.wire, this.label, this.hint);
  final String wire;
  final String label;
  final String hint;

  static BookingStatus fromWire(String? value) => BookingStatus.values
      .firstWhere((BookingStatus s) => s.wire == value,
          orElse: () => BookingStatus.pending);

  bool get isTerminal =>
      this == BookingStatus.rejected ||
      this == BookingStatus.cancelled ||
      this == BookingStatus.completed;
}

enum PaymentStatus {
  pending('PENDING', 'Pending'),
  paid('PAID', 'Paid'),
  refunded('REFUNDED', 'Refunded'),
  failed('FAILED', 'Failed');

  const PaymentStatus(this.wire, this.label);
  final String wire;
  final String label;

  static PaymentStatus fromWire(String? value) => PaymentStatus.values
      .firstWhere((PaymentStatus s) => s.wire == value,
          orElse: () => PaymentStatus.pending);
}

class Booking {
  const Booking({
    required this.id,
    required this.equipmentId,
    required this.renterId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.quantity,
    required this.totalPrice,
    required this.commissionAmount,
    required this.status,
    required this.paymentStatus,
    this.depositAmount = 0,
    this.notes,
    this.equipment,
    this.renter,
    this.owner,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> equipmentJson = asMap(json['equipment']);
    return Booking(
      id: asString(json['id']),
      equipmentId: asString(json['equipmentId']),
      renterId: asString(json['renterId']),
      ownerId: asString(json['ownerId']),
      startDate: asDate(json['startDate']),
      endDate: asDate(json['endDate']),
      quantity: asInt(json['quantity']),
      totalPrice: asDouble(json['totalPrice']),
      commissionAmount: asDouble(json['commissionAmount']),
      depositAmount: asDouble(json['depositAmount']),
      status: BookingStatus.fromWire(asStringOrNull(json['status'])),
      paymentStatus:
          PaymentStatus.fromWire(asStringOrNull(json['paymentStatus'])),
      notes: asStringOrNull(json['notes']),
      equipment: equipmentJson.isEmpty
          ? null
          : Equipment.fromJson(equipmentJson),
      renter: json['renter'] == null
          ? null
          : UserRef.fromJson(asMap(json['renter'])),
      owner:
          json['owner'] == null ? null : UserRef.fromJson(asMap(json['owner'])),
      createdAt: asDateOrNull(json['createdAt']),
    );
  }

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
  final Equipment? equipment;
  final UserRef? renter;
  final UserRef? owner;
  final DateTime? createdAt;

  /// Mirrors `BookingsService.rentalDays`: inclusive day count, minimum 1.
  int get days {
    final DateTime a = DateTime(startDate.year, startDate.month, startDate.day);
    final DateTime b = DateTime(endDate.year, endDate.month, endDate.day);
    return b.difference(a).inDays + 1 < 1 ? 1 : b.difference(a).inDays + 1;
  }

  double get unitPrice => quantity == 0 ? 0 : totalPrice / quantity / days;

  /// What the owner receives once the platform commission is removed.
  double get ownerPayout => totalPrice - commissionAmount;

  bool isRenter(String userId) => renterId == userId;
  bool isOwner(String userId) => ownerId == userId;

  bool isParty(String userId) => isRenter(userId) || isOwner(userId);

  Booking copyWith({
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? endDate,
    double? totalPrice,
    double? commissionAmount,
  }) =>
      Booking(
        id: id,
        equipmentId: equipmentId,
        renterId: renterId,
        ownerId: ownerId,
        startDate: startDate,
        endDate: endDate ?? this.endDate,
        quantity: quantity,
        totalPrice: totalPrice ?? this.totalPrice,
        commissionAmount: commissionAmount ?? this.commissionAmount,
        depositAmount: depositAmount,
        status: status ?? this.status,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        notes: notes,
        equipment: equipment,
        renter: renter,
        owner: owner,
        createdAt: createdAt,
      );
}

class BookingTimelineEntry {
  const BookingTimelineEntry({
    required this.id,
    required this.status,
    required this.createdAt,
    this.note,
    this.actor,
  });

  factory BookingTimelineEntry.fromJson(Map<String, dynamic> json) =>
      BookingTimelineEntry(
        id: asString(json['id']),
        status: BookingStatus.fromWire(asStringOrNull(json['status'])),
        note: asStringOrNull(json['note']),
        createdAt: asDate(json['createdAt']),
        actor:
            json['actor'] == null ? null : UserRef.fromJson(asMap(json['actor'])),
      );

  final String id;
  final BookingStatus status;
  final String? note;
  final DateTime createdAt;
  final UserRef? actor;
}

// --------------------------------------------------------------- payments

enum MobileMoneyProvider {
  momo('MOMO', 'MTN Mobile Money', '078'),
  airtel('AIRTEL', 'Airtel Money', '073');

  const MobileMoneyProvider(this.wire, this.label, this.dialPrefix);
  final String wire;
  final String label;
  final String dialPrefix;

  /// MTN lines are 078/079, Airtel lines are 072/073.
  bool ownsPhone(String phone) => phone.startsWith(dialPrefix);

  static MobileMoneyProvider? forPhone(String phone) {
    for (final MobileMoneyProvider p in MobileMoneyProvider.values) {
      if (p.ownsPhone(phone)) return p;
    }
    return null;
  }
}

class PaymentIntent {
  const PaymentIntent({
    required this.paymentRef,
    required this.transactionId,
    required this.amount,
    required this.provider,
    required this.message,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) => PaymentIntent(
        paymentRef: asString(json['paymentRef']),
        transactionId: asString(json['transactionId']),
        amount: asDouble(json['amount']),
        provider:
            MobileMoneyProvider.values.firstWhere(
          (MobileMoneyProvider p) => p.wire == asStringOrNull(json['provider']),
          orElse: () => MobileMoneyProvider.momo,
        ),
        message: asString(json['message']),
      );

  final String paymentRef;
  final String transactionId;
  final double amount;
  final MobileMoneyProvider provider;
  final String message;
}

enum TransactionType {
  commission('COMMISSION', 'Platform commission'),
  payout('PAYOUT', 'Rental payout'),
  boost('BOOST', 'Listing boost'),
  rental('RENTAL', 'Rental payment'),
  withdrawal('WITHDRAWAL', 'Withdrawal'),
  refund('REFUND', 'Refund');

  const TransactionType(this.wire, this.label);
  final String wire;
  final String label;

  static TransactionType fromWire(String? value) => TransactionType.values
      .firstWhere((TransactionType t) => t.wire == value,
          orElse: () => TransactionType.rental);
}

class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    this.bookingId,
    this.userId = '',
    this.provider,
    this.providerRef,
    this.createdAt,
    this.booking,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: asString(json['id']),
        bookingId: asStringOrNull(json['bookingId']),
        userId: asString(json['userId']),
        amount: asDouble(json['amount']),
        type: TransactionType.fromWire(asStringOrNull(json['type'])),
        provider: asStringOrNull(json['provider']),
        providerRef: asStringOrNull(json['providerRef']),
        status:
            PaymentStatus.fromWire(asStringOrNull(json['status'])),
        createdAt: asDateOrNull(json['createdAt']),
        booking: json['booking'] == null
            ? null
            : _TransactionBooking.fromJson(asMap(json['booking'])),
      );

  final String id;
  final String? bookingId;
  final String userId;
  final double amount;
  final TransactionType type;
  final String? provider;
  final String? providerRef;
  final PaymentStatus status;
  final DateTime? createdAt;
  final _TransactionBooking? booking;
}

class _TransactionBooking {
  const _TransactionBooking({
    this.id = '',
    this.status,
    this.equipmentId,
    this.equipmentTitle,
    this.startDate,
    this.endDate,
  });

  factory _TransactionBooking.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> equipment = asMap(json['equipment']);
    return _TransactionBooking(
      id: asString(json['id']),
      status: json['status'] == null
          ? null
          : BookingStatus.fromWire(asStringOrNull(json['status'])),
      equipmentId: asStringOrNull(json['equipmentId']) ??
          asStringOrNull(equipment['id']),
      equipmentTitle:
          asStringOrNull(json['equipmentTitle']) ?? asStringOrNull(equipment['title']),
      startDate: asDateOrNull(json['startDate']),
      endDate: asDateOrNull(json['endDate']),
    );
  }

  final String id;
  final BookingStatus? status;
  final String? equipmentId;
  final String? equipmentTitle;
  final DateTime? startDate;
  final DateTime? endDate;
}

class EarningsBreakdown {
  const EarningsBreakdown({
    required this.totalEarnings,
    required this.byMonth,
    required this.payouts,
  });

  factory EarningsBreakdown.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> months = asMap(json['byMonth']);
    return EarningsBreakdown(
      totalEarnings: asDouble(json['totalEarnings']),
      byMonth: months.map(
        (String key, Object? value) => MapEntry<String, double>(
          key,
          asDouble(value),
        ),
      ),
      payouts: asMapList(json['payouts']).map(Payout.fromJson).toList(),
    );
  }

  final double totalEarnings;

  /// `{"2026-10": 45000, "2026-09": 12000}` — newest month first for display.
  final Map<String, double> byMonth;
  final List<Payout> payouts;

  List<MapEntry<String, double>> get orderedMonths {
    final List<MapEntry<String, double>> entries = byMonth.entries.toList()
      ..sort((MapEntry<String, double> a, MapEntry<String, double> b) =>
          b.key.compareTo(a.key));
    return entries;
  }

  double get peakMonth => byMonth.values.fold<double>(
        0,
        (double max, double v) => v > max ? v : max,
      );
}

class Payout {
  const Payout({required this.id, required this.amount, this.createdAt, this.booking});

  factory Payout.fromJson(Map<String, dynamic> json) => Payout(
        id: asString(json['id']),
        amount: asDouble(json['amount']),
        createdAt: asDateOrNull(json['createdAt']),
        booking: json['booking'] == null
            ? null
            : _TransactionBooking.fromJson(asMap(json['booking'])),
      );

  final String id;
  final double amount;
  final DateTime? createdAt;
  final _TransactionBooking? booking;

  String get title => booking?.equipmentTitle ?? 'Rental payout';
}

enum WithdrawalStatus {
  pending('PENDING', 'Pending'),
  approved('APPROVED', 'Approved'),
  rejected('REJECTED', 'Rejected'),
  completed('COMPLETED', 'Completed');

  const WithdrawalStatus(this.wire, this.label);
  final String wire;
  final String label;

  static WithdrawalStatus fromWire(String? value) => WithdrawalStatus.values
      .firstWhere((WithdrawalStatus s) => s.wire == value,
          orElse: () => WithdrawalStatus.pending);
}

class Withdrawal {
  const Withdrawal({
    required this.id,
    required this.amount,
    required this.phone,
    required this.provider,
    required this.status,
    this.note,
    this.createdAt,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) => Withdrawal(
        id: asString(json['id']),
        amount: asDouble(json['amount']),
        phone: asString(json['phone']),
        provider: asStringOrNull(json['provider']) ?? '',
        status:
            WithdrawalStatus.fromWire(asStringOrNull(json['status'])),
        note: asStringOrNull(json['note']),
        createdAt: asDateOrNull(json['createdAt']),
      );

  final String id;
  final double amount;
  final String phone;
  final String provider;
  final WithdrawalStatus status;
  final String? note;
  final DateTime? createdAt;
}

// ---------------------------------------------------------------- reviews

class Review {
  const Review({
    required this.id,
    required this.rating,
    this.bookingId,
    this.comment,
    this.createdAt,
    this.fromUser,
    this.toUser,
    this.equipmentId,
    this.equipmentTitle,
    this.equipmentImages = const <String>[],
    this.bookingStartDate,
    this.bookingEndDate,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> equipment = asMap(json['equipment']);
    final Map<String, dynamic> booking = asMap(json['booking']);
    return Review(
      id: asString(json['id']),
      bookingId: asStringOrNull(json['bookingId']),
      rating: asInt(json['rating']),
      comment: asStringOrNull(json['comment']),
      createdAt: asDateOrNull(json['createdAt']),
      fromUser: json['fromUser'] == null
          ? null
          : UserRef.fromJson(asMap(json['fromUser'])),
      toUser:
          json['toUser'] == null ? null : UserRef.fromJson(asMap(json['toUser'])),
      equipmentId: asStringOrNull(json['equipmentId']) ??
          asStringOrNull(equipment['id']),
      equipmentTitle: asStringOrNull(equipment['title']),
      equipmentImages: asStringList(equipment['images']),
      bookingStartDate: asDateOrNull(booking['startDate']),
      bookingEndDate: asDateOrNull(booking['endDate']),
    );
  }

  final String id;
  final String? bookingId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final UserRef? fromUser;
  final UserRef? toUser;
  final String? equipmentId;
  final String? equipmentTitle;
  final List<String> equipmentImages;
  final DateTime? bookingStartDate;
  final DateTime? bookingEndDate;
}

// ------------------------------------------------------------------- chat

class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    this.bookingId,
    this.createdAt,
    this.sender,
    this.receiver,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: asString(json['id']),
        senderId: asString(json['senderId']),
        receiverId: asString(json['receiverId']),
        content: asString(json['content']),
        isRead: asBool(json['isRead']),
        bookingId: asStringOrNull(json['bookingId']),
        createdAt: asDateOrNull(json['createdAt']),
        sender:
            json['sender'] == null ? null : UserRef.fromJson(asMap(json['sender'])),
        receiver: json['receiver'] == null
            ? null
            : UserRef.fromJson(asMap(json['receiver'])),
      );

  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final String? bookingId;
  final DateTime? createdAt;
  final UserRef? sender;
  final UserRef? receiver;
}

class Conversation {
  const Conversation({
    required this.user,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> last = asMap(json['lastMessage']);
    return Conversation(
      user: UserRef.fromJson(asMap(json['user'])),
      lastMessage: Message.fromJson({
        'id': last['id'],
        'senderId': last['senderId'],
        'receiverId': '',
        'content': last['content'],
        'isRead': last['isRead'],
        'bookingId': last['bookingId'],
        'createdAt': last['createdAt'],
      }),
      unreadCount: asInt(json['unreadCount']),
    );
  }

  final UserRef user;
  final Message lastMessage;
  final int unreadCount;
}

// ---------------------------------------------------------- notifications

enum NotificationType {
  booking('BOOKING', 'Booking'),
  payment('PAYMENT', 'Payment'),
  chat('CHAT', 'Message'),
  review('REVIEW', 'Review'),
  system('SYSTEM', 'System'),
  dispute('DISPUTE', 'Dispute');

  const NotificationType(this.wire, this.label);
  final String wire;
  final String label;

  static NotificationType fromWire(String? value) => NotificationType.values
      .firstWhere((NotificationType t) => t.wire == value,
          orElse: () => NotificationType.system);
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.data = const <String, dynamic>{},
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: asString(json['id']),
        title: asString(json['title']),
        body: asString(json['body']),
        type: NotificationType.fromWire(asStringOrNull(json['type'])),
        isRead: asBool(json['isRead']),
        data: asMap(json['data']),
        createdAt: asDateOrNull(json['createdAt']),
      );

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic> data;
  final DateTime? createdAt;

  String? get bookingId => asStringOrNull(data['bookingId']);
}

class NotificationSettings {
  const NotificationSettings({
    required this.bookingAlerts,
    required this.paymentAlerts,
    required this.chatAlerts,
    required this.marketingAlerts,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        bookingAlerts: asBool(json['bookingAlerts'], true),
        paymentAlerts: asBool(json['paymentAlerts'], true),
        chatAlerts: asBool(json['chatAlerts'], true),
        marketingAlerts: asBool(json['marketingAlerts']),
      );

  const NotificationSettings.defaults()
      : bookingAlerts = true,
        paymentAlerts = true,
        chatAlerts = true,
        marketingAlerts = false;

  final bool bookingAlerts;
  final bool paymentAlerts;
  final bool chatAlerts;
  final bool marketingAlerts;

  NotificationSettings copyWith({
    bool? bookingAlerts,
    bool? paymentAlerts,
    bool? chatAlerts,
    bool? marketingAlerts,
  }) =>
      NotificationSettings(
        bookingAlerts: bookingAlerts ?? this.bookingAlerts,
        paymentAlerts: paymentAlerts ?? this.paymentAlerts,
        chatAlerts: chatAlerts ?? this.chatAlerts,
        marketingAlerts: marketingAlerts ?? this.marketingAlerts,
      );
}

// ------------------------------------------------------------- favorites

class FavoriteEntry {
  const FavoriteEntry({
    required this.id,
    required this.equipment,
    this.createdAt,
  });

  factory FavoriteEntry.fromJson(Map<String, dynamic> json) => FavoriteEntry(
        id: asString(json['id']),
        equipment: Equipment.fromJson(asMap(json['equipment'])),
        createdAt: asDateOrNull(json['createdAt']),
      );

  final String id;
  final Equipment equipment;
  final DateTime? createdAt;
}

// ------------------------------------------------- reports and disputes

class Report {
  const Report({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    this.details,
    this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: asString(json['id']),
        targetType: asString(json['targetType']),
        targetId: asString(json['targetId']),
        reason: asString(json['reason']),
        details: asStringOrNull(json['details']),
        status: asString(json['status'], 'OPEN'),
        createdAt: asDateOrNull(json['createdAt']),
      );

  final String id;
  final String targetType;
  final String targetId;
  final String reason;
  final String? details;
  final String status;
  final DateTime? createdAt;
}

class Dispute {
  const Dispute({
    required this.id,
    required this.bookingId,
    required this.reason,
    required this.status,
    this.response,
    this.resolution,
    this.createdAt,
    this.bookingEquipmentTitle,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> booking = asMap(json['booking']);
    final Map<String, dynamic> equipment = asMap(booking['equipment']);
    return Dispute(
      id: asString(json['id']),
      bookingId: asString(json['bookingId']),
      reason: asString(json['reason']),
      response: asStringOrNull(json['response']),
      resolution: asStringOrNull(json['resolution']),
      status: asString(json['status'], 'OPEN'),
      createdAt: asDateOrNull(json['createdAt']),
      bookingEquipmentTitle: asStringOrNull(equipment['title']),
    );
  }

  final String id;
  final String bookingId;
  final String reason;
  final String? response;
  final String? resolution;
  final String status;
  final DateTime? createdAt;
  final String? bookingEquipmentTitle;
}

// ---------------------------------------------------------------- system

class PlatformConfig {
  const PlatformConfig({
    required this.appName,
    required this.currency,
    required this.commissionRate,
    required this.boostTiers,
    required this.paymentMethods,
    this.supportPhone,
    this.supportEmail,
    this.supportWhatsApp,
  });

  factory PlatformConfig.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> support = asMap(json['support']);
    return PlatformConfig(
      appName: asString(json['appName'], 'Neo'),
      currency: asString(json['currency'], 'RWF'),
      commissionRate: asDouble(json['commissionRate'], 0.1),
      boostTiers: asMapList(json['boostPricingTiers'])
          .map(BoostTier.fromJson)
          .toList(),
      paymentMethods: asMapList(json['paymentMethods'])
          .map((Map<String, dynamic> m) => asString(m['name']))
          .toList(),
      supportPhone: asStringOrNull(support['phone']),
      supportWhatsApp: asStringOrNull(support['whatsapp']),
      supportEmail: asStringOrNull(support['email']),
    );
  }

  const PlatformConfig.fallback()
      : appName = 'Neo',
        currency = 'RWF',
        commissionRate = 0.1,
        boostTiers = const <BoostTier>[],
        paymentMethods = const <String>[],
        supportPhone = null,
        supportWhatsApp = null,
        supportEmail = null;

  final String appName;
  final String currency;
  final double commissionRate;
  final List<BoostTier> boostTiers;
  final List<String> paymentMethods;
  final String? supportPhone;
  final String? supportWhatsApp;
  final String? supportEmail;
}

class BoostTier {
  const BoostTier({
    required this.durationDays,
    required this.price,
    required this.label,
  });

  factory BoostTier.fromJson(Map<String, dynamic> json) => BoostTier(
        durationDays: asInt(json['durationDays']),
        price: asDouble(json['price']),
        label: asString(json['label']),
      );

  final int durationDays;
  final double price;
  final String label;
}

class CategoryInfo {
  const CategoryInfo({
    required this.code,
    required this.name,
    required this.description,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) => CategoryInfo(
        code: asString(json['code']),
        name: asString(json['name']),
        description: asString(json['description']),
      );

  /// Local fallback used when `/system/categories` is unreachable.
  factory CategoryInfo.local(EquipmentCategory category) => CategoryInfo(
        code: category.wire,
        name: category.label,
        description: '',
      );

  final String code;
  final String name;
  final String description;

  EquipmentCategory get category => EquipmentCategory.fromWire(code);
}

class RwandaLocation {
  const RwandaLocation({required this.province, required this.districts});

  factory RwandaLocation.fromJson(Map<String, dynamic> json) =>
      RwandaLocation(
        province: asString(json['province']),
        districts: asStringList(json['districts']),
      );

  final String province;
  final List<String> districts;
}

/// Auth session payload: `accessToken`, `refreshToken` and the user snapshot.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: asString(json['accessToken']),
        refreshToken: asString(json['refreshToken']),
        user: AppUser.fromJson(asMap(json['user'])),
      );

  final String accessToken;
  final String refreshToken;
  final AppUser user;
}

/// Result of `POST /auth/send-otp` — `devOtp` is present outside production.
class OtpDispatch {
  const OtpDispatch({
    required this.message,
    required this.expiresInMinutes,
    this.devOtp,
  });

  factory OtpDispatch.fromJson(Map<String, dynamic> json) => OtpDispatch(
        message: asString(json['message'], 'OTP sent'),
        expiresInMinutes: asInt(json['expiresInMinutes'], 10),
        devOtp: asStringOrNull(json['devOtp']),
      );

  final String message;
  final int expiresInMinutes;

  /// Surfaced in the OTP screen during development so the flow is testable
  /// without an SMS gateway. Absent in production builds.
  final String? devOtp;
}