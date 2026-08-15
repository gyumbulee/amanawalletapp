import '../../../../constants/network_provider.dart';
import '../../domain/entities/data_plan.dart';

/// JSON <-> [DataPlan] mapping.
///
/// Actual `GET /data/plans?network=...` response (VTpass-style), wrapped
/// under `"plans"`:
/// `{ "variation_code": "mtn-100mb-1000", "name": "N1000 1.5GB - 30 days", "amount": 1000 }`
/// — `amount` is plain Naira (not kobo), and there's no separate size/
/// validity field: both are baked into `name` as "N<price> <size> - <validity>".
/// This parses that pattern and falls back to showing the raw name if it
/// ever doesn't match.
class DataPlanModel {
  static final _nameFormat = RegExp(r'^N\d+\s+(.+?)\s*-\s*(.+)$', caseSensitive: false);

  static DataPlan fromJson(Map<String, dynamic> json, NetworkProvider network) {
    final rawName = json['name'] as String? ?? '';
    final match = _nameFormat.firstMatch(rawName);

    return DataPlan(
      id: (json['variation_code'] ?? json['id']).toString(),
      network: network,
      name: rawName,
      sizeLabel: match != null ? match.group(1)!.trim() : rawName,
      validityLabel: match != null ? match.group(2)!.trim() : '',
      priceKobo: _nairaToKobo(json['amount']),
    );
  }

  static int _nairaToKobo(dynamic raw) {
    if (raw == null) return 0;
    final naira = raw is num ? raw : num.tryParse(raw.toString()) ?? 0;
    return (naira * 100).round();
  }
}

