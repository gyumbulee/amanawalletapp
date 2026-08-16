import '../../domain/entities/wallet_balance.dart';
import '../../domain/entities/wallet_ledger_entry.dart';

/// JSON <-> [WalletBalance] mapping.
///
/// Actual `GET /wallet` response, wrapped under `"wallet"` (unwrapping
/// happens in the repository):
/// `{ "id": "...", "balance": 2000, "currency": "NGN", "status": "active",
///    "has_pin": false, "created_at": "..." }`
/// `balance` is plain Naira (not kobo) — same convention as the data plan
/// `amount` field — so this converts to kobo for internal use.
class WalletBalanceModel {
  static WalletBalance fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balanceKobo: _nairaToKobo(json['balance']),
      currency: json['currency'] as String? ?? 'NGN',
    );
  }

  static int _nairaToKobo(dynamic raw) {
    if (raw == null) return 0;
    final naira = raw is num ? raw : num.tryParse(raw.toString()) ?? 0;
    return (naira * 100).round();
  }
}

/// JSON <-> [WalletLedgerEntry] mapping.
///
/// Assumes each row looks like:
/// `{ "id": "...", "type": "credit", "amount": 50000, "balance_after": 150000,
///    "description": "...", "reference": "...", "created_at": "..." }`
class WalletLedgerEntryModel {
  static WalletLedgerEntry fromJson(Map<String, dynamic> json) {
    return WalletLedgerEntry(
      id: json['id'].toString(),
      type: (json['type'] as String?) == 'debit' ? LedgerEntryType.debit : LedgerEntryType.credit,
      amountKobo: _toKobo(json['amount']),
      balanceAfterKobo: _toKobo(json['balance_after']),
      description: json['description'] as String? ?? '',
      reference: json['reference'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static int _toKobo(dynamic raw) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }
}
