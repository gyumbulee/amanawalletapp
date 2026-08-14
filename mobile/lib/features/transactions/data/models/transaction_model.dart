import '../../domain/entities/transaction.dart';

/// JSON <-> [Transaction] mapping.
///
/// Assumes each row looks like:
/// ```
/// { "reference": "...", "service": "airtime", "status": "successful",
///   "amount": 50000, "fee": 0, "description": "...", "recipient": "...",
///   "narration": "...", "provider_reference": "...", "created_at": "..." }
/// ```
class TransactionModel {
  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      reference: (json['reference'] ?? json['id']).toString(),
      service: TransactionService.fromApi(json['service'] as String?),
      status: TransactionStatus.fromApi(json['status'] as String?),
      amountKobo: _toKobo(json['amount']),
      feeKobo: _toKobo(json['fee']),
      description: json['description'] as String? ?? '',
      recipient: json['recipient'] as String?,
      narration: json['narration'] as String?,
      providerReference: json['provider_reference'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static int _toKobo(dynamic raw) {
    if (raw == null) return 0;
    if (raw is int) return raw;
    return int.tryParse(raw.toString()) ?? 0;
  }
}
