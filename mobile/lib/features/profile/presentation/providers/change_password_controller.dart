import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_repository_provider.dart';

class ChangePasswordController extends AsyncNotifier<bool> {
  @override
  bool build() => false;

  Future<void> submit({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(profileRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      return true;
    });
  }
}

final changePasswordControllerProvider =
    AsyncNotifierProvider<ChangePasswordController, bool>(ChangePasswordController.new);
