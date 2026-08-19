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
}

final profileControllerProvider = AsyncNotifierProvider<ProfileController, AuthUser>(
  ProfileController.new,
);
