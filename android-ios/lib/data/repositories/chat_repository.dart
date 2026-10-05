import '../models/message_model.dart';
import '../models/paginated_response.dart';
import '../services/api_client.dart';
import '../../core/errors/exceptions.dart';

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await _apiClient.get('/chat/conversations');
      return List<Map<String, dynamic>>.from(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/chat/unread-count');
      return response.data['count'] as int;
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<PaginatedResponse<MessageModel>> getMessages(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/chat/conversations/$userId',
        queryParameters: {'page': page, 'limit': limit},
      );

      return PaginatedResponse.fromJson(
        response.data,
        (json) => MessageModel.fromJson(json as Map<String, dynamic>),
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<MessageModel> sendMessage(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '/chat/send',
        data: data,
      );
      return MessageModel.fromJson(response.data);
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _apiClient.patch('/chat/messages/$messageId/read');
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> markConversationAsRead(String userId) async {
    try {
      await _apiClient.patch('/chat/conversations/$userId/read');
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _apiClient.delete('/chat/messages/$messageId');
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }
}
