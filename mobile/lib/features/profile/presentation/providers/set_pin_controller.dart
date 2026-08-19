import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import 'profile_repository_provider.dart';

class SetPinController extends AsyncNotifier<bool> {
  @override
  bool build() => false;

  Future<void> submit({required String pin, required String pinConfirmation}) async {
    state = const AsyncLoading();
    final repo = ref.read(profileRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repo.setTransactionPin(pin: pin, pinConfirmation: pinConfirmation);
      // Reflect immediately in the session so any screen checking
      // hasTransactionPin (e.g. gating a purchase flow later) sees it
      // without needing a full profile refetch.
      ref.read(authSessionProvider.notifier).updateUser((u) => u.copyWith(hasTransactionPin: true));
      return true;
    });
  }
}

final setPinControllerProvider = AsyncNotifierProvider<SetPinController, bool>(SetPinController.new);
