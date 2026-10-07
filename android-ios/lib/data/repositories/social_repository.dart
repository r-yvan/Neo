import '../../core/network/api_paths.dart';
import '../../core/utils/parsing.dart';
import '../models/models.dart';
import 'users_repository.dart';

class PaymentsRepository {
  PaymentsRepository(this._get, this._post);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;
  final Future<dynamic> Function(String path, {Object? body}) _post;

  /// Only accepted bookings can be paid. Returns the reference the renter
  /// must confirm (in this build the provider webhook or `confirm`).
  Future<PaymentIntent> initiate({
    required String bookingId,
    required MobileMoneyProvider provider,
  }) async =>
      PaymentIntent.fromJson(
          asMap(await _post(ApiPaths.paymentsInitiate, body: {
        'bookingId': bookingId,
        'provider': provider.wire,
      })));

  Future<bool> confirm(String paymentRef) async {
    final dynamic res =
        await _post(ApiPaths.paymentsConfirm, body: {'paymentRef': paymentRef});
    return asString(asMap(res)['message']).toLowerCase().contains('confirm');
  }

  Future<PaginatedList<Transaction>> history({
    int page = 1,
    int limit = 20,
  }) async {
    final dynamic res = await _get(ApiPaths.paymentsHistory,
        query: {'page': page, 'limit': limit});
    final Map<String, dynamic> map = asMap(res);
    return PaginatedList<Transaction>(
      items: asMapList(map['data']).map(Transaction.fromJson).toList(),
      meta: asMap(map['meta']),
    );
  }

  Future<double> earnings() async {
    final dynamic res = await _get(ApiPaths.paymentsEarnings);
    return asDouble(asMap(res)['totalEarnings']);
  }

  Future<EarningsBreakdown> earningsBreakdown() async =>
      EarningsBreakdown.fromJson(
          asMap(await _get(ApiPaths.paymentsEarningsBreakdown)));

  Future<Withdrawal> withdraw({
    required double amount,
    required String phone,
    required MobileMoneyProvider provider,
  }) async =>
      Withdrawal.fromJson(asMap(await _post(ApiPaths.paymentsWithdraw, body: {
        'amount': amount,
        'phone': phone,
        'provider': provider.wire,
      })));

  Future<PaginatedList<Withdrawal>> withdrawals({
    int page = 1,
    int limit = 20,
  }) async {
    final dynamic res = await _get(ApiPaths.paymentsWithdrawals,
        query: {'page': page, 'limit': limit});
    final Map<String, dynamic> map = asMap(res);
    return PaginatedList<Withdrawal>(
      items: asMapList(map['data']).map(Withdrawal.fromJson).toList(),
      meta: asMap(map['meta']),
    );
  }
}

class ReviewsRepository {
  ReviewsRepository(this._get, this._post, this._patch, this._delete);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;
  final Future<dynamic> Function(String path, {Object? body}) _post;
  final Future<dynamic> Function(String path, {Object? body}) _patch;
  final Future<dynamic> Function(String path, {Object? body}) _delete;

  /// Renter only, and only once the booking is COMPLETED — enforced server-side.
  Future<Review> create({
    required String bookingId,
    required int rating,
    String? comment,
  }) async =>
      Review.fromJson(asMap(await _post(ApiPaths.reviews, body: {
        'bookingId': bookingId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      })));

  Future<PaginatedList<Review>> given({int page = 1, int limit = 20}) async =>
      _page(await _get(ApiPaths.reviewsMy,
          query: {'page': page, 'limit': limit}));

  Future<PaginatedList<Review>> forEquipment(String equipmentId,
          {int page = 1, int limit = 20}) async =>
      _page(await _get(ApiPaths.reviewsForEquipment(equipmentId),
          query: {'page': page, 'limit': limit}));

  Future<PaginatedList<Review>> forUser(String userId,
          {int page = 1, int limit = 20}) async =>
      _page(await _get(ApiPaths.reviewsForUser(userId),
          query: {'page': page, 'limit': limit}));

