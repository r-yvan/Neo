import '../../core/network/api_paths.dart';
import '../../core/utils/parsing.dart';
import '../models/models.dart';

/// Registration, OTP, session refresh and password reset.
///
/// The backend accepts either `password` or `otp` on `/auth/login`; the app
/// leads with password and falls back to OTP when the account has none.
class AuthRepository {
  AuthRepository(this._post, this._get);

  final Future<dynamic> Function(String path,
      {Object? body, bool skipAuth}) _post;
  final Future<dynamic> Function(String path,
      {Map<String, dynamic>? query, bool skipAuth}) _get;

  Future<AuthSession> register({
    required String phone,
    required String fullName,
    String? nationalId,
    String? email,
    String? password,
  }) async =>
      AuthSession.fromJson(asMap(await _post(ApiPaths.authRegister, body: {
        'phone': phone,
        'fullName': fullName,
        if (nationalId != null && nationalId.isNotEmpty)
          'nationalId': nationalId,
        if (email != null && email.isNotEmpty) 'email': email,
        if (password != null && password.length >= 6) 'password': password,
      }, skipAuth: true)));

  Future<AuthSession> loginWithPassword({
    required String phone,
    required String password,
  }) async =>
      AuthSession.fromJson(asMap(await _post(ApiPaths.authLogin,
          body: {'phone': phone, 'password': password},
          skipAuth: true)));

  Future<AuthSession> loginWithOtp({
    required String phone,
    required String otp,
  }) async =>
      AuthSession.fromJson(asMap(await _post(ApiPaths.authLogin,
          body: {'phone': phone, 'otp': otp},
          skipAuth: true)));

  Future<OtpDispatch> sendOtp(String phone) async => OtpDispatch.fromJson(asMap(
      await _post(ApiPaths.authSendOtp, body: {'phone': phone}, skipAuth: true)));

  /// Verifying also flips `isVerified` on the user and returns fresh tokens.
  Future<AuthSession> verifyOtp({
    required String phone,
    required String otp,
  }) async =>
      AuthSession.fromJson(asMap(await _post(ApiPaths.authVerifyOtp,
          body: {'phone': phone, 'otp': otp},
          skipAuth: true)));

  Future<String> forgotPassword(String phone) async {
    final dynamic res = await _post(ApiPaths.authForgotPassword,
        body: {'phone': phone}, skipAuth: true);
    return asString(asMap(res)['message'], 'Check your phone for an OTP');
  }

  Future<String> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    final dynamic res = await _post(ApiPaths.authResetPassword, body: {
      'phone': phone,
      'otp': otp,
      'newPassword': newPassword,
    }, skipAuth: true);
    return asString(asMap(res)['message'], 'Password reset');
  }

  Future<void> logout(String refreshToken) =>
      _post(ApiPaths.authLogout, body: {'refreshToken': refreshToken});

  Future<AppUser> me() async => AppUser.fromJson(asMap(await _get(ApiPaths.authMe)));
}