import '../../domain/entities/transaction.dart';

/// JSON <-> [Transaction] mapping.
///
/// Actual `GET /transactions` row shape (list wraps under "transactions",
/// handled in the repository), confirmed from a real response:
/// ```
/// { "id": "...", "type": "referral_bonus", "reference": "TXN-...",
///   "amount": 200, "fee": 0, "status": "successful", "provider": null,
///   "description": "...", "meta": {...}, "created_at": "..." }
/// ```
/// `amount`/`fee` are plain Naira (not kobo), same convention as wallet
/// balance and every bill-payment amount field on this backend. The
/// service/type field is called "type", not "service".
///
/// `id` (UUID) and `reference` (human-readable TXN-... string) are kept as
/// separate fields — `GET /transactions/{id}` looks up by the UUID, not the
/// reference string, so navigation/detail-fetch must use [Transaction.id],
/// while [Transaction.reference] stays purely for display.
class TransactionModel {
  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: (json['id'] ?? json['reference']).toString(),
      reference: (json['reference'] ?? json['id']).toString(),
      service: TransactionService.fromApi((json['type'] ?? json['service']) as String?),
      status: TransactionStatus.fromApi(json['status'] as String?),
      amountKobo: _nairaToKobo(json['amount']),
      feeKobo: _nairaToKobo(json['fee']),
      description: json['description'] as String? ?? '',
      recipient: json['recipient'] as String?,
      narration: json['narration'] as String?,
      providerReference: json['provider_reference'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static int _nairaToKobo(dynamic raw) {
    if (raw == null) return 0;
    final naira = raw is num ? raw : num.tryParse(raw.toString()) ?? 0;
    return (naira * 100).round();
  }
}
