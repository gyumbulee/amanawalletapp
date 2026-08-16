import '../../../../constants/cable_provider.dart';
import '../../domain/entities/cable_package.dart';

/// JSON <-> [CablePackage] mapping.
///
/// Assumed VTpass-style shape (matching the confirmed `/data/plans` shape):
/// `{ "variation_code": "dstv-padi", "name": "DStv Padi", "amount": 2150 }`
/// with amount in plain Naira, converted to kobo here.
class CablePackageModel {
  static CablePackage fromJson(Map<String, dynamic> json, CableProvider provider) {
    return CablePackage(
      id: (json['variation_code'] ?? json['id']).toString(),
      provider: provider,
      name: json['name'] as String? ?? '',
      priceKobo: _nairaToKobo(json['amount'] ?? json['price']),
    );
  }

  static int _nairaToKobo(dynamic raw) {
    if (raw == null) return 0;
    final naira = raw is num ? raw : num.tryParse(raw.toString()) ?? 0;
    return (naira * 100).round();
  }
}
