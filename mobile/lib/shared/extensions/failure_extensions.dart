import '../../core/errors/failure.dart';

extension ValidationFailureFieldError on Failure? {
  /// Returns the first validation error message for [field], or null if
  /// this isn't a [ValidationFailure] or has no error for that field.
  String? fieldError(String field) {
    final f = this;
    if (f is ValidationFailure) {
      final errors = f.errors[field];
      if (errors != null && errors.isNotEmpty) return errors.first;
    }
    return null;
  }
}
