import '../entities/auth_user.dart';

/// Result of a register/verify-otp/login call. [token] is null when the
/// account still needs OTP verification before a session is issued
/// (register response); non-null once verified/logged in.
class AuthResult {
  const AuthResult({required this.user, this.token});
  final AuthUser user;
  final String? token;

  bool get requiresOtpVerification => token == null;
}

/// Domain-facing contract for all auth operations. Presentation code
/// (controllers/screens) depends only on this interface, never on Dio or
/// the concrete [AuthRepositoryImpl] — keeps the provider layer swappable
/// and testable.
abstract class AuthRepository {
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String bvn,
    String? referralCode,
  });

  Future<AuthResult> login({
    required String login,
    required String password,
  });

  Future<AuthResult> verifyOtp({
    required String email,
    required String otp,
  });

  Future<void> resendOtp({required String email});

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> logout();
}
