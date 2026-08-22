import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import 'profile_repository_provider.dart';

/// Fetches the current user via GET /auth/me and mirrors it into
/// [authSessionProvider] so the dashboard greeting/avatar and everywhere
/// else that reads the session stay in sync with whatever the Profile
/// screen just loaded or changed.
class ProfileController extends AsyncNotifier<AuthUser> {
  @override
  Future<AuthUser> build() async {
    final user = await ref.read(profileRepositoryProvider).getProfile();
    ref.read(authSessionProvider.notifier).setUser(user);
    return user;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(profileRepositoryProvider).getProfile();
      ref.read(authSessionProvider.notifier).setUser(user);
      return user;
    });
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final user = await ref.read(profileRepositoryProvider).updateProfile(
            firstName: firstName,
            lastName: lastName,
            phone: phone,
          );
      ref.read(authSessionProvider.notifier).setUser(user);
      return user;
    });
    state = result;
    return !result.hasError;
  }

  /// Patches just the avatar URL into this controller's cached state.
  /// Called from UploadPhotoController after a successful upload — without
  /// this, the Profile screen (which reads from here, not
  /// authSessionProvider directly) wouldn't reflect the new photo until a
  /// manual refresh or navigating away and back.
  void setAvatarUrl(String avatarUrl) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(avatarUrl: avatarUrl));
    }
  }

  /// Same reasoning as [setAvatarUrl] — called from VerifyBvnController so
  /// the Profile screen's BVN badge updates immediately.
  void setBvnVerified(bool verified) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(isBvnVerified: verified));
    }
  }
}

final profileControllerProvider = AsyncNotifierProvider<ProfileController, AuthUser>(
  ProfileController.new,
);
