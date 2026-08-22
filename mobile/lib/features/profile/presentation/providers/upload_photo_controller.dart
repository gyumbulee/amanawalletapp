import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import 'profile_controller.dart';
import 'profile_repository_provider.dart';

class UploadPhotoController extends AsyncNotifier<String?> {
  @override
  String? build() => null;

  Future<void> upload(Uint8List bytes, String filename) async {
    state = const AsyncLoading();
    final repo = ref.read(profileRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final avatarUrl = await repo.uploadPhoto(bytes, filename);
      // Update both: authSessionProvider (dashboard avatar/greeting) and
      // profileControllerProvider (the Profile screen itself) — they're
      // separate cached states, so both need patching for the change to
      // show up everywhere immediately without a manual refresh.
      ref.read(authSessionProvider.notifier).updateUser((u) => u.copyWith(avatarUrl: avatarUrl));
      ref.read(profileControllerProvider.notifier).setAvatarUrl(avatarUrl);
      return avatarUrl;
    });
  }
}

final uploadPhotoControllerProvider =
    AsyncNotifierProvider<UploadPhotoController, String?>(UploadPhotoController.new);
