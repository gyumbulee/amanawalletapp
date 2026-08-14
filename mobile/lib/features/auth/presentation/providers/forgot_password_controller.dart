import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository_provider.dart';

class ForgotPasswordController extends AsyncNotifier<bool> {
  @override
  bool build() => false; // OTP sent?

  Future<void> submit({required String email}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repo.forgotPassword(email: email);
      return true;
    });
  }
}

final forgotPasswordControllerProvider =
    AsyncNotifierProvider<ForgotPasswordController, bool>(ForgotPasswordController.new);
