import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/auth_interceptor.dart';
import '../core/network/dio_client.dart';
import '../core/storage/local_storage_service.dart';
import '../core/storage/secure_storage_service.dart';

/// Overridden in main.dart with the resolved instance once
/// `SharedPreferences.getInstance()` completes (must happen before runApp).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

/// Bumped to force a router redirect re-evaluation right after logout, since
/// GoRouter doesn't automatically know secure storage changed.
final authRefreshProvider = StateProvider<int>((ref) => 0);

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthInterceptor(
    secureStorage,
    onUnauthorized: () async {
      ref.read(authRefreshProvider.notifier).state++;
    },
  );
});

final dioProvider = Provider<Dio>((ref) {
  final authInterceptor = ref.watch(authInterceptorProvider);
  return DioClientFactory.create(authInterceptor: authInterceptor);
});

/// Simple auth-status check used by the router redirect. Individual features
/// (e.g. auth_controller in features/auth/presentation/providers) own the
/// richer session/user state — this just answers "is there a token?".
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  ref.watch(authRefreshProvider); // re-run when bumped after a 401
  final secureStorage = ref.watch(secureStorageProvider);
  final token = await secureStorage.getAuthToken();
  return token != null && token.isNotEmpty;
});
