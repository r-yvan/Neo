import '../models/booking_model.dart';
import '../models/paginated_response.dart';
import '../services/api_client.dart';
import '../../core/errors/exceptions.dart';

class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository(this._apiClient);

  Future<BookingModel> createBooking(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '/bookings',
        data: data,
      );
      return BookingModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<PaginatedResponse<BookingModel>> getMyBookings({
    String? role,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (role != null) queryParams['role'] = role;
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.get(
        '/bookings',
        queryParameters: queryParams,
      );

      return PaginatedResponse.fromJson(
        response.data,
        (json) => BookingModel.fromJson(json as Map<String, dynamic>),
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<BookingModel> getBookingById(String id) async {
    try {
      final response = await _apiClient.get('/bookings/$id');
      return BookingModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<BookingModel> acceptBooking(String id) async {
    try {
      final response = await _apiClient.patch('/bookings/$id/accept');
      return BookingModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<BookingModel> rejectBooking(String id) async {
    try {
      final response = await _apiClient.patch('/bookings/$id/reject');
      return BookingModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<BookingModel> cancelBooking(String id) async {
    try {
      final response = await _apiClient.patch('/bookings/$id/cancel');
      return BookingModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<BookingModel> startBooking(String id) async {
    try {
      final response = await _apiClient.patch('/bookings/$id/start');
      return BookingModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<BookingModel> completeBooking(String id) async {
    try {
      final response = await _apiClient.patch('/bookings/$id/complete');
      return BookingModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<BookingModel> disputeBooking(String id) async {
    try {
      final response = await _apiClient.patch('/bookings/$id/dispute');
      return BookingModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<BookingModel> extendBooking(String id, String newEndDate) async {
    try {
      final response = await _apiClient.post(
        '/bookings/$id/extend',
        data: {'newEndDate': newEndDate},
      );
      return BookingModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }
}
