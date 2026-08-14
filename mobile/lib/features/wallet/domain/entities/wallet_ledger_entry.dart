import 'package:equatable/equatable.dart';

enum LedgerEntryType { credit, debit }

/// A single row from the wallet_ledgers table — the raw credit/debit trail
/// backing the wallet balance. Distinct from a full Transaction (built in
/// the `transactions` feature): the ledger is wallet-internal bookkeeping,
/// while a Transaction represents the customer-facing operation (airtime
/// purchase, wallet funding, etc.) that caused it.
class WalletLedgerEntry extends Equatable {
  const WalletLedgerEntry({
    required this.id,
    required this.type,
    required this.amountKobo,
    required this.balanceAfterKobo,
    required this.description,
    required this.createdAt,
    this.reference,
  });

  final String id;
  final LedgerEntryType type;
  final int amountKobo;
  final int balanceAfterKobo;
  final String description;
  final DateTime createdAt;
  final String? reference;

  bool get isCredit => type == LedgerEntryType.credit;

  @override
  List<Object?> get props =>
      [id, type, amountKobo, balanceAfterKobo, description, createdAt, reference];
}
