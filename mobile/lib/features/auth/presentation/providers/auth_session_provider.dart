import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_user.dart';

/// Holds the current [AuthUser] once known (after login/verify-otp, or
/// hydrated from a /profile call on app start in a later phase). Kept
/// separate from [isAuthenticatedProvider] in global_providers.dart, which
/// only answers "is there a token" for routing — this holds the richer
/// profile data screens actually render.
class AuthSessionController extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => null;

  void setUser(AuthUser user) => state = user;

  void updateUser(AuthUser Function(AuthUser current) update) {
    final current = state;
    if (current != null) state = update(current);
  }

  void clear() => state = null;
}

final authSessionProvider = NotifierProvider<AuthSessionController, AuthUser?>(
  AuthSessionController.new,
);
