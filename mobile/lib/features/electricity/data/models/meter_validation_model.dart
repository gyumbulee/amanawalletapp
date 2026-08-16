import '../../domain/entities/meter_validation.dart';

/// JSON <-> [MeterValidation] mapping.
///
/// Assumes `POST /electricity/validate` returns:
/// `{ "customer_name": "...", "address": "..." }`
/// (or nested under "data" — handled in the repository).
class MeterValidationModel {
  static MeterValidation fromJson(Map<String, dynamic> json) {
    return MeterValidation(
      customerName: json['customer_name'] as String? ?? '',
      customerAddress: json['address'] as String?,
    );
  }
}