  Future<Review> update(String id, {int? rating, String? comment}) async =>
      Review.fromJson(asMap(await _patch(ApiPaths.review(id), body: {
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
      })));

  Future<void> delete(String id) => _delete(ApiPaths.review(id));
}

PaginatedList<Review> _reviewPage(dynamic res) {
  final Map<String, dynamic> map = asMap(res);
  return PaginatedList<Review>(
    items: asMapList(map['data']).map(Review.fromJson).toList(),
    meta: asMap(map['meta']),
  );
}

PaginatedList<AppNotification> _notificationPage(dynamic res) {
  final Map<String, dynamic> map = asMap(res);
  return PaginatedList<AppNotification>(
    items: asMapList(map['data']).map(AppNotification.fromJson).toList(),
    meta: asMap(map['meta']),
  );
}

class FavoritesRepository {
  FavoritesRepository(this._get, this._post, this._delete);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;
  final Future<dynamic> Function(String path, {Object? body}) _post;
  final Future<dynamic> Function(String path, {Object? body}) _delete;

  Future<PaginatedList<FavoriteEntry>> list(
      {int page = 1, int limit = 20}) async {
    final dynamic res =
        await _get(ApiPaths.favorites, query: {'page': page, 'limit': limit});
    final Map<String, dynamic> map = asMap(res);
    return PaginatedList<FavoriteEntry>(
      items: asMapList(map['data']).map(FavoriteEntry.fromJson).toList(),
      meta: asMap(map['meta']),
    );
  }

  Future<void> add(String equipmentId) => _post(ApiPaths.favorite(equipmentId));

  Future<void> remove(String equipmentId) =>
      _delete(ApiPaths.favorite(equipmentId));
}

class NotificationsRepository {
  NotificationsRepository(this._get, this._post, this._patch, this._delete);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;
  final Future<dynamic> Function(String path, {Object? body}) _post;
  final Future<dynamic> Function(String path, {Object? body}) _patch;
  final Future<dynamic> Function(String path, {Object? body}) _delete;

  Future<PaginatedList<AppNotification>> list({
    int page = 1,
    int limit = 20,
  }) async =>
      _notificationPage(await _get(ApiPaths.notifications,
          query: {'page': page, 'limit': limit}));

  Future<PaginatedList<AppNotification>> unread({
    int page = 1,
    int limit = 20,
  }) async =>
      _notificationPage(await _get(ApiPaths.notificationsUnread,
          query: {'page': page, 'limit': limit}));

  Future<AppNotification> markRead(String id) async => AppNotification.fromJson(
      asMap(await _patch(ApiPaths.notificationRead(id))));

  Future<int> markAllRead() async {
    final dynamic res = await _patch(ApiPaths.notificationsReadAll);
    return asInt(asMap(res)['updated']);
  }

  Future<void> delete(String id) => _delete(ApiPaths.notification(id));

  Future<NotificationSettings> settings() async =>
      NotificationSettings.fromJson(
          asMap(await _get(ApiPaths.notificationsSettings)));

  Future<NotificationSettings> updateSettings(
          NotificationSettings value) async =>
      NotificationSettings.fromJson(asMap(await _patch(
        ApiPaths.notificationsSettings,
        body: {
          'bookingAlerts': value.bookingAlerts,
          'paymentAlerts': value.paymentAlerts,
          'chatAlerts': value.chatAlerts,
          'marketingAlerts': value.marketingAlerts,
        },
      )));
}

PaginatedList<AppNotification> _page(dynamic res) {
  final Map<String, dynamic> map = asMap(res);
  return PaginatedList<AppNotification>(
    items: asMapList(map['data']).map(AppNotification.fromJson).toList(),
    meta: asMap(map['meta']),
  );
}

class ChatRepository {
  ChatRepository(this._get, this._post, this._patch, this._delete);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;
  final Future<dynamic> Function(String path, {Object? body}) _post;
  final Future<dynamic> Function(String path, {Object? body}) _patch;
  final Future<dynamic> Function(String path, {Object? body}) _delete;

