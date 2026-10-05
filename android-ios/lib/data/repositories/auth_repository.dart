import '../models/auth_models.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';
import '../../core/errors/exceptions.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository(this._apiClient, this._storageService);

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveAuthData(authResponse);
      return authResponse;
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveAuthData(authResponse);
      return authResponse;
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> sendOtp(String phone) async {
    try {
      await _apiClient.post(
        '/auth/send-otp',
        data: SendOtpRequest(phone: phone).toJson(),
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<AuthResponse> verifyOtp(String phone, String otp) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-otp',
        data: VerifyOtpRequest(phone: phone, otp: otp).toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveAuthData(authResponse);
      return authResponse;
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.post(
          '/auth/logout',
          data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
        );
      }
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _storageService.clearAuthData();
    }
  }

  Future<void> forgotPassword(String phone) async {
    try {
      await _apiClient.post(
        '/auth/forgot-password',
        data: {'phone': phone},
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<void> resetPassword(String phone, String otp, String newPassword) async {
    try {
      await _apiClient.post(
        '/auth/reset-password',
        data: {
          'phone': phone,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    }
  }

  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  Future<String?> getCurrentUserId() async {
    return await _storageService.getUserId();
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _storageService.setAccessToken(authResponse.accessToken);
    await _storageService.setRefreshToken(authResponse.refreshToken);
    await _storageService.setUserId(authResponse.user.id);
    await _storageService.setUserProfile(authResponse.user.toJson());
  }
}
