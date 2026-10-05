import '../models/equipment_model.dart';
import '../models/paginated_response.dart';
import '../services/api_client.dart';
import '../../core/errors/exceptions.dart';

class EquipmentRepository {
  final ApiClient _apiClient;

  EquipmentRepository(this._apiClient);

  Future<PaginatedResponse<EquipmentModel>> getEquipment({
    String? category,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? date,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (category != null) queryParams['category'] = category;
      if (location != null) queryParams['location'] = location;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (date != null) queryParams['date'] = date;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radiusKm != null) queryParams['radiusKm'] = radiusKm;
      if (search != null) queryParams['search'] = search;

      final response = await _apiClient.get(
        '/equipment',
        queryParameters: queryParams,
      );

      return PaginatedResponse.fromJson(
        response.data,
        (json) => EquipmentModel.fromJson(json as Map<String, dynamic>),
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<EquipmentModel> getEquipmentById(String id) async {
    try {
      final response = await _apiClient.get('/equipment/$id');
      return EquipmentModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<PaginatedResponse<EquipmentModel>> getMyEquipment({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/equipment/my',
        queryParameters: {'page': page, 'limit': limit},
      );

      return PaginatedResponse.fromJson(
        response.data,
        (json) => EquipmentModel.fromJson(json as Map<String, dynamic>),
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<EquipmentModel> createEquipment(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '/equipment',
        data: data,
      );
      return EquipmentModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<EquipmentModel> updateEquipment(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        '/equipment/$id',
        data: data,
      );
      return EquipmentModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> deleteEquipment(String id) async {
    try {
      await _apiClient.delete('/equipment/$id');
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> addImages(String id, List<String> urls) async {
    try {
      await _apiClient.post(
        '/equipment/$id/images',
        data: {'urls': urls},
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> removeImage(String id, String imageId) async {
    try {
      await _apiClient.delete('/equipment/$id/images/$imageId');
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> boostEquipment(String id, {int days = 7}) async {
    try {
      await _apiClient.post(
        '/equipment/$id/boost',
        data: {'days': days},
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> cancelBoost(String id) async {
    try {
      await _apiClient.delete('/equipment/$id/boost');
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get('/equipment/categories');
      return List<String>.from(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<PaginatedResponse<EquipmentModel>> getPopularEquipment({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/equipment/popular',
        queryParameters: {'page': page, 'limit': limit},
      );

      return PaginatedResponse.fromJson(
        response.data,
        (json) => EquipmentModel.fromJson(json as Map<String, dynamic>),
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }
}
