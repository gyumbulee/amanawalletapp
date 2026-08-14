import 'package:equatable/equatable.dart';

/// Base type for all recoverable errors surfaced to the UI.
///
/// Repositories return `Either`-style results (or throw these wrapped in a
/// Result type) so presentation code never has to catch DioException
/// directly — it only ever deals with a [Failure].
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Network unreachable, timeout, no internet, etc.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please try again.']);
}

/// 401 — token missing/expired/invalid. Route guard should force re-login.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired. Please log in again.']);
}

/// 422 — validation errors, keyed by field name for form display.
class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;
  const ValidationFailure(this.errors, [super.message = 'Please check the form and try again.']);

  @override
  List<Object?> get props => [message, errors];
}

/// 403 — authenticated but not permitted (e.g. suspended account).
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'You do not have permission to do that.']);
}

/// 404 — resource not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

/// 409 / business-rule errors from the API (e.g. insufficient wallet balance,
/// wrong transaction PIN, provider temporarily unavailable).
class BusinessFailure extends Failure {
  final String? code;
  const BusinessFailure(super.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// 5xx or unrecognized server error.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on our end. Please try again shortly.']);
}

/// Fallback for anything unmapped.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
