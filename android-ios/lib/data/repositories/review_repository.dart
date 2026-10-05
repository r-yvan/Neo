import '../models/review_model.dart';
import '../models/paginated_response.dart';
import '../services/api_client.dart';
import '../../core/errors/exceptions.dart';

class ReviewRepository {
  final ApiClient _apiClient;

  ReviewRepository(this._apiClient);

  Future<ReviewModel> createReview(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '/reviews',
        data: data,
      );
      return ReviewModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<PaginatedResponse<ReviewModel>> getMyReviews({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/reviews/my',
        queryParameters: {'page': page, 'limit': limit},
      );

      return PaginatedResponse.fromJson(
        response.data,
        (json) => ReviewModel.fromJson(json as Map<String, dynamic>),
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<PaginatedResponse<ReviewModel>> getEquipmentReviews(
    String equipmentId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/reviews/equipment/$equipmentId',
        queryParameters: {'page': page, 'limit': limit},
      );

      return PaginatedResponse.fromJson(
        response.data,
        (json) => ReviewModel.fromJson(json as Map<String, dynamic>),
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<PaginatedResponse<ReviewModel>> getUserReviews(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/reviews/user/$userId',
        queryParameters: {'page': page, 'limit': limit},
      );

      return PaginatedResponse.fromJson(
        response.data,
        (json) => ReviewModel.fromJson(json as Map<String, dynamic>),
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<ReviewModel> updateReview(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        '/reviews/$id',
        data: data,
      );
      return ReviewModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      await _apiClient.delete('/reviews/$id');
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }
}
