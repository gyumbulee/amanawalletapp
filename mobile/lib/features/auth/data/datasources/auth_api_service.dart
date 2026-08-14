import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

/// Thin wrapper around Dio for the /auth/* endpoints — returns raw
/// [Response] data. Mapping to domain types and error handling both happen
/// one layer up in [AuthRepositoryImpl], so this class stays a pure HTTP
/// client with no business logic.
class AuthApiService {
  AuthApiService(this._dio);
  final Dio _dio;

  Future<Response> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String bvn,
    String? referralCode,
  }) {
    return _dio.post(ApiEndpoints.register, data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'bvn': bvn,
      if (referralCode != null && referralCode.isNotEmpty) 'referral_code': referralCode,
    });
  }

  Future<Response> login({required String login, required String password}) {
    return _dio.post(ApiEndpoints.login, data: {
      'login': login,
      'password': password,
    });
  }

  Future<Response> verifyOtp({required String email, required String otp}) {
    return _dio.post(ApiEndpoints.verifyOtp, data: {
      'email': email,
      'otp': otp,
    });
  }

  Future<Response> resendOtp({required String email}) {
    return _dio.post(ApiEndpoints.resendOtp, data: {'email': email});
  }

  Future<Response> forgotPassword({required String email}) {
    return _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  Future<Response> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) {
    return _dio.post(ApiEndpoints.resetPassword, data: {
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<Response> logout() {
    return _dio.post(ApiEndpoints.logout);
  }
}
