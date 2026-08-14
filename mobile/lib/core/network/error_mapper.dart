import 'package:dio/dio.dart';
import '../errors/failure.dart';

/// Converts a [DioException] (or anything else thrown during a request)
/// into a typed [Failure] the UI layer can pattern-match on.
///
/// Expects Laravel's standard error shape:
/// ```
/// { "message": "...", "errors": { "field": ["msg"] } }
/// ```
class ErrorMapper {
  ErrorMapper._();

  static Failure map(Object error) {
    if (error is DioException) {
      return _mapDioException(error);
    }
    return const UnknownFailure();
  }

  static Failure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Secure connection failed.');
      case DioExceptionType.cancel:
        return const UnknownFailure('Request cancelled.');
      case DioExceptionType.badResponse:
        return _mapStatusCode(e);
      case DioExceptionType.unknown:
        return const NetworkFailure();
      // Default covers newer DioExceptionType values added in later Dio
      // releases (e.g. transformTimeout) that didn't exist when this was
      // written — treated as a network-layer failure rather than breaking
      // the build every time Dio adds a case.
      default:
        return const NetworkFailure();
    }
  }

  static Failure _mapStatusCode(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final message = _extractMessage(data);

    switch (status) {
      case 401:
        return UnauthorizedFailure(message ?? 'Session expired. Please log in again.');
      case 403:
        return ForbiddenFailure(message ?? 'You do not have permission to do that.');
      case 404:
        return NotFoundFailure(message ?? 'Not found.');
      case 422:
        return ValidationFailure(_extractErrors(data), message ?? 'Please check the form and try again.');
      case 409:
        return BusinessFailure(message ?? 'This action could not be completed.');
      case 429:
        return BusinessFailure(message ?? 'Too many attempts. Please wait and try again.');
      default:
        if (status != null && status >= 500) {
          return const ServerFailure();
        }
        return BusinessFailure(message ?? 'Something went wrong.');
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }

  static Map<String, List<String>> _extractErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      final raw = data['errors'] as Map;
      return raw.map((key, value) => MapEntry(
            key.toString(),
            (value as List).map((e) => e.toString()).toList(),
          ));
    }
    return {};
  }
}
