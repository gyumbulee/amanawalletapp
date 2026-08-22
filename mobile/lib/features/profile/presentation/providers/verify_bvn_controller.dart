import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import 'profile_controller.dart';
import 'profile_repository_provider.dart';

class VerifyBvnController extends AsyncNotifier<bool> {
  @override
  bool build() => false;

  Future<void> submit({required String bvn}) async {
    state = const AsyncLoading();
    final repo = ref.read(profileRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repo.verifyBvn(bvn: bvn);
      // BVN verification is often async upstream (bank/NIBSS lookup), so
      // this may or may not actually flip to verified immediately — a
      // profile refresh (or the virtual account becoming active) is the
      // real source of truth, but reflect optimistically for now. Updates
      // both authSessionProvider and profileControllerProvider — see
      // upload_photo_controller.dart for why both are needed.
      ref.read(authSessionProvider.notifier).updateUser((u) => u.copyWith(isBvnVerified: true));
      ref.read(profileControllerProvider.notifier).setBvnVerified(true);
      return true;
    });
  }
}

final verifyBvnControllerProvider =
    AsyncNotifierProvider<VerifyBvnController, bool>(VerifyBvnController.new);
