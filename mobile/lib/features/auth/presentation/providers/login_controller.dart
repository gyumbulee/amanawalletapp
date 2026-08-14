import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_repository_provider.dart';
import 'auth_session_provider.dart';

class LoginController extends AsyncNotifier<AuthResult?> {
  @override
  AuthResult? build() => null;

  Future<void> login({required String login, required String password}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final result = await repo.login(login: login, password: password);
      if (!result.requiresOtpVerification) {
        ref.read(authSessionProvider.notifier).setUser(result.user);
        ref.invalidate(isAuthenticatedProvider);
      }
      return result;
    });
  }

  void reset() => state = const AsyncData(null);
}

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, AuthResult?>(LoginController.new);
