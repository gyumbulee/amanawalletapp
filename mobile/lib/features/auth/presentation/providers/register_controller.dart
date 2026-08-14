import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_repository_provider.dart';
import 'auth_session_provider.dart';

/// Drives the register screen. Registration typically returns no token yet
/// (email must be OTP-verified first) — [AuthResult.requiresOtpVerification]
/// tells the screen whether to navigate to /verify-otp or straight to
/// /dashboard.
class RegisterController extends AsyncNotifier<AuthResult?> {
  @override
  AuthResult? build() => null;

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String bvn,
    String? referralCode,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final result = await repo.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        bvn: bvn,
        referralCode: referralCode,
      );
      if (!result.requiresOtpVerification) {
        ref.read(authSessionProvider.notifier).setUser(result.user);
        ref.invalidate(isAuthenticatedProvider);
      }
      return result;
    });
  }
}

final registerControllerProvider =
    AsyncNotifierProvider<RegisterController, AuthResult?>(RegisterController.new);
