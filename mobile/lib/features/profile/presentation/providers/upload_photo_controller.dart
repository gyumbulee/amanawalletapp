import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import 'profile_repository_provider.dart';

class UploadPhotoController extends AsyncNotifier<String?> {
  @override
  String? build() => null;

  Future<void> upload(String filePath) async {
    state = const AsyncLoading();
    final repo = ref.read(profileRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final avatarUrl = await repo.uploadPhoto(filePath);
      ref.read(authSessionProvider.notifier).updateUser((u) => u.copyWith(avatarUrl: avatarUrl));
      return avatarUrl;
    });
  }
}

final uploadPhotoControllerProvider =
    AsyncNotifierProvider<UploadPhotoController, String?>(UploadPhotoController.new);
