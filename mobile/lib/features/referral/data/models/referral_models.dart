import '../../domain/entities/referral_entry.dart';
import '../../domain/entities/referral_summary.dart';

/// JSON <-> [ReferralSummary] mapping.
///
/// Assumed shape (amounts in plain Naira, per this backend's established
/// convention — see wallet/data plan amount fixes):
/// `{ "referral_code": "...", "referral_count": 3, "total_earnings": 500 }`
class ReferralSummaryModel {
  static ReferralSummary fromJson(Map<String, dynamic> json) {
    return ReferralSummary(
      referralCode: json['referral_code'] as String? ?? '',
      referralCount: (json['referral_count'] as num?)?.toInt() ?? 0,
      totalEarningsKobo: _nairaToKobo(json['total_earnings']),
    );
  }

  static int _nairaToKobo(dynamic raw) {
    if (raw == null) return 0;
    final naira = raw is num ? raw : num.tryParse(raw.toString()) ?? 0;
    return (naira * 100).round();
  }
}

/// JSON <-> [ReferralEntry] mapping.
///
/// Assumed shape: `{ "id": "...", "referee_name": "...", "status": "completed",
/// "bonus_amount": 200, "created_at": "..." }`
class ReferralEntryModel {
  static ReferralEntry fromJson(Map<String, dynamic> json) {
    return ReferralEntry(
      id: json['id'].toString(),
      refereeName: (json['referee_name'] ?? json['name']) as String? ?? '',
      status:
          (json['status'] as String?) == 'completed' ? ReferralStatus.completed : ReferralStatus.pending,
      bonusKobo: _nairaToKobo(json['bonus_amount'] ?? json['bonus']),
      joinedAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static int _nairaToKobo(dynamic raw) {
    if (raw == null) return 0;
    final naira = raw is num ? raw : num.tryParse(raw.toString()) ?? 0;
    return (naira * 100).round();
  }
}
