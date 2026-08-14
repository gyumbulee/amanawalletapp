import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import 'auth_repository_provider.dart';
import 'auth_session_provider.dart';

class OtpVerifyController extends AsyncNotifier<bool> {
  @override
  bool build() => false; // verified?

  Future<void> verify({required String email, required String otp}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final result = await repo.verifyOtp(email: email, otp: otp);
      ref.read(authSessionProvider.notifier).setUser(result.user);
      ref.invalidate(isAuthenticatedProvider);
      return true;
    });
  }
}

final otpVerifyControllerProvider =
    AsyncNotifierProvider<OtpVerifyController, bool>(OtpVerifyController.new);

/// Separate controller for the "resend OTP" action so its own loading/error
/// state doesn't collide with the main verify button's state.
class ResendOtpController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> resend({required String email}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => repo.resendOtp(email: email));
  }
}

final resendOtpControllerProvider =
    AsyncNotifierProvider<ResendOtpController, void>(ResendOtpController.new);
