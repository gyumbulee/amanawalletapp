import '../../domain/entities/profile_validation.dart';

/// JSON <-> [ProfileValidation] mapping.
///
/// Assumes `POST /education/verify-profile` returns
/// `{ "candidate_name": "..." }` (or nested under "data"). Endpoint name
/// is a guess following the `verify-*` convention electricity/cable
/// actually used — check the real route if this 404s, same fix as before.
class ProfileValidationModel {
  static ProfileValidation fromJson(Map<String, dynamic> json) {
    return ProfileValidation(
      candidateName: (json['candidate_name'] ?? json['customer_name']) as String? ?? '',
    );
  }
}
