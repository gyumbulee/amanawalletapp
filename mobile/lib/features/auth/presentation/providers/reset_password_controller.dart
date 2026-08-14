import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository_provider.dart';

class ResetPasswordController extends AsyncNotifier<bool> {
  @override
  bool build() => false; // reset succeeded?

  Future<void> submit({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repo.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return true;
    });
  }
}

final resetPasswordControllerProvider =
    AsyncNotifierProvider<ResetPasswordController, bool>(ResetPasswordController.new);
