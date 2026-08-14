import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import 'auth_repository_provider.dart';
import 'auth_session_provider.dart';

class LogoutController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> logout() async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repo.logout();
      ref.read(authSessionProvider.notifier).clear();
      ref.invalidate(isAuthenticatedProvider);
    });
  }
}

final logoutControllerProvider = AsyncNotifierProvider<LogoutController, void>(LogoutController.new);