  /// Returned newest-first; the UI reverses for display.
  Future<List<Conversation>> conversations() async {
    final dynamic res = await _get(ApiPaths.chatConversations);
    return asMapList(res).map(Conversation.fromJson).toList();
  }

  Future<int> unreadCount() async {
    final dynamic res = await _get(ApiPaths.chatUnreadCount);
    return asInt(asMap(res)['count']);
  }

  Future<PaginatedList<Message>> messages(String userId,
      {int page = 1, int limit = 30}) async {
    final dynamic res = await _get(ApiPaths.chatConversation(userId),
        query: {'page': 1, 'limit': 100});
    final Map<String, dynamic> map = asMap(res);
    return PaginatedList<Message>(
      items: asMapList(map['data']).map(Message.fromJson).toList(),
      meta: asMap(map['meta']),
    );
  }

  Future<Message> send({
    required String receiverId,
    required String content,
    String? bookingId,
  }) async =>
      Message.fromJson(asMap(await _post(ApiPaths.chatSend, body: {
        'receiverId': receiverId,
        'content': content,
        if (bookingId != null) 'bookingId': bookingId,
      })));

  Future<void> markRead(String messageId) =>
      _patch(ApiPaths.chatMessageRead(messageId));

  Future<void> markConversationRead(String userId) =>
      _patch(ApiPaths.chatConversationRead(userId));

  Future<void> deleteMessage(String messageId) =>
      _delete(ApiPaths.chatMessage(messageId));
}

class TrustRepository {
  TrustRepository(this._get, this._post, this._patch);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;
  final Future<dynamic> Function(String path, {Object? body}) _post;
  final Future<dynamic> Function(String path, {Object? body}) _patch;

  Future<Report> report({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async =>
      Report.fromJson(asMap(await _post(ApiPaths.reports, body: {
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        if (details != null && details.isNotEmpty) 'details': details,
      })));

  Future<PaginatedList<Report>> myReports(
      {int page = 1, int limit = 20}) async {
    final dynamic res =
        await _get(ApiPaths.reportsMine, query: {'page': page, 'limit': limit});
    final Map<String, dynamic> map = asMap(res);
    return PaginatedList<Report>(
      items: asMapList(map['data']).map(Report.fromJson).toList(),
      meta: asMap(map['meta']),
    );
  }

  /// Opening a dispute also flips the booking into DISPUTED server-side.
  Future<Dispute> openDispute({
    required String bookingId,
    required String reason,
  }) async =>
      Dispute.fromJson(asMap(await _post(ApiPaths.disputes, body: {
        'bookingId': bookingId,
        'reason': reason,
      })));

  Future<Dispute> dispute(String id) async =>
      Dispute.fromJson(asMap(await _get(ApiPaths.dispute(id))));

  Future<Dispute> respond(String id, String response) async =>
      Dispute.fromJson(asMap(await _patch(ApiPaths.disputeRespond(id),
          body: {'response': response})));
}

class SystemRepository {
  SystemRepository(this._get);

  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;

  Future<PlatformConfig> config() async => PlatformConfig.fromJson(
      asMap(await _get(ApiPaths.systemConfig, skipAuth: true)));

  Future<List<CategoryInfo>> categories() async {
    final dynamic res = await _get(ApiPaths.systemCategories, skipAuth: true);
    return asMapList(res).map(CategoryInfo.fromJson).toList(growable: false);
  }

  Future<List<RwandaLocation>> locations() async {
    final dynamic res = await _get(ApiPaths.systemLocations, skipAuth: true);
    return asMapList(res).map(RwandaLocation.fromJson).toList(growable: false);
  }

  Future<bool> health() async {
    final dynamic res = await _get(ApiPaths.systemHealth, skipAuth: true);
    return asString(asMap(res)['status']) == 'ok';
  }
}
