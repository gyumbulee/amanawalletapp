import '../../domain/entities/smartcard_validation.dart';

/// JSON <-> [SmartcardValidation] mapping.
///
/// Assumes `POST /cable/verify-smartcard` returns `{ "customer_name": "..." }`
/// (or nested under "data" — handled in the repository). Endpoint name is a
/// guess following the same convention Electricity actually used
/// (`verify-meter`, not `validate`) — check the real route if this 404s,
/// same as electricity did.
class SmartcardValidationModel {
  static SmartcardValidation fromJson(Map<String, dynamic> json) {
    return SmartcardValidation(customerName: json['customer_name'] as String? ?? '');
  }
}
