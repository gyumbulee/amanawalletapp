import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import 'auth_repository_provider.dart';
import 'auth_session_provider.dart';

/// [loggedIn] tells the screen where to navigate: true → dashboard
/// (backend issued a session on verify), false → login screen (backend's
/// verify-email endpoint only confirms verification, per the actual API —
/// the user still needs to log in manually).
class OtpVerifyOutcome {
  const OtpVerifyOutcome({required this.loggedIn});
  final bool loggedIn;
}

class OtpVerifyController extends AsyncNotifier<OtpVerifyOutcome?> {
  @override
  OtpVerifyOutcome? build() => null;

  Future<void> verify({required String email, required String otp}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final result = await repo.verifyOtp(email: email, otp: otp);
      if (result != null) {
        ref.read(authSessionProvider.notifier).setUser(result.user);
        ref.invalidate(isAuthenticatedProvider);
        return const OtpVerifyOutcome(loggedIn: true);
      }
      return const OtpVerifyOutcome(loggedIn: false);
    });
  }
}

final otpVerifyControllerProvider =
    AsyncNotifierProvider<OtpVerifyController, OtpVerifyOutcome?>(OtpVerifyController.new);

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
