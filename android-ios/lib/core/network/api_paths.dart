/// Every endpoint the backend actually exposes.
///
/// Paths are relative to `AppConfig.apiBaseUrl`, which already ends with
/// `/api/v1`. Nothing here is invented — each entry mirrors a route mapped by
/// the NestJS controllers (see the API contract notes in the root README).
library;

abstract final class ApiPaths {
  static const String _v1 = '/api/v1';

  // ------------------------------------------------------------------ auth
  static const String authRegister = '$_v1/auth/register';
  static const String authLogin = '$_v1/auth/login';
  static const String authSendOtp = '$_v1/auth/send-otp';
  static const String authVerifyOtp = '$_v1/auth/verify-otp';
  static const String authRefresh = '$_v1/auth/refresh';
  static const String authLogout = '$_v1/auth/logout';
  static const String authForgotPassword = '$_v1/auth/forgot-password';
  static const String authResetPassword = '$_v1/auth/reset-password';
  static const String authMe = '$_v1/auth/me';

  // ----------------------------------------------------------------- users
  static const String usersMe = '$_v1/users/me';
  static const String usersMeAvatar = '$_v1/users/me/avatar';
  static const String usersMeChangePassword = '$_v1/users/me/change-password';
  static const String usersMeRole = '$_v1/users/me/role';
  static const String usersMeVerifyNationalId = '$_v1/users/me/verify-national-id';
  static const String usersSearch = '$_v1/users/search';
  static String user(String id) => '$_v1/users/$id';
  static String userReviews(String id) => '$_v1/users/$id/reviews';
  static String userEquipment(String id) => '$_v1/users/$id/equipment';

  // ------------------------------------------------------------- equipment
  static const String equipment = '$_v1/equipment';
  static const String equipmentMy = '$_v1/equipment/my';
  static const String equipmentCategories = '$_v1/equipment/categories';
  static const String equipmentPopular = '$_v1/equipment/popular';
  static const String equipmentNearby = '$_v1/equipment/nearby';
  static String equipmentById(String id) => '$_v1/equipment/$id';
  static String equipmentImages(String id) => '$_v1/equipment/$id/images';
  static String equipmentImage(String id, String imageId) =>
      '$_v1/equipment/$id/images/$imageId';
  static String equipmentBoost(String id) => '$_v1/equipment/$id/boost';
  static String equipmentAvailability(String id) =>
      '$_v1/equipment/$id/availability';
  static String equipmentAvailabilityDate(String id, String date) =>
      '$_v1/equipment/$id/availability/$date';
  static String equipmentBlockDates(String id) => '$_v1/equipment/$id/block-dates';

  // -------------------------------------------------------------- bookings
  static const String bookings = '$_v1/bookings';
  static const String bookingsRenter = '$_v1/bookings/renter';
  static const String bookingsOwner = '$_v1/bookings/owner';
  static String booking(String id) => '$_v1/bookings/$id';
  static String bookingTimeline(String id) => '$_v1/bookings/$id/timeline';
  static String bookingExtend(String id) => '$_v1/bookings/$id/extend';
  static String bookingAccept(String id) => '$_v1/bookings/$id/accept';
  static String bookingReject(String id) => '$_v1/bookings/$id/reject';
  static String bookingCancel(String id) => '$_v1/bookings/$id/cancel';
  static String bookingStart(String id) => '$_v1/bookings/$id/start';
  static String bookingComplete(String id) => '$_v1/bookings/$id/complete';
  static String bookingDispute(String id) => '$_v1/bookings/$id/dispute';

  // -------------------------------------------------------------- payments
  static const String paymentsInitiate = '$_v1/payments/initiate';
  static const String paymentsConfirm = '$_v1/payments/confirm';
  static const String paymentsHistory = '$_v1/payments/history';
  static const String paymentsEarnings = '$_v1/payments/earnings';
  static const String paymentsEarningsBreakdown =
      '$_v1/payments/earnings/breakdown';
  static const String paymentsWithdraw = '$_v1/payments/withdraw';
  static const String paymentsWithdrawals = '$_v1/payments/withdrawals';

  // --------------------------------------------------------------- reviews
  static const String reviews = '$_v1/reviews';
  static const String reviewsMy = '$_v1/reviews/my';
  static String reviewsForEquipment(String id) => '$_v1/reviews/equipment/$id';
  static String reviewsForUser(String id) => '$_v1/reviews/user/$id';
  static String review(String id) => '$_v1/reviews/$id';

  // ------------------------------------------------------------------ chat
  static const String chatConversations = '$_v1/chat/conversations';
  static const String chatUnreadCount = '$_v1/chat/unread-count';
  static const String chatSend = '$_v1/chat/send';
  static String chatConversation(String userId) =>
      '$_v1/chat/conversations/$userId';
  static String chatConversationRead(String userId) =>
      '$_v1/chat/conversations/$userId/read';
  static String chatMessageRead(String id) => '$_v1/chat/messages/$id/read';
  static String chatMessage(String id) => '$_v1/chat/messages/$id';

  // --------------------------------------------------------- notifications
  static const String notifications = '$_v1/notifications';
  static const String notificationsUnread = '$_v1/notifications/unread';
  static const String notificationsSettings =
      '$_v1/notifications/settings';
  static const String notificationsReadAll = '$_v1/notifications/read-all';
  static String notificationRead(String id) => '$_v1/notifications/$id/read';
  static String notification(String id) => '$_v1/notifications/$id';

  // ------------------------------------------------------------- favorites
  static const String favorites = '$_v1/favorites';
  static String favorite(String equipmentId) => '$_v1/favorites/$equipmentId';

  // ------------------------------------------- reports & dispute centre
  static const String reports = '$_v1/reports';
  static const String reportsMine = '$_v1/reports/my';
  static const String disputes = '$_v1/disputes';
  static String dispute(String id) => '$_v1/disputes/$id';
  static String disputeRespond(String id) => '$_v1/disputes/$id/respond';

  // ---------------------------------------------------------------- system
  static const String systemHealth = '$_v1/system/health';
  static const String systemConfig = '$_v1/system/config';
  static const String systemLocations = '$_v1/system/locations';
  static const String systemCategories = '$_v1/system/categories';
}