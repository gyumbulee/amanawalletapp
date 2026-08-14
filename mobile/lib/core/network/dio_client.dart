import 'package:dio/dio.dart';
import '../config/env_config.dart';
import 'auth_interceptor.dart';

/// Builds the single [Dio] instance used app-wide. Every feature's data
/// layer depends on this via Riverpod (see providers/global_providers.dart)
/// — no feature should create its own Dio instance.
class DioClientFactory {
  DioClientFactory._();

  static Dio create({required AuthInterceptor authInterceptor}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: EnvConfig.connectTimeout,
        receiveTimeout: EnvConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(authInterceptor);

    if (EnvConfig.isDev) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) {
            // Swap for a proper logger later; fine for local dev.
            // ignore: avoid_print
            print(obj);
          },
        ),
      );
    }

    return dio;
  }
}
