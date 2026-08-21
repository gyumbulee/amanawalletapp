import 'package:equatable/equatable.dart';

/// Wallet balance snapshot. Amount is stored in kobo (integer minor units)
/// to match the Laravel ledger and avoid floating point drift — see
/// shared/extensions/currency_extensions.dart for kobo<->Naira display.
class WalletBalance extends Equatable {
  const WalletBalance({
    required this.balanceKobo,
    this.currency = 'NGN',
    this.hasPin = false,
  });

  final int balanceKobo;
  final String currency;

  /// Whether a transaction PIN has been set. Lives on the wallet record on
  /// the backend (not the user), confirmed from a real `GET /wallet`
  /// response — this is the source of truth, not AuthUser.hasTransactionPin.
  final bool hasPin;

  @override
  List<Object?> get props => [balanceKobo, currency, hasPin];
}
