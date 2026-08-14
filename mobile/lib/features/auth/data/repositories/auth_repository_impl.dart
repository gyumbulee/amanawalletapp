import '../../../../core/errors/failure.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_service.dart';
import '../models/auth_user_model.dart';

/// Concrete [AuthRepository]. Catches Dio errors, maps them through
/// [ErrorMapper] into typed [Failure]s, and rethrows those — controllers
/// only ever need to catch [Failure], never Dio internals.
///
/// Expected response shape (adjust if your Laravel resources differ):
/// ```
/// { "message": "...", "user": {...}, "token": "..." }   // login / verify-otp
/// { "message": "OTP sent to your email", "user": {...} } // register (no token yet)
/// ```
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._secureStorage);

  final AuthApiService _api;
  final SecureStorageService _secureStorage;

  @override
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String bvn,
    String? referralCode,
  }) async {
    try {
      final response = await _api.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        bvn: bvn,
        referralCode: referralCode,
      );
      final data = response.data as Map<String, dynamic>;
      final user = AuthUserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String?;
      if (token != null) await _secureStorage.saveAuthToken(token);
      return AuthResult(user: user, token: token);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<AuthResult> login({required String login, required String password}) async {
    try {
      final response = await _api.login(login: login, password: password);
      final data = response.data as Map<String, dynamic>;
      final user = AuthUserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String?;
      if (token != null) await _secureStorage.saveAuthToken(token);
      return AuthResult(user: user, token: token);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<AuthResult> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _api.verifyOtp(email: email, otp: otp);
      final data = response.data as Map<String, dynamic>;
      final user = AuthUserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String?;
      if (token != null) await _secureStorage.saveAuthToken(token);
      return AuthResult(user: user, token: token);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    try {
      await _api.resendOtp(email: email);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _api.forgotPassword(email: email);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _api.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Even if the server call fails (e.g. token already expired), we
      // still want to clear the local session below.
    } finally {
      await _secureStorage.clearAll();
    }
  }
}
