import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

/// Attaches the Sanctum bearer token to every outgoing request and reacts
/// to 401 responses by clearing the stored session and notifying the app
/// (via [onUnauthorized]) so the router can redirect to /login.
///
/// Kept decoupled from GoRouter on purpose — network code shouldn't import
/// routing code. [onUnauthorized] is wired up once in global_providers.dart.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage, {this.onUnauthorized});

  final SecureStorageService _secureStorage;
  final Future<void> Function()? onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _secureStorage.deleteAuthToken();
      if (onUnauthorized != null) {
        await onUnauthorized!();
      }
    }
    handler.next(err);
  }
}
