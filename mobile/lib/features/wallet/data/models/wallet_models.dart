import '../../domain/entities/wallet_balance.dart';
import '../../domain/entities/wallet_ledger_entry.dart';

/// JSON <-> [WalletBalance] mapping.
///
/// Assumes `GET /wallet/balance` returns:
/// `{ "balance": 150000, "currency": "NGN" }` with balance in kobo.
/// If your backend returns balance as a decimal Naira string instead,
/// convert here (e.g. `(double.parse(json['balance']) * 100).round()`).
class WalletBalanceModel {
  static WalletBalance fromJson(Map<String, dynamic> json) {
    final raw = json['balance'];
    final balanceKobo = raw is int ? raw : int.tryParse(raw.toString()) ?? 0;
    return WalletBalance(
      balanceKobo: balanceKobo,
      currency: json['currency'] as String? ?? 'NGN',
    );
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
